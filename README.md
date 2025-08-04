# Design and development of an embedded system for obstacle detection on radio-controlled cars

## Overview

This project aims to describe the design and development of an embedded system for obstacle detection on radio-controlled cars. The system consists of an Arduino Due microcontroller, responsible for collecting distance measurements from 8 proximity sensors placed on the radio-controlled car. The acquired data is transmitted via serial communication to an Arduino Nano 33 BLE, which processes it, filters out any anomalous values, and sends it via Bluetooth Low Energy to an application developed with Flutter. This app allows the user to easily and intuitively visualize the presence of obstacles around the radio-controlled car.

## Hardware requirements

- 8 HC-SR04 proximity sensors
- [Arduino Nano 33 BLE](https://docs.arduino.cc/hardware/nano-33-ble/)
- [Arduino Due](https://docs.arduino.cc/hardware/nano-33-ble/)
- [RC Car](https://traxxas.com/) 
- Mobile phone
- Powerbank with two 5V out ports

![Hardware connections](images/connections.jpg?raw=true)

## Software requirements

### Integrated development enviroments

- [Arduino IDE 2.3.6](https://www.arduino.cc/en/software/)
- [Visual Studio Code](https://code.visualstudio.com/) with [Flutter](https://flutter.dev/) framework

## Quick start

1. **Upload Firmware to Arduino Boards:**
   - Upload the `edge/Bluetooth/Bluetooth.ino` sketch to your `Arduino Nano 33 BLE` board.
   - Then, upload the `edge/Collector/Collector.ino` sketch to your `Arduino Due` board.
2. **Connect the cables as shown in the image above**
   - Connect the echo pins of the sensors to digital pins 3 through 10
4. **Configure the Client Application:**
   - Open the `client/lib/default.dart` file in your code editor.
   - Inside this file, set your configuration values, such as `deviceId` and `deviceToken`, in the appropriate fields.
5. **Download Project Dependencies:**
   - Open the integrated terminal in Visual Studio Code.
   - Run the command `flutter pub get` to download all the necessary libraries for the project.
6. **Deploy the Mobile Application:**
   - Build and run the application to install it on your mobile phone.
  
 ![Application](images/application.jpg?raw=true)
 ![Car](images/car.jpg?raw=true)
