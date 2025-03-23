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

//Biến lưu thời gian sử dụng đèn và độ sáng trung bình
bool timeStudy = false;//Biến xác định người dùng tắt đèn chưa để gửi thời gian học
unsigned long countTimeStudy = 0;//Biến lưu thời gian học tập của người dùng
int lightBrightness = 0; //Biến lưu cường độ sáng của đèn
unsigned long sumBrightness = 0;  // Tổng độ sáng đã thay đổi
unsigned int countBrightness = 0; // Số lần thay đổi độ sáng
unsigned long totalTimeBrightness = 0; // Tổng thời gian tích lũy cho độ sáng
unsigned long lastBrightnessUpdate = 0; // Lần cuối cập nhật độ sáng


//Biến cho nhấp nháy đèn
bool isBlinking = false; //Đèn có đang nhấp nháy không
int blinkCount = 0; //Đếm số lần nhấp nháy
const int reminderBlinkCount = 5; //Số lần nhấp nháy
const int reminderBlinkDelay = 350; //Thời gian mỗi lần nhấp nháy (ms)
unsigned long lastBlinkTime = 0; //Thời điểm nhấp nháy cuối cùng
bool blinkState = false; //Trạng thái nhấp nháy (bật/tắt)

// Biến chống rung phím
const int debounceDelay = 50;
unsigned long lastDebounceTimePower = 0;
unsigned long lastDebounceTimeColor = 0;

int lastStateButSwitchAuto; //Biến lưu trạng thái (LOW/HIGH) gần nhất của nút tự động sáng
int lastStateButChangeColor; //Biến lưu trạng thái (LOW/HIGH) gần nhất của nút chuyển đổi màu đèn

//Biến lưu giá trị cũ để so sánh
String data_cu = "";
int power_cu = 0;
int lightBrightness_cu = 0;
String data_firebase_cu = "";
String data_firebase_cu_convert ="";

//Set thời gian cập nhật serial
unsigned long lastUpdateTime = 0;

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

    startTime = millis(); // Khởi tạo thời gian bắt đầu học
}


void loop() {
    // Đọc dữ liệu từ Serial
    docDuLieuSerial();
    
    // Xử lý điều khiển nguồn từ biến trở
    int power = constrain(map(analogRead(butPower), 0, 1023, 255, 0), 0, 255);
    
    if (power == 0) {
        isActive = false;
        capNhatThoiGianHoc();
        capNhat();
    }
    else {
        // if (!isActive) { // Khi bật lại đèn, reset thời gian học
            isActive = true;
            timeStudy = false;
            isStudying = true;
            startTime = millis();
        // }

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
    xuLyThoiGianHocNghi(); // Thêm xử lý thời gian học nghỉ 
    dieuKhienDen();
    
    // Giảm tần suất cập nhật để tránh quá tải serial
    if (millis() - lastUpdateTime >= 500) {
        lastUpdateTime = millis();
        capNhat();
    }

    // Không delay cố định để đảm bảo phản hồi nhanh với serial
    delay(50);  // Delay ngắn chỉ để tránh tải CPU quá cao
}



void capNhat() {
    int brightness = autoLight ? constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255) : giaTriSangTuApp;
    String data = "D*" + String(isActive ? 1 : 0) + "*" + String(ledColor ? 1 : 0) + "*" + String(autoLight ? 1 : 0) +  "*" + String(brightness) + "\n";
    String data_firebase_cu_convert = "D*" + data_firebase_cu.substring(0, 1) + "*" + data_firebase_cu.substring(1, 2) + "*" + data_firebase_cu.substring(2, 3) + "*" + data_firebase_cu.substring(3) + "\n";

    if (data != data_cu && data != data_firebase_cu_convert) {
        data_cu = data;
//        Serial.println("Check: " + data_firebase_cu_convert);

//      Serial.print("Gui di: ");
        Serial.println(data);
        Serial.flush(); // Đảm bảo dữ liệu được gửi đi
    }
}

//Cập nhật thời gian học và cường độ sáng trung bình
void capNhatThoiGianHoc(){
    if(timeStudy == false){
        countTimeStudy = millis();

         // Chỉ tính cường độ sáng trung bình khi có thời gian tổng hợp
        if (totalTimeBrightness > 0) {
            lightBrightness = sumBrightness / totalTimeBrightness;
        } else {
            lightBrightness = 0; // Nếu không có dữ liệu, gán về 0
        }
        
        String dataTimeStudy = "T*" + String(countTimeStudy) + "\n";
        String cuongDoSang = "I*" + String(lightBrightness) + "\n";
        
        Serial.println("Cuong do sang: " + lightBrightness);
        Serial.println(dataTimeStudy);
        Serial.println(cuongDoSang);
        Serial.flush(); // Đảm bảo dữ liệu được gửi đi
        timeStudy = true;
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
                isStudying = true;
                startTime = millis();
                data_firebase_cu = data;
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
        if (isBlinking) {
        nhapNhayDen(); // Nhấp nháy đèn khi chuyển trạng thái
        } else {
            int brightness;
            if (autoLight == true) {
                brightness = constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255);
                analogWrite(A4, 255);
            } else {
                brightness = giaTriSangTuApp;
                analogWrite(A4, 0);
            }

            unsigned long currentTime = millis();
        if (brightness != lightBrightness_cu) {
            // Tính thời gian độ sáng trước đó đã tồn tại
            if (lastBrightnessUpdate > 0) {
                unsigned long duration = currentTime - lastBrightnessUpdate;
                sumBrightness += lightBrightness_cu * duration; // Cộng dồn độ sáng theo thời gian
                totalTimeBrightness += duration;
            }

            // Cập nhật lại biến
            lightBrightness_cu = brightness;
            lastBrightnessUpdate = currentTime;
        }
            
            analogWrite(ledWhite, ledColor ? brightness : 0);
            analogWrite(ledYellow, ledColor ? 0 : brightness);
            
        }
    }
    else {
        digitalWrite(ledWhite, LOW);
        digitalWrite(ledYellow, LOW);
    }
}

void xuLyThoiGianHocNghi() {
    if (!isActive) return; //Không xử lý nếu đèn tắt

    unsigned long currentMillis = millis();

    if (isBlinking) {
        if (blinkCount >= reminderBlinkCount * 2) { //Nhấp nháy đủ lần thì chuyển sang nghỉ
            isBlinking = false;
            isStudying = false;
            startTime = currentMillis;
            Serial.println("Da nhap nhay du so lan. Bat dau thoi gian nghi!");
        }
    } else if (isStudying) {
        if (currentMillis - startTime >= studyTime) { //Hết 10 phút học
            isBlinking = true;
            blinkCount = 0;
            lastBlinkTime = currentMillis;
            blinkState = false;
            Serial.println("Da hoc du 10 phut. Den bat dau nhap nhay!");
        }
    } else {
        if (currentMillis - startTime >= breakTime) { //Hết 5 phút nghỉ
            isStudying = true;
            startTime = currentMillis;
            Serial.println("Da nghi du 5 phut. Quay lai che do hoc!");
        }
    }
}

void nhapNhayDen() {
    unsigned long currentMillis = millis();
    if (currentMillis - lastBlinkTime >= reminderBlinkDelay) {
        lastBlinkTime = currentMillis;
        blinkState = !blinkState;
        blinkCount++;

        int brightness = autoLight ? constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255) : giaTriSangTuApp;
        if (blinkState) {
            analogWrite(ledWhite, ledColor ? brightness : 0);
            analogWrite(ledYellow, ledColor ? 0 : brightness);
        } else {
            digitalWrite(ledWhite, LOW);
            digitalWrite(ledYellow, LOW);
        }
    }
}
