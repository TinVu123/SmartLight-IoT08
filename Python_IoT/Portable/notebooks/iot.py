import time
from datetime import datetime
import serial #Dùng để giao tiếp với arduino qua cổng COM
from firebase import firebase

# Cấu hình kết nối
FIREBASE_URL = 'https://iot-nhom08-default-rtdb.asia-southeast1.firebasedatabase.app'

#Đường dẫn cho các node trong Firebase
FIREBASE_PATH_LED_CONTROL = "/LED_CONTROL"
FIREBASE_PATH_SAVE_TIME_STUDY = "/TIME_USE"
FIREBASE_PATH_SAVE_LIGHT_INTENSITY = "/LIGHT_INTENSITY"
FIREBASE_PATH_PROMODORO = "/PROMODORO"

#Cấu hình cổng COM và tốc độ truyền dữ liệu (baud rate)
COMPORT = "COM4"
BAUD_RATE = 9600


def main():
    # Khởi tạo kết nối Firebase
    print("Dang ket noi den Firebase...")
    firebase_db = firebase.FirebaseApplication(FIREBASE_URL)
    print(f"Da ket noi den Firebase thanh cong: {FIREBASE_URL}")
    
    # Khởi tạo kết nối Serial
    serial_connection = serial.Serial(COMPORT, BAUD_RATE, timeout=1)
    print(f"Đã kết nối với cổng {COMPORT}")

    #Biến để theo dõi trạng thái
    #Biến "cong_tac" dùng như một "công tắc" để tránh xử lý đồng thời nhiều tác vụ
    cong_tac = 1 # Neu bien nay True thi duoc xu ly
    last_data_from_arduino_convert = ""
    last_led_command_convert =""

    last_led_command = None  #Lưu lệnh led_control gần nhất đã gửi từ firebase về thiết bị
    last_data_from_arduino = None #Lưu dữ liệu gần nhất đã nhận từ arduino
    last_promodoro_command = None #Lưu lệnh promodoro gần nhất
    
    try:
        while True:
            #Đọc dữ liệu từ arduino và gửi lên firebase
            if(cong_tac == 1):
                cong_tac = 0 #Đóng công tắc để tránh xử lý cùng lúc

                #Kiểm tra có dữ liệu từ từ Arduino không
                if serial_connection.in_waiting > 0:
                    #Đọc dữ liệu từ thiết bị và giải mã sang chuỗi UTF-8
                    data_from_arduino = serial_connection.readline().decode('utf-8')

                    # if last_led_command:
                    #     last_led_command_convert = f"D*{last_led_command[0]}*{last_led_command[1]}*{last_led_command[2]}*{last_led_command[3:]}"
                    #     print(last_led_command_convert)
                    #Xử lý dữ liệu điều khiển đèn hợp lệ (bắt đầu bằng "D*")
                    if data_from_arduino.startswith("D*") and data_from_arduino != last_data_from_arduino:
                        last_data_from_arduino = data_from_arduino
                        print('Nhận từ phần cứng: ' + data_from_arduino.strip())
                        
                        #Tách dữ liệu theo dấu *, và lưu vào mảng parts
                        parts = data_from_arduino.split('*')
                        if len(parts) >= 5:
                            #Cập nhật dữ liệu lên Firebase
                            # nutNguon = parts[1]
                            # nutDoiMau = parts[2]
                            # nutTuDongSang = parts[3]
                            # doSangCuaDen = parts[4].strip()
                            
                            # # Gửi dữ liệu lên Firebase
                            # firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'nutNguon', nutNguon)
                            # firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'nutDoiMau', nutDoiMau)
                            # firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'nutTuDongSang', nutTuDongSang)
                            # firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'doSangCuaDen', doSangCuaDen)
                            update_data = {
                                'nutNguon': parts[1],
                                'nutDoiMau': parts[2],
                                'nutTuDongSang': parts[3],
                                'doSangCuaDen': parts[4].strip() #xoá kí tự \n nếu có
                            }
                            firebase_db.put(FIREBASE_PATH_LED_CONTROL, '/', update_data) #Ghi đè toàn bộ node LED_CONTROL
                            print("Đã cập nhật dữ liệu lên Firebase")
                        
                    #Xử lý dữ liệu thời gian học hợp lệ (bắt đầu bằng "T*")
                    if data_from_arduino.startswith("T*"):
                        print('Nhận từ phần cứng: ' + data_from_arduino.strip())
                        #Tách dữ liệu
                        parts = data_from_arduino.split('*')
                        if len(parts) >= 2:
                            #Lấy thời gian học tính bằng mili giây và chuyển đổi sang phút
                            thoiGianHoc = int(parts[1])  #Nếu là số nguyên
                            thoiGianHoc = thoiGianHoc/1000/60
                            print(thoiGianHoc)

                            #Lấy ngày hiện tại để làm key trong Firebase
                            ngay_hien_tai = datetime.today().date()
                            print(ngay_hien_tai)

                            #Lấy dữ liệu thời gian học đã có trên Firebase, nếu không tồn tại thì = None
                            du_lieu_thoi_gian = firebase_db.get(FIREBASE_PATH_SAVE_TIME_STUDY, None)

                            #Lấy giá trị thời gian học của ngày hiện tại, nếu chưa có sẽ tạo là 0
                            time_on_firebase = du_lieu_thoi_gian.get(str(ngay_hien_tai), 0)
                            print("Ngày trên firebase: " + str(time_on_firebase))
                            print("Thời gian học: " + str(thoiGianHoc))
                            time_on_firebase = int(time_on_firebase)

                            # Cộng giá trị mới
                            time_on_firebase += thoiGianHoc
                            time_on_firebase = round(time_on_firebase, 0)
                            print(time_on_firebase)

                            #Cập nhật lại lên Firebase
                            firebase_db.put(FIREBASE_PATH_SAVE_TIME_STUDY, str(ngay_hien_tai), int(time_on_firebase))
                            print("Đã cập nhật dữ liệu lên Firebase")
                    
                    #Xử lý dữ liệu cường độ sáng mà arduino gửi đến (bắt đầu bằng "I*")
                    if data_from_arduino.startswith("I*"):
                        print('Nhận từ phần cứng: ' + data_from_arduino.strip())
                        #Tách dữ liệu
                        parts = data_from_arduino.split('*')
                        if len(parts) >= 2:
                            #Lấy giá trị cường độ sáng
                            cuongDoSang = int(parts[1])  #Nếu là số nguyên

                            if cuongDoSang > 0:
                                print(cuongDoSang)

                                #Lấy ngày hiện tại để dùng làm key trên firebase
                                ngay_hien_tai = datetime.today().date()
                                print(ngay_hien_tai)

                                #Lấy dữ liệu cường độ sáng hiện có trên Firebase, không có thì bằng None
                                du_lieu_do_sang = firebase_db.get(FIREBASE_PATH_SAVE_LIGHT_INTENSITY, None)

                                light_intensity_on_firebase = du_lieu_do_sang.get(str(ngay_hien_tai), 0)
                                print("Độ sáng trên firebase: " + str(light_intensity_on_firebase))
                                print("Cường độ sáng: " + str(cuongDoSang))
                                light_intensity_on_firebase = int(light_intensity_on_firebase)

                                #Cập nhật giá trị cường độ sáng mới
                                light_intensity_on_firebase = cuongDoSang
                                light_intensity_on_firebase = round(light_intensity_on_firebase, 2)
                                print(light_intensity_on_firebase)

                                #Cập nhật dữ liệu cường độ sáng vào Firebase
                                firebase_db.put(FIREBASE_PATH_SAVE_LIGHT_INTENSITY, str(ngay_hien_tai), int(light_intensity_on_firebase))
                                print("Đã cập nhật dữ liệu lên Firebase")
                cong_tac = 1 #Mở công tắc để bên khác tiếp tục xử lý
            
            #Đọc dữ liệu LED_CONTROL từ firebase và gửi xuống thiết bị
            if(cong_tac == 1):
                cong_tac = 0 #Đóng công tắc để tránh xử lý cùng lúc

                #Lấy dữ liệu điều khiển LED từ Firebase
                data_from_firebase = firebase_db.get(FIREBASE_PATH_LED_CONTROL, None) 
                
                if data_from_firebase:
                    #Tạo chuỗi điều khiển đèn dựa trên dữ liệu nhận được từ firebase
                    led_command = (
                        data_from_firebase['nutNguon'] + 
                        data_from_firebase['nutDoiMau'] + 
                        data_from_firebase['nutTuDongSang'] + 
                        data_from_firebase['doSangCuaDen'] + 
                        "\n" #Ký tự xuống dòng để báo hiệu cho arduino biết đã kết thúc lệnh
                    )
                    
                    #Kiểm tra xem lệnh mới có khác với lệnh đã gửi gần nhất không
                    if last_data_from_arduino:
                        # Chuyển thành D*...
                        last_data_from_arduino_convert = last_data_from_arduino.replace("D", "").replace("*", "")
                        #print(last_data_from_arduino_convert)

                    #Chỉ gửi lệnh khi có thay đổi và khác với trạng thái hiện tại của thiết bị.
                    if led_command != last_led_command and led_command != last_data_from_arduino_convert:
                        last_led_command = led_command
                        #print(last_data_from_arduino)
                        print('Gửi đến phần cứng: ' + led_command.strip())
                        serial_connection.write(led_command.encode('utf-8'))
                else:
                    print("Không có dữ liệu từ Firebase")
                                  
                cong_tac = 1 #Mở công tắc để bên khác tiếp tục xử lý

            #Đọc dữ liệu promodo firebase và gửi xuống thiết bị
            if(cong_tac == 1):
                cong_tac = 0 #Đóng công tắc để tránh xử lý cùng lúc

                #Lấy dữ liệu Promodoro từ Firebase
                promodoro_from_firebase = firebase_db.get(FIREBASE_PATH_PROMODORO, None) 
                
                if promodoro_from_firebase:
                    #Tạo chuỗi điều khiển đèn theo định dạng: "P*stateProdomoro*thoiGianHoc*thoiGianNghi\n"
                    promodoro_command = (
                        "P*" +
                        promodoro_from_firebase['state'] +
                        "*" +
                        promodoro_from_firebase['thoiGianLam'] +
                        "*" +
                        promodoro_from_firebase['thoiGianNghi'] +
                        "\n"
                    )
                    #Chỉ gửi lệnh nếu lệnh mới khác với lệnh đã gửi trước đó
                    if promodoro_command != last_promodoro_command:
                        last_promodoro_command = promodoro_command
                        print(promodoro_command);
                        serial_connection.write(promodoro_command.encode('utf-8'))
                else:
                    print("Không có dữ liệu từ Firebase")
                                  
                cong_tac = 1 #Mở công tắc để bên khác tiếp tục xử lý
                
                time.sleep(0.1) #Tạm dừng để giảm tải, tránh vòng lặp quá nhanh
    
    except KeyboardInterrupt: #Xử lý khi người dùng dừng chương trình (Ctrl+C)
        print("Chương trình đã dừng bởi người dùng.")
    #Bắt chi tiết các lỗi nếu có
    # except Exception as e:
    #     print(f"Lỗi: {e}")
    finally:
        #Đảm bảo đóng kết nối Serial khi kết thúc
        if serial_connection.is_open:
            serial_connection.close()
            print("Đã đóng kết nối Serial")

#Chạy chương trình
if __name__ == "__main__":
    main()