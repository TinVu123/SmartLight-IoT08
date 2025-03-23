from PyQt5 import QtWidgets, uic, QtCore
import sys
import serial
import time
from datetime import datetime
from firebase import firebase

# Cấu hình kết nối
FIREBASE_URL = 'https://iot-nhom08-default-rtdb.asia-southeast1.firebasedatabase.app'
FIREBASE_PATH_LED_CONTROL = "/LED_CONTROL"
FIREBASE_PATH_SAVE_TIME_STUDY = "/TIME_USE"
FIREBASE_PATH_SAVE_LIGHT_INTENSITY = "/LIGHT_INTENSITY"

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
    cong_tac = 1 # Neu bien nay True thi duoc xu ly
    last_data_from_arduino_convert = ""
    last_led_command_convert =""

    last_led_command = None  #Lưu lệnh gần nhất đã gửi từ firebase về thiết bị
    last_data_from_arduino = None #Lưu dữ liệu gần nhất đã nhận từ arduino
    
    try:
        # print(cong_tac)
        while True:
            # time.sleep(0.5)
            
            #Đọc dữ liệu từ arduino và gửi lên firebase
            if(cong_tac == 1):
                cong_tac = 0 #Đóng công tắc để tránh xử lý cùng lúc

                #Kiểm tra có dữ liệu từ thiết bị phần cứng không
                if serial_connection.in_waiting > 0:
                    #Đọc dữ liệu từ thiết bị
                    data_from_arduino = serial_connection.readline().decode('utf-8')

                    # if last_led_command:
                    #     last_led_command_convert = f"D*{last_led_command[0]}*{last_led_command[1]}*{last_led_command[2]}*{last_led_command[3:]}"
                    #     print(last_led_command_convert)

                    #Xử lý dữ liệu điều khiển đèn hợp lệ (bắt đầu bằng "D*")
                    if data_from_arduino.startswith("D*") and data_from_arduino != last_data_from_arduino:
                        last_data_from_arduino = data_from_arduino
                        print('Nhận từ phần cứng: ' + data_from_arduino.strip())
                        
                        #Tách dữ liệu
                        parts = data_from_arduino.split('*')
                        if len(parts) >= 5:
                            #Cập nhật dữ liệu lên Firebase
                            nutNguon = parts[1]
                            nutDoiMau = parts[2]
                            nutTuDongSang = parts[3]
                            doSangCuaDen = parts[4].strip()
                            
                            # Gửi dữ liệu lên Firebase
                            firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'nutNguon', nutNguon)
                            firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'nutDoiMau', nutDoiMau)
                            firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'nutTuDongSang', nutTuDongSang)
                            firebase_db.put(FIREBASE_PATH_LED_CONTROL, 'doSangCuaDen', doSangCuaDen)
                            # serial_connection.reset_input_buffer()  # Xóa dữ liệu đầu vào
                            print("Đã cập nhật dữ liệu lên Firebase")
                        
                    #Xử lý dữ liệu thời gian học hợp lệ (bắt đầu bằng "T*")
                    if data_from_arduino.startswith("T*"):
                        print('Nhận từ phần cứng: ' + data_from_arduino.strip())
                        #Tách dữ liệu
                        parts = data_from_arduino.split('*')
                        if len(parts) >= 2:
                            #Cập nhật dữ liệu lên Firebase
                            thoiGianHoc = int(parts[1])  # Nếu là số nguyên
                            thoiGianHoc = thoiGianHoc/1000/60
                            # thoiGianHoc = float(parts[1])  # Nếu có số thập phân

                            print(thoiGianHoc)

                            ngay_hien_tai = datetime.today().date()
                            print(ngay_hien_tai)

                            du_lieu_thoi_gian = firebase_db.get(FIREBASE_PATH_SAVE_TIME_STUDY, None)

                            # Đọc dữ liệu từ Firebase, đảm bảo là số
                            time_on_firebase = du_lieu_thoi_gian.get(str(ngay_hien_tai), 0)
                            print("Ngày trên firebase: " + str(time_on_firebase))
                            print("Thời gian học: " + str(thoiGianHoc))
                            time_on_firebase = int(time_on_firebase)

                            # Cộng giá trị mới
                            time_on_firebase += thoiGianHoc
                            time_on_firebase = round(time_on_firebase, 0)
                            print(time_on_firebase)

                            # Cập nhật lại Firebase
                            firebase_db.put(FIREBASE_PATH_SAVE_TIME_STUDY, str(ngay_hien_tai), int(time_on_firebase))
                            print("Đã cập nhật dữ liệu lên Firebase")
                    
                    #Xử lý dữ liệu cường độ sáng mà arduino gửi đến (bắt đầu bằng "I*")
                    if data_from_arduino.startswith("I*"):
                        print('Nhận từ phần cứng: ' + data_from_arduino.strip())
                        #Tách dữ liệu
                        parts = data_from_arduino.split('*')
                        if len(parts) >= 2:
                            #Cập nhật dữ liệu lên Firebase
                            cuongDoSang = int(parts[1])  # Nếu là số nguyên
                            # cuongDoSang = float(parts[1])  # Nếu có số thập phân

                            print(cuongDoSang)

                            ngay_hien_tai = datetime.today().date()
                            print(ngay_hien_tai)

                            du_lieu_do_sang = firebase_db.get(FIREBASE_PATH_SAVE_LIGHT_INTENSITY, None)

                            # Đọc dữ liệu từ Firebase, đảm bảo là số
                            light_intensity_on_firebase = du_lieu_do_sang.get(str(ngay_hien_tai), 0)
                            print("Độ sáng trên firebase: " + str(light_intensity_on_firebase))
                            print("Cường độ sáng: " + str(cuongDoSang))
                            light_intensity_on_firebase = int(light_intensity_on_firebase)

                            # Cộng giá trị mới
                            light_intensity_on_firebase = cuongDoSang
                            light_intensity_on_firebase = round(light_intensity_on_firebase, 2)
                            print(light_intensity_on_firebase)

                            # Cập nhật lại Firebase
                            firebase_db.put(FIREBASE_PATH_SAVE_LIGHT_INTENSITY, str(ngay_hien_tai), int(light_intensity_on_firebase))
                            print("Đã cập nhật dữ liệu lên Firebase")
                # time.sleep(0.5)
                cong_tac = 1 #Mở công tắc để bên khác tiếp tục xử lý
            
            #Đọc dữ liệu từ firebase và gửi xuống thiết bị
            if(cong_tac == 1):
                cong_tac = 0 #Đóng công tắc để tránh xử lý cùng lúc

                data_from_firebase = firebase_db.get(FIREBASE_PATH_LED_CONTROL, None) 
                
                if data_from_firebase:
                    #Tạo chuỗi điều khiển đèn
                    led_command = (
                        data_from_firebase['nutNguon'] + 
                        data_from_firebase['nutDoiMau'] + 
                        data_from_firebase['nutTuDongSang'] + 
                        data_from_firebase['doSangCuaDen'] + 
                        "\n"
                    )
                    
                    #Kiểm tra xem lệnh mới có khác với lệnh đã gửi gần nhất không
                    if last_data_from_arduino:
                        # Chuyển thành D*...
                        last_data_from_arduino_convert = last_data_from_arduino.replace("D", "").replace("*", "")
                        #print(last_data_from_arduino_convert)

                    #Chỉ gửi lệnh khi có thay đổi và khác với trạng thái hiện tại của thiết bị.
                    if led_command != last_led_command and led_command != last_data_from_arduino_convert:
                        last_led_command = led_command
                        print(last_data_from_arduino)
                        print('Gửi đến phần cứng: ' + led_command.strip())
                        # serial_connection.reset_output_buffer() # Xóa dữ liệu đầu ra
                        serial_connection.write(led_command.encode('utf-8'))
                else:
                    print("Không có dữ liệu từ Firebase")
                                  
                cong_tac = 1 #Mở công tắc để bên khác tiếp tục xử lý
                # Tạm dừng để không sử dụng quá nhiều CPU
                # time.sleep(0.5)

            
    except KeyboardInterrupt:
        print("Chương trình đã dừng bởi người dùng.")
    except Exception as e:
        print(f"Lỗi: {e}")
    finally:
        # Đảm bảo đóng kết nối Serial khi kết thúc
        if serial_connection.is_open:
            serial_connection.close()
            print("Đã đóng kết nối Serial")

# Chạy chương trình
if __name__ == "__main__":
    main()