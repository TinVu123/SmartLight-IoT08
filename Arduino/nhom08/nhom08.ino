// Định nghĩa các chân cảm biến và LED
const int camBienAnhSang = A1; //Cảm biến ánh sáng ldr
const int butPower = A0; //Nút
const int ledWhite = 9;

const int ledYellow = 10;
const int butChangeColor = 12; //Nút chuyển đổi chế độ chuyển màu đèn
const int switchAuto = 13; //Nút chuyển đổi chế độ tự động sáng

// Biến trạng thái hệ thống
bool isActive = true; //Biến lưu trạng thái hệ thống hoạt động hay tắt
bool ledColor = true; // true - trắng; false - vàng
bool autoLight = false; //Biến lưu chế độ tự động điều chỉnh ánh sáng (bật/tắt)
int giaTriSangTuApp = 0;

bool isStudying = true; //Biến lưu trạng thái học tập
const int studyTime = 10 * 1000; //Biến lưu thời gian học
const int breakTime = 5 * 1000; //Biến lưu thời gian nghỉ
unsigned long startTime = 0;

// Biến chống rung phím
const int debounceDelay = 50;
unsigned long lastDebounceTimePower = 0;
unsigned long lastDebounceTimeColor = 0;

int lastStateButSwitchAuto; //Biến lưu trạng thái (LOW/HIGH) gần nhất của nút tự động sáng
int lastStateButChangeColor; //Biến lưu trạng thái (LOW/HIGH) gần nhất của nút chuyển đổi màu đèn

void setup() {
    pinMode(camBienAnhSang, INPUT);
    pinMode(butPower, INPUT);
    pinMode(switchAuto, INPUT_PULLUP);
    pinMode(butChangeColor, INPUT_PULLUP);

    pinMode(A4, OUTPUT);
    pinMode(ledWhite, OUTPUT);
    pinMode(ledYellow, OUTPUT);
    
    Serial.begin(9600);
    while (!Serial) {
        ; // Đợi kết nối serial được thiết lập
    }

    lastStateButSwitchAuto = digitalRead(switchAuto);
    lastStateButChangeColor = digitalRead(butChangeColor);

    digitalWrite(ledWhite, LOW);
    digitalWrite(ledYellow, LOW);
}

String data_cu = "";
int power_cu = 0;
unsigned long lastUpdateTime = 0;

void loop() {
    // Đọc dữ liệu từ Serial
    docDuLieuSerial();
    
    // Xử lý điều khiển nguồn từ biến trở
    int power = constrain(map(analogRead(butPower), 0, 1023, 255, 0), 0, 255);
    
    if (power == 0) {
        isActive = false;
        capNhat();
    }
    else {
        isActive = true;

        // Nếu tự động sáng tắt thì độ sáng của đèn dựa vào nút nguồn
        if (autoLight == false) {
            if(power != power_cu){
                power_cu = power;
                giaTriSangTuApp = constrain(power, 0, 255);
            }
        }
        capNhat();
    }

    xuLyNutNhan();
    dieuKhienDen();
    
    // Giảm tần suất cập nhật để tránh quá tải serial
    if (millis() - lastUpdateTime >= 1000) {
        lastUpdateTime = millis();
        capNhat();
    }

    // Không delay cố định để đảm bảo phản hồi nhanh với serial
    delay(50);  // Delay ngắn chỉ để tránh tải CPU quá cao
}

void capNhat() {
    int brightness = autoLight ? constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255) : giaTriSangTuApp;
    String data = "D*" + String(isActive ? 1 : 0) + "*" + String(ledColor ? 1 : 0) + "*" + String(autoLight ? 1 : 0) +  "*" + String(brightness) + "\n";
    if (data != data_cu) {
        data_cu = data;
        Serial.print(data);
        Serial.flush(); // Đảm bảo dữ liệu được gửi đi
    }
}

void docDuLieuSerial() {
    // Đọc dữ liệu từ Serial
    while (Serial.available() > 0) {  // Xử lý tất cả dữ liệu có sẵn
        String data = Serial.readStringUntil('\n');
        data.trim();

        if (data.length() >= 4) {
            bool oldIsActive = isActive;
            bool oldLedColor = ledColor;
            bool oldAutoLight = autoLight;
            int oldGiaTriSangTuApp = giaTriSangTuApp;

            // Đảm bảo sự nhất quán về định dạng dữ liệu
            isActive = (data[0] == '1');
            ledColor = (data[1] == '1');
            autoLight = (data[2] == '1');

            if (data.length() > 3) {
                String brightnessStr = data.substring(3);
                brightnessStr.trim();
                if (brightnessStr.length() > 0) {
                    int newBrightness = brightnessStr.toInt();
                    if (newBrightness >= 0 && newBrightness <= 255) {
                        giaTriSangTuApp = newBrightness;
                    }
                }
            }

            // Chỉ cập nhật khi có thay đổi
            if (oldIsActive != isActive || oldLedColor != ledColor || 
                oldAutoLight != autoLight || oldGiaTriSangTuApp != giaTriSangTuApp) {
                Serial.print("Du lieu tu Firebase: ");
                Serial.println(data);
                dieuKhienDen();  // Cập nhật đèn ngay lập tức khi có thay đổi
            }
        }
    }
}

void xuLyNutNhan() {
    // Xử lý nút tự động sáng
    int stateButSwitchAuto = digitalRead(switchAuto); //Lấy trạng thái hiện tại của nút switch

    if (stateButSwitchAuto == LOW && lastStateButSwitchAuto == HIGH && (millis() - lastDebounceTimePower > debounceDelay)) {
        autoLight = !autoLight;
        Serial.print("Tu dong sang: ");
        Serial.println(autoLight ? "ON" : "OFF");
        lastDebounceTimePower = millis();
    }
    lastStateButSwitchAuto = stateButSwitchAuto;

    // Xử lý nút đổi màu
    int stateButChangeColor = digitalRead(butChangeColor); ///Lấy trạng thái hiện tại của nút đổi màu
    if (stateButChangeColor == LOW && lastStateButChangeColor == HIGH && (millis() - lastDebounceTimeColor > debounceDelay)) {
        ledColor = !ledColor;
        Serial.print("Mau den: ");
        Serial.println(ledColor ? "Trang" : "Vang");
        lastDebounceTimeColor = millis();
    }
    lastStateButChangeColor = stateButChangeColor;
}

void dieuKhienDen() {
    // Điều khiển đèn
    if (isActive) {
        int brightness;
        if (autoLight) {
            brightness = constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255);
            analogWrite(A4, 255);
        } else {
            brightness = giaTriSangTuApp;
            analogWrite(A4, 0);
        }

        analogWrite(ledWhite, ledColor ? brightness : 0);
        analogWrite(ledYellow, ledColor ? 0 : brightness);
        
    } else {
        digitalWrite(ledWhite, LOW);
        digitalWrite(ledYellow, LOW);
    }
}
