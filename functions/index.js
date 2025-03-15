const express = require('express');
const session = require('express-session');
const fetch = require('node-fetch');
const oauth2orize = require('oauth2orize');
const app = express();

// Cấu hình middleware cho Express
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Thêm express-session middleware
app.use(session({
  secret: 'your-secret-key', // Thay bằng một chuỗi bí mật bất kỳ
  resave: false,
  saveUninitialized: false
}));

// Cấu hình Firebase
const FIREBASE_URL = 'https://iot-nhom08-default-rtdb.asia-southeast1.firebasedatabase.app/LED_CONTROL/nutNguon.json';
const FIREBASE_AUTH_TOKEN = 'your-firebase-secret'; // Thay bằng secret thực tế từ Firebase Console

// --- OAuth 2.0 Setup ---
const oauthServer = oauth2orize.createServer();

// Danh sách client (có thể thay đổi theo giá trị thực tế từ Google Smart Home Console)
const clients = [
  { id: 'ABC123', secret: 'DEF456', redirectUri: 'https://oauth-redirect.googleusercontent.com/r/smartlight08' }
];

// Serialize và deserialize client
oauthServer.serializeClient((client, done) => done(null, client.id));
oauthServer.deserializeClient((id, done) => {
  const client = clients.find(c => c.id === id);
  done(null, client);
});

// Cấu hình OAuth 2.0: Định nghĩa grant code
oauthServer.grant(oauth2orize.grant.code((client, redirectUri, user, ares, done) => {
  const code = 'fake-auth-code'; // Giả lập mã code
  done(null, code);
}));

// Định nghĩa exchange code thành token
oauthServer.exchange(oauth2orize.exchange.code((client, code, redirectUri, done) => {
  console.log('Exchange code:', { client, code, redirectUri }); // Log để debug
  if (code === 'fake-auth-code') {
    const token = 'fake-access-token'; // Giả lập token
    return done(null, token);
  }
  return done(null, false);
}));
// Endpoint OAuth 2.0: Authorization
app.get('/auth', (req, res) => {
  console.log('Authorization request:', req.query); // Log này hiển thị state
  const { client_id, redirect_uri, response_type, state } = req.query;
  if (!state) {
    return res.status(400).send('Missing required parameter: state');
  }
  res.redirect(`/auth/authorize?client_id=${client_id}&redirect_uri=${redirect_uri}&response_type=${response_type}&state=${state}`);
});

app.get('/auth/authorize', 
  oauthServer.authorization((clientId, redirectUri, done) => {
    console.log('Validating client:', { clientId, redirectUri });
    const client = clients.find(c => c.id === clientId);
    if (!client) {
      console.log('Client not found:', clientId);
      return done(null, false);
    }
    if (client.redirectUri !== redirectUri) {
      console.log('Redirect URI mismatch:', { expected: client.redirectUri, received: redirectUri });
      return done(null, false);
    }
    return done(null, client, redirectUri);
  }, (client, user, done) => {
    return done(null, true);
  }),
  (req, res) => {
    res.redirect(`${req.oauth2.redirectURI}?code=fake-auth-code&state=${req.query.state}`);
  }
);



// Endpoint OAuth 2.0: Token
app.post('/token', oauthServer.token());

// --- Smart Home Setup ---
app.post('/smarthome', async (req, res) => {
  console.log('Smart Home request:', req.body); // Log để debug
  const request = req.body;
  const intent = request.inputs[0].intent;

  if (intent === 'action.devices.SYNC') {
    res.json({
      requestId: request.requestId,
      payload: {
        devices: [{
          id: 'light1',
          type: 'action.devices.types.LIGHT',
          name: { name: 'Đèn học' },
          willReportState: false,
          traits: ['action.devices.traits.OnOff'],
          attributes: { commandOnlyOnOff: true }
        }]
      }
    });
  } else if (intent === 'action.devices.QUERY') {
    try {
      const response = await fetch(FIREBASE_URL, {
        headers: { 'Authorization': `Bearer ${FIREBASE_AUTH_TOKEN}` }
      });
      if (!response.ok) {
        throw new Error(`Firebase query failed: ${response.statusText}`);
      }
      const currentStatus = await response.json();
      // Xử lý trường hợp giá trị không hợp lệ
      const isOn = currentStatus === "1" || currentStatus?.value === "1" || false;
      res.json({
        requestId: request.requestId,
        payload: {
          devices: [{
            id: 'light1',
            status: 'SUCCESS',
            state: { on: isOn }
          }]
        }
      });
    } catch (error) {
      console.error('Error querying Firebase:', error);
      res.status(500).json({
        requestId: request.requestId,
        payload: {
          devices: [{
            id: 'light1',
            status: 'ERROR',
            state: { on: false }
          }]
        }
      });
    }
  } else if (intent === 'action.devices.EXECUTE') {
    const command = request.inputs[0].payload.commands[0].execution[0];
    if (command.command === 'action.devices.commands.OnOff') {
      try {
        const status = command.params.on ? "1" : "0";
        const response = await fetch(FIREBASE_URL, {
          method: 'PATCH', // Sử dụng PATCH thay vì PUT
          body: JSON.stringify({ value: status }), // Cập nhật chỉ trường value
          headers: { 'Authorization': `Bearer ${FIREBASE_AUTH_TOKEN}`, 'Content-Type': 'application/json' }
        });
        if (!response.ok) {
          throw new Error(`Firebase update failed: ${response.statusText}`);
        }
        res.json({
          requestId: request.requestId,
          payload: {
            commands: [{
              ids: ['light1'],
              status: 'SUCCESS',
              states: { on: command.params.on }
            }]
          }
        });
      } catch (error) {
        console.error('Error updating Firebase:', error);
        res.status(500).json({
          requestId: request.requestId,
          payload: {
            commands: [{
              ids: ['light1'],
              status: 'ERROR',
              states: { on: command.params.on }
            }]
          }
        });
      }
    }
  }
});

// Khởi động server
app.listen(3000, () => console.log('Server running on port 3000'));