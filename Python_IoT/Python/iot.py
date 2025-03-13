from PyQt5 import QtWidgets, uic, QtCore
import sys
import socket
import threading
from time import sleep
import serial
from firebase import firebase


serverAddressPort = ("127.0.0.1", 20001)

bufferSize = 1024

bytesToSend = str.encode('')


firebase = firebase.FirebaseApplication('https://iot-nhom08-default-rtdb.asia-southeast1.firebasedatabase.app')

ROOM = "/LED_CONTROL"

COMPORT = "COM4"

class clientClass (threading.Thread):

    def __init__ (self, comport, room):
        threading.Thread.__init__(self)
        #call parent init()
        self.comport = comport
        self.room = room
        self.s = serial.Serial(self.comport, 9600, timeout=None)
        self.getDataFromHW = threading.Thread(target=self.send2Server_c02)
        self.getDataFromHW.start()

    def run(self):
        last_data = None
        while (True):
            # sleep (2)
            result = firebase.get(ROOM, None)
            
            # print(result)
            
            if result != None:      
                ledcontrol = result['nutNguon'] + result['nutDoiMau'] + result['tuDongSang'] + result['doSangCuaDen'] +"\n"
                if ledcontrol != last_data:
                    last_data = ledcontrol
                    print(ledcontrol)
                    self.s.write(str.encode(ledcontrol + '\n'))
            else:
                print ("FB is Clear")

    def send2Server_c02(self):
        data_cu = None
        while (True):
            #readline(): code will be waiting herefft not consume CPU. () readline() is read until '\n' D*23*89*\n
            

            data = self.s.readline()
            data = data.decode('utf-8') #for read until(), https://pyserial.readthedocs. fread until(),read until char, but need to read enough number of

            
            if(data.startswith("D*")):
                if(data != data_cu):
                    data_cu = data
                    print(data)
                    data = data.split('*')  # Tách chuỗi
                    nutNguon = data[1]
                    nutDoiMau = data[2]
                    tuDongSang = data[3]  # Xóa ký tự xuống dòng
                    doSangCuaDen = data[4].strip()

                    
                    # Gửi dữ liệu lên Firebase
                    firebase.put(self.room, 'nutNguon', nutNguon)
                    firebase.put(self.room, 'nutDoiMau', nutDoiMau)
                    firebase.put(self.room, 'tuDongSang', tuDongSang)
                    firebase.put(self.room, 'doSangCuaDen', doSangCuaDen)

                else:
                    continue


	
#Liston for incoming datagrams
	
clientDev = clientClass (COMPORT, ROOM)
clientDev.start()
clientDev.join()