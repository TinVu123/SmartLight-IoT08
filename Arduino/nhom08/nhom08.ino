//Định nghĩa các chân cảm biến và LED
const int camBienAnhSang = A1; //Cảm biến ánh sáng ldr
const int butPower = A0; //Nút điều chỉnh nguồn (biến trở)
const int butChangeColor = 12; //Nút chuyển đổi chế độ chuyển màu đèn
const int switchAuto = 13; //Nút chuyển đổi chế độ tự động sáng

const int ledWhite = 9;
const int ledYellow = 10;

//Biến trạng thái hệ thống
bool isActive = true; //Biến lưu trạng thái hệ thống hoạt động hay tắt
bool ledColor = true; // true - trắng; false - vàng
bool autoLight = false; //Biến lưu chế độ tự động điều chỉnh ánh sáng (bật/tắt)
int giaTriSangTuApp = 0;

//Biến hẹn giờ học tập
bool statePromodoro = true;
bool isStudying = true; //Biến lưu trạng thái học tập (học tập hoặc nghỉ ngơi)
int studyTime = 25 * 1000 *60; //Biến lưu thời gian học, mặc định 25 phút
int breakTime = 5 * 1000 *60; //Biến lưu thời gian nghỉ, mặc định 5 phút
unsigned long startTime = 0;

//Biến lưu thời gian sử dụng đèn và độ sáng trung bình
bool timeStudy = false;//Biến xác định người dùng tắt đèn chưa để gửi thời gian học
unsigned long countTimeStudy = 0;//Biến lưu thời gian học tập của người dùng

int lightBrightness = 0; //Biến lưu cường độ sáng của đèn
unsigned long sumBrightness = 0;  //Tổng độ sáng đã thay đổi
unsigned long totalTimeBrightness = 0; //Tổng thời gian tích lũy cho độ sáng
unsigned long lastBrightnessUpdate = 0; //Lần cuối cập nhật độ sáng


//Biến cho nhấp nháy đèn
bool isBlinking = false; //Đèn có đang nhấp nháy không
int blinkCount = 0; //Đếm số lần nhấp nháy
const int reminderBlinkCount = 5; //Số lần nhấp nháy
const int reminderBlinkDelay = 350; //Thời gian mỗi lần nhấp nháy (ms)
unsigned long lastBlinkTime = 0; //Thời điểm nhấp nháy cuối cùng
bool blinkState = false; //Trạng thái nhấp nháy (bật/tắt)

//Biến chống rung phím
//Tín hiệu có thể bị nhiễu (do bật tắt liên tục), cần đợi một khoảng thời gian trước khi xác nhận nút đã được nhấn
const int debounceDelay = 50;
unsigned long lastDebounceTimePower = 0;
unsigned long lastDebounceTimeColor = 0;

//Theo dõi trạng thái nút
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
    //Chân input
    pinMode(camBienAnhSang, INPUT);
    pinMode(butPower, INPUT);
    pinMode(switchAuto, INPUT_PULLUP);
    pinMode(butChangeColor, INPUT_PULLUP);

    //Chân output
    pinMode(A4, OUTPUT); //Chân đèn thể hiện chế độ tự động sáng (tự động sáng bật thì chân A4 sáng, tắt thì chân A4 không sáng)
    pinMode(ledWhite, OUTPUT);
    pinMode(ledYellow, OUTPUT);
    
    Serial.begin(9600);
    while (!Serial) {
        ; // Đợi kết nối serial được thiết lập
    }

    //Lấy trạng thái nút ban đầu
    lastStateButSwitchAuto = digitalRead(switchAuto);
    lastStateButChangeColor = digitalRead(butChangeColor);

    //Tắt hết đèn
    digitalWrite(ledWhite, LOW);
    digitalWrite(ledYellow, LOW);

    startTime = millis(); //Khởi tạo thời gian bắt đầu học
}


void loop() {
    //Đọc dữ liệu từ Serial
    docDuLieuSerial();
    
    //Xử lý điều khiển nguồn từ biến trở
    int power = constrain(map(analogRead(butPower), 0, 1023, 255, 0), 0, 255);

    //Xử lý thay đổi trạng thái nguồn
    if (power == 0) {
        isActive = false;
        capNhatThongKeHocTap();
        capNhatDuLieuSerial();
    } else {
        if (power != power_cu) { //Phát hiện nút nguồn được vặn
            isActive = true;
            timeStudy = false; //biến lưu trạng thái để gửi dữ liệu thời gian học đi
            isStudying = true; //biến lưu trạng thái học để nhấp nháy đèn
            startTime = millis();
        }
        if (autoLight == false) { //Nếu tự động sáng tắt thì độ sáng của đèn bằng giá trị biến trở
            if (power != power_cu) {
                power_cu = power;
                giaTriSangTuApp = constrain(power, 0, 255);
            }
        }
        capNhatDuLieuSerial();
    }
    power_cu = power;

    xuLyNutNhan(); //Xử lý nút tự động sáng và đổi màu đèn
    xuLyThoiGianHocNghi(); //Xử lý thời gian học nghỉ 
    dieuKhienDen();
    
    //Giảm tần suất cập nhật để tránh quá tải serial
    if (millis() - lastUpdateTime >= 50) {
        lastUpdateTime = millis();
        capNhatDuLieuSerial();
    }
}

void capNhatDuLieuSerial() {
    //Lấy độ sáng hiện tại dựa trên chế độ tự động sáng
    int brightness = autoLight ? constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255) : giaTriSangTuApp;

    //Định dạng chuỗi dữ liệu trước khi gửi đi (thêm D vào đầu, ngăn cách dữ liệu các nút bởi dấu *)
    String data = "D*" + String(isActive ? 1 : 0) + "*" + String(ledColor ? 1 : 0) + "*" + String(autoLight ? 1 : 0) +  "*" + String(brightness) + "\n";
    //Định dạng chuỗi dữ liệu firebase để so sánh
    data_firebase_cu_convert = "D*" + data_firebase_cu.substring(0, 1) + "*" + data_firebase_cu.substring(1, 2) + "*" + data_firebase_cu.substring(2, 3) + "*" + data_firebase_cu.substring(3) + "\n";

    //Chỉ gửi đi nếu dữ liệu thay đổi
    if (data != data_cu && data != data_firebase_cu_convert) {
        data_cu = data;
        //Serial.println("Check: " + data_firebase_cu_convert);
        //Serial.print("Gui di: ");
        Serial.println(data);
        //Serial.flush(); // Đảm bảo dữ liệu được gửi đi
    }
}

//Cập nhật thời gian học và cường độ sáng trung bình
void capNhatThongKeHocTap(){
    //Nếu kết thúc thời gian học
    if(timeStudy == false){
        //Tính toán tổng thời gian đã học
        //countTimeStudy = millis() - startTime;
        countTimeStudy = millis();

        //Tính độ sáng trung bình nếu có dữ liệu
        if (totalTimeBrightness > 0) {
            lightBrightness = sumBrightness / totalTimeBrightness;
        } else {
            lightBrightness = 0; //Nếu không có dữ liệu, gán về 0
        }
        
        String dataTimeStudy = "T*" + String(countTimeStudy) + "\n"; //Dữ liệu thời gian học bắt đầu bằng T
        String cuongDoSang = "I*" + String(lightBrightness) + "\n"; //Dữ liệu cường độ sáng bắt đầu bằng I
        
        Serial.println("Cuong do sang: " + lightBrightness);
        //Gửi thống kê qua serial
        Serial.println(dataTimeStudy);
        Serial.println(cuongDoSang);
        //Serial.flush(); // Đảm bảo dữ liệu được gửi đi
        timeStudy = true; //Gán lại thời gian học = true

        countTimeStudy = 0; //Reset thời gian đếm
        sumBrightness = 0;  //Reset tổng độ sáng
        totalTimeBrightness = 0; //Reset tổng thời gian
        lastBrightnessUpdate = 0; //Reset thời điểm cập nhật cuối
        lightBrightness_cu = 0; //Reset độ sáng cũ
    }
}


void docDuLieuSerial() {
    //Đọc dữ liệu từ Serial
    while (Serial.available() > 0) {  // Xử lý tất cả dữ liệu có sẵn
        String data = Serial.readStringUntil('\n'); //đọc dữ liệu từ cổng Serial cho đến khi gặp ký tự xuống dòng '\n'
        data.trim(); //loại bỏ khoảng trắng 2 đầu
        
        //Esp sẽ gửi dự liệu  đến arduino dạng thứ tự. VD: 111154 lần lượt là:
        //1:nút nguồn true
        //1:nút đổi màu true
        //1: nút tự động sáng true
        //154: độ sáng của đèn
    
        //Chuỗi có 4 kí tự trở lên và không phải chuỗi dữ liệu promodoro
        if (data.length() >= 4 && data[0] != 'P') {
            //Lưu trạng thái cũ của các biến điều khiển
            bool oldIsActive = isActive;
            bool oldLedColor = ledColor;
            bool oldAutoLight = autoLight;
            int oldGiaTriSangTuApp = giaTriSangTuApp;

            isActive = (data[0] == '1'); //Nếu kí tự đầu (nguồn) = 1 thì gán isActive = true
            ledColor = (data[1] == '1');
            autoLight = (data[2] == '1');

            if (data.length() > 3) {
                String brightnessStr = data.substring(3); //Lấy từ kí tự thứ 3 chứa giá trị độ sáng của đèn
                brightnessStr.trim();
                if (brightnessStr.length() > 0) {
                    int newBrightness = brightnessStr.toInt(); //Chuyển đổi String về int
                    if (newBrightness >= 0 && newBrightness <= 255) {
                        giaTriSangTuApp = newBrightness;
                    }
                }
            }

            //Nếu trạng thái vừa chuyển từ BẬT (true) sang TẮT (false) do lệnh Firebase
            if (oldIsActive == true && isActive == false) {
                capNhatThongKeHocTap(); //Gọi cập nhật thời gian học và cường độ sáng
            }

            //Chỉ cập nhật khi có thay đổi
            if (oldIsActive != isActive || oldLedColor != ledColor || 
                oldAutoLight != autoLight || oldGiaTriSangTuApp != giaTriSangTuApp) {
                if (isActive) { //Chỉ reset nếu đèn BẬT (hoặc vừa được bật)
                    isStudying = true;
                    startTime = millis();
                    timeStudy = false; //biến lưu trạng thái để gửi dữ liệu thời gian học đi
                 }
                
                data_firebase_cu = data;
                //In dữ liệu lên Serial
                Serial.print("Du lieu tu Firebase: ");
                Serial.println(data);
                dieuKhienDen();  //Cập nhật đèn ngay lập tức
            }
        }

        //Xử lý chuỗi Pomodoro (P*statePromodoro*thoiGianHoc*thoiGianNghi)
        else if (data.startsWith("P*")) {
            int firstStar = data.indexOf('*'); //Vị trí của dấu * đầu tiên
            int secondStar = data.indexOf('*', firstStar + 1); //Vị trí của dấu * thứ 2, bắt đầu tìm từ vị trí dấu * đầu tiên
            int thirdStar = data.indexOf('*', secondStar + 1); //Vị trí của dấu * thứ 3, bắt đầu tìm từ vị trí dấu * thuws 2

            if (thirdStar != -1) { // Đảm bảo chuỗi có đủ 3 dấu '*'
                String stateStr = data.substring(firstStar + 1, secondStar); //Lấy chuỗi nằm giữa dấu * thứ nhất và thứ hai (statePromodoro)
                String studyStr = data.substring(secondStar + 1, thirdStar); //Lấy chuỗi nằm giữa dấu * thứ hai và thứ ba (studyTime)
                String breakStr = data.substring(thirdStar + 1); //Lấy chuỗi nằm giữa dấu * thứ ba đến hết (breakTime)

                //Lưu lại giá trị hiện tại
                bool oldStatePromodoro = statePromodoro;
                int oldStudyTime = studyTime;
                int oldBreakTime = breakTime;

                //So sánh dữ liệu hiện tại với dữ liệu mới, nếu khác thì cập nhật
                //if (oldStatePromodoro != (stateStr == "1") || oldStudyTime != studyStr.toInt() * 1000 || 
                //oldBreakTime != breakStr.toInt() * 1000) {

                  //Chuyển đổi và cập nhật giá trị
                  statePromodoro = (stateStr == "1");
                  studyTime = studyStr.toInt() * 1000; //Chuyển giây thành giây
                  breakTime = breakStr.toInt() * 1000; //Chuyển giây thành giây
  
                  //Reset trạng thái Pomodoro khi nhận dữ liệu mới
                  if (statePromodoro) {
                      isStudying = true; //đang học bằng true
                      startTime = millis(); //thời gian bắt đầu học bằng thời điểm hiện tại
                      isBlinking = false; //nhấp nháy đèn bằng false
                      blinkCount = 0; //số lần nhấp nháy đèn =0
                  }
  
                  //In ra màn hình để kiểm tra
                  Serial.print("Pomodoro: ");
                  Serial.print(statePromodoro ? "ON" : "OFF");
                  Serial.print(" | Study: ");
                  Serial.print(studyTime / 1000);
                  Serial.print("s | Break: ");
                  Serial.print(breakTime / 1000);
                  Serial.println("s");
                //}
            }
        }
        
    }
}

void xuLyNutNhan() {
    //Xử lý nút tự động sáng
    int stateButSwitchAuto = digitalRead(switchAuto); //Lấy trạng thái hiện tại của nút tự động sáng
    if (stateButSwitchAuto == LOW && lastStateButSwitchAuto == HIGH && (millis() - lastDebounceTimePower > debounceDelay)) {
        autoLight = !autoLight;
        Serial.print("Tu dong sang: ");
        Serial.println(autoLight ? "ON" : "OFF");
        lastDebounceTimePower = millis();
    }
    lastStateButSwitchAuto = stateButSwitchAuto;

    //Xử lý nút đổi màu
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
    //Điều khiển đèn
    if (isActive) {
        //Nếu đèn đang nhấp nháy thì không xử lý lệnh điều khiển
        if (isBlinking) {
        nhapNhayDen(); //Nhấp nháy đèn khi chuyển trạng thái
        } 
        else {
            int brightness;
            //Nếu tự động sáng = true thì lấy giá trị độ sáng của cảm biến ldr, giới hạn trong khoảng từ 0-255
            if (autoLight == true) {
                brightness = constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255);
                analogWrite(A4, 255);
            } else {
                brightness = giaTriSangTuApp;
                analogWrite(A4, 0);
            }

            //Nếu ledColor == true, LED trắng sáng với độ sáng brightness, LED vàng tắt
            //Nếu ledColor == false, LED vàng sáng, LED trắng tắt
            analogWrite(ledWhite, ledColor ? brightness : 0);
            analogWrite(ledYellow, ledColor ? 0 : brightness);

            unsigned long currentTime = millis(); //lấy thời điểm hiện tại
            //Nếu độ sáng thay đổi so với giá trị cũ
            if (brightness != lightBrightness_cu) {
                // Tính thời gian độ sáng trước đó đã tồn tại
                if (lastBrightnessUpdate > 0) {
                    unsigned long duration = currentTime - lastBrightnessUpdate; //Tính thời gian độ sáng trước đã duy trì
                    sumBrightness += lightBrightness_cu * duration; //Cộng dồn tổng độ sáng theo thời gian
                    totalTimeBrightness += duration; //Cộng dồn tổng thời gian sáng đèn
                }
                //VD: Đèn sáng ở mức 200 trong 5s, thì sumBrightness += 200*5, totalTimeBrightness += 5
                //Khi đèn tắt thì tính cường độ sáng trung bình của đèn = sumBrightness/totalTimeBrightness

                // Cập nhật lại biến
                lightBrightness_cu = brightness; //Lưu lại giá trị độ sáng mới 
                lastBrightnessUpdate = currentTime; //Lưu thời gian thay đổi
            }            
        }
    }
    //Nếu đèn không hoạt động (isActive == false), cả LED trắng và vàng đều tắt
    else {
        digitalWrite(ledWhite, LOW);
        digitalWrite(ledYellow, LOW);
    }
}

//Khi học xong -> Nhấp nháy đèn báo hiệu
//Khi nhấp nháy xong -> Bắt đầu nghỉ
//Khi nghỉ xong -> Quay lại học
void xuLyThoiGianHocNghi() {
    if (!isActive || statePromodoro == false) return; //Không xử lý nếu đèn tắt hoặc statePromodoro = false

    unsigned long currentTime = millis(); //Lấy thời gian hiện tại

    //Nếu đèn đang nhấp nháy
    if (isBlinking) {
        if (blinkCount >= reminderBlinkCount * 2) { //Nhấp nháy đủ lần thì chuyển sang nghỉ
            isBlinking = false;
            isStudying = false;
            startTime = currentTime; //Lưu thời điểm bắt đầu nghỉ
            Serial.println("Bat dau thoi gian nghi!");
        }
    } 
    //Nếu đang trong thời gian học
    else if (isStudying) {
        //Nếu đã học đủ thời gian quy định (studyTime), bắt đầu nhấp nháy đèn báo hiệu hết giờ
        if (currentTime - startTime >= studyTime) {
            isBlinking = true;
            blinkCount = 0;
            lastBlinkTime = currentTime; //Lưu thời điểm bắt đầu nhấp nháy
            blinkState = false; //Tắt trạng thái nhấp nháy
            Serial.println("Da hoc du " + String(studyTime/1000)+ " phut. Den bat dau nhap nhay!");
        }
    //Nếu đang trong thời gian nghỉ
    } else {
        //Nếu đã nghỉ đủ thời gian nghỉ quy định (breakTime), quay lại chế độ học
        if (currentTime - startTime >= breakTime) {
            isStudying = true;
            startTime = currentTime; //Lưu thời gian bắt đầu học
            Serial.println("Da nghi du " + String(breakTime/1000) + " phut. Quay lai che do hoc!");
        }        
    }
}

void nhapNhayDen() {
    unsigned long currentTime = millis(); //Lấy thời gian hiện tại

    //Kiểm tra nếu đã đến lúc nhấp nháy
    if (currentTime - lastBlinkTime >= reminderBlinkDelay) {
        lastBlinkTime = currentTime; //Cập nhật thời điểm nhấp nháy
        blinkState = !blinkState; //Đảo trạng thái nhấp nháy
        blinkCount++; //Tăng số lần nhấp nháy

        //Lưu độ sáng của đèn hiện tại, (autoLight hoặc độ sáng tự chỉnh)
        int brightness = autoLight ? constrain(map(analogRead(camBienAnhSang), 0, 1023, 255, 0), 0, 255) : giaTriSangTuApp;
        
        //Nếu trạng thái nhấp nháy bật
        if (blinkState) {
            analogWrite(ledWhite, ledColor ? brightness : 0);
            analogWrite(ledYellow, ledColor ? 0 : brightness);
        } else { //Tắt cả hai đèn
            digitalWrite(ledWhite, LOW);
            digitalWrite(ledYellow, LOW);
        }
    }
}
