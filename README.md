
# Hướng Dẫn Sử Dụng Dự Án 🚀

  

Dự án này mô phỏng hệ thống đèn thông minh giao tiếp giữa Arduino, Proteus và Firebase thông qua Script Python.

  

---

  

## 1. Cấu Trúc Thư Mục 📂

  

- **🛠 Arduino**

Chứa code Arduino IDE và file `.hex` đã được biên dịch sẵn để nạp vào Arduino Uno R3 trong mô phỏng Proteus.

  

- **🔌 Proteus/Nhom08**

Chứa mạch mô phỏng của dự án.

  

- **🐍 Python_IoT**

Chứa code Python dùng để giao tiếp giữa mạch mô phỏng và Firebase.

- **📱 Flutter**

Chứa file APK đã biên dịch sẵn từ source code Flutter.

- **🌐 NodeJs**

Chứa code NodeJs dùng để chạy máy chủ xử lý thông báo và ra lệnh bằng Google Assistant.

  

---

  

## 2. Thiết Lập Ban Đầu ⚙️

  

1. **📥 Cài đặt `vspd.exe`**

Sử dụng phần mềm này để thiết lập liên kết ảo giữa các cổng COM.

2. **🔗 Tạo kết nối COM ảo**

Sau khi cài đặt, chọn Pair COM1 với COM4 để tạo kết nối ảo giữa hai cổng.

  

---

  

## 3. Chạy Ứng Dụng Python 🐍

Thư mục Python_IoT cung cấp 2 lựa chọn:

  

### Cách 1: Dùng Môi Trường Python Portable 💻

  

- Trong **Python_IoT/Portable**, chạy **WinPython Command Prompt.exe** hoặc **WinPython Powershell Prompt.exe**.

- Nhập lệnh:

  

```bash

python iot.py

```

  

### Cách 2: Tự Cài Đặt Python ⚡

  

- **Folder Python** chứa mã nguồn gốc (.py).

- Thực hiện các bước sau:

1. Cài đặt Python trên máy tính của bạn.

2. Cài đặt các thư viện cần thiết với lệnh:

```bash

pip install -r requirenments.txt

```

3. Chạy ứng dụng bằng lệnh:

```bash

python iot.py

```

---

  

## 4. Mô Phỏng Trên Proteus 🔬

  

- Mở file mô phỏng nằm trong thư mục **Proteus/Nhom08** để chạy mô phỏng mạch điện.

  

---

  

## 5. Nạp Chương Trình Arduino 🔄

  

- Sử dụng file `.hex` trong thư mục **Arduino** để nạp trực tiếp vào Uno R3 trong mô phỏng Proteus, hoặc sử dụng mã nguồn trong Arduino IDE để biên dịch và nạp chương trình.

  

---

  

## 6. Chạy Code NodeJs 🚀

  

1. Cài sẵn **NodeJs**.

2. Giải nén **Nodejs_Sever_Notification.zip** và **gg_assistant.zip**.

3. Mở CMD tại thư mục **Nodejs_Sever_Notification**:

```bash

node sever_notifi.js

```

  

4. Mở CMD tại thư mục **gg_assistant**:

```bash

node sever.js

```

  

---

  

## 7. Cài Đặt App SmartLight 📲

  

- Trong **Flutter**, tìm file APK và cài đặt lên điện thoại.

- Mở app và cấp quyền thông báo (nếu được hỏi).

  

---

  

## 8. Tóm Tắt ✅

  

- **🛠 Arduino**: Code Arduino IDE và file `.hex` đã biên dịch sẵn có thể nạp vào mạch mô phỏng.

- **🔌 Proteus/Nhom08**: Mạch mô phỏng của dự án.

- **🐍 Python_IoT**: Code Python dùng để giao tiếp giữa mạch mô phỏng và Firebase.

- **🔗 vspd.exe**: Phần mềm để thiết lập liên kết ảo giữa các cổng COM (Pair COM1 với COM4).

- 🐍 Trong **Python_IoT** có 2 lựa chọn:

- **Portable**: Môi trường Python đã được thiết lập sẵn, chỉ cần chạy file `WinPython Command Prompt.exe` hoặc `WinPython Powershell Prompt.exe` và nhập lệnh `python iot.py`.

- **Python**: Mã nguồn gốc (.py) cần tự cài đặt môi trường Python và các thư viện với `pip install -r requirenments.txt` trước khi chạy với `python iot.py`.

- **🌐 NodeJs**: Chạy `node sever_notifi.js` và `node sever.js`.

- **📱 Flutter**: Cài app APK và cấp quyền thông báo.