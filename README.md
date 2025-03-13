# Hướng Dẫn Sử Dụng Dự Án

Dự án này bao gồm các thành phần chính cho mô phỏng đèn thông minh giao tiếp giữa Arduino, Proteus và Firebase thông qua Python.

---

## Cấu Trúc Thư Mục

- **Arduino**  
  Chứa code Arduino IDE và file `.hex` đã được biên dịch sẵn để nạp vào Arduino Uno R3 trong mô phỏng Proteus.

- **Proteus/Nhom08**  
  Chứa mạch mô phỏng của dự án.

- **Python_IoT**  
  Chứa code Python dùng để giao tiếp giữa mạch mô phỏng và Firebase.

---

## Thiết Lập Ban Đầu

1. **Cài đặt phần mềm `vspd.exe`**  
   Sử dụng phần mềm này để thiết lập liên kết ảo giữa các cổng COM.  
2. **Thiết lập kết nối ảo**  
   Sau khi cài đặt, chọn **Pair COM1** với **COM4** để tạo kết nối ảo giữa hai cổng.

---

## Chạy Ứng Dụng Python

Thư mục **Python_IoT** cung cấp 2 lựa chọn:

### 1. Sử dụng Môi Trường Python Có Sẵn

- **Folder Portable** chứa môi trường Python đã được thiết lập sẵn.
- Thực hiện các bước sau:
  1. Chạy file **WinPython Command Prompt.exe** hoặc **WinPython Powershell Prompt.exe**.
  2. Trong cửa sổ lệnh, nhập:
  
     ```bash
     python iot.py
     ```

### 2. Sử dụng Môi Trường Python Riêng

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

## Mô Phỏng Trên Proteus

- Mở file mô phỏng nằm trong thư mục **Proteus/Nhom08** để chạy mô phỏng mạch điện.

---

## Nạp Chương Trình Vào Arduino

- Sử dụng file `.hex` trong thư mục **Arduino** để nạp trực tiếp vào Uno R3 trong mô phỏng Proteus, hoặc sử dụng mã nguồn trong Arduino IDE để biên dịch và nạp chương trình.

---

## Tóm Tắt

- **Arduino**: Code Arduino IDE và file `.hex` đã biên dịch sẵn có thể nạp vào mạch mô phỏng.
- **Proteus/Nhom08**: Mạch mô phỏng của dự án.
- **Python_IoT**: Code Python dùng để giao tiếp giữa mạch mô phỏng và Firebase.
- **vspd.exe**: Phần mềm để thiết lập liên kết ảo giữa các cổng COM (Pair COM1 với COM4).
- Trong **Python_IoT** có 2 lựa chọn:
  - **Portable**: Môi trường Python đã được thiết lập sẵn, chỉ cần chạy file `WinPython Command Prompt.exe` hoặc `WinPython Powershell Prompt.exe` và nhập lệnh `python iot.py`.
  - **Python**: Mã nguồn gốc (.py) cần tự cài đặt môi trường Python và các thư viện với `pip install -r requirenments.txt` trước khi chạy với `python iot.py`.
