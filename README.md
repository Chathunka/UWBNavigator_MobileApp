# UWB_Navigator Flutter App

## Overview
The UWB_Navigator Flutter App is designed for indoor localization using UWB (Ultra-Wideband) sensors in conjunction with an M5 Stack device. This app is developed to receive distance data from the M5 Stack device via either BLE (Bluetooth Low Energy) or WiFi communication. The distance data is then utilized to calculate the x, y, and z coordinates of the 3D space using trilateration techniques. These coordinates are used to represent the location of the UWB tag in a 3D view within the Flutter app, providing real-time, interactive tracking and updating of the current location.

## Features
- Real-time indoor localization using UWB technology.
- Integration with the M5 Stack device for distance data acquisition.
- Communication via BLE or WiFi for data transfer.
- 3D visualization of the UWB tag's location within the app.
- Interactive tracking and continuous updating of the current location.

## Getting Started

### Prerequisites
Before you begin, make sure you have the following:

- Flutter development environment set up on your system.
- An Android or iOS device for testing the app.
- An M5 Stack device with atleast 4 UWB sensors.

### Installation

1. Clone the UWB_Navigator Flutter App repository to your local machine:

   ```bash
   git clone https://github.com/Chathunka/UWBNavigator_MobileApp.git
   ```

2. Navigate to the project directory:

   ```bash
   cd UWB_Navigator
   ```

3. Install the required dependencies using Flutter:

   ```bash
   flutter pub get
   ```

### Configuration

1. Configure the app to connect to your M5 Stack device. This may involve setting up BLE or WiFi communication,  depending on your hardware and communication preferences and defining Base station locations in the 3D space.

2. Ensure that the UWB sensor on your M5 Stack device is properly plased on the defined locations and configured for accurate distance measurement.

3. Update any relevant settings or parameters within the app to match your specific environment and hardware.

### Usage

1. Connect your Android or iOS device to your development environment.

2. Run the app on your device using Flutter:

   ```bash
   flutter run
   ```

3. Once the app is running, you should be able to connect your mobile phone with the M5Stack device using either WiFI or BLE.

4. Once conneted and configured, the app will perform trilateration calculations based on the received distance data and display the UWB tag's location in a 3D view.

5. Interact with the app to view real-time updates of the UWB tag's location as it moves within the indoor space.

## Troubleshooting

If you encounter any issues while setting up or using the UWB_Navigator app, refer to the troubleshooting section in the app's documentation or seek assistance from the project's support channels.

## License

This project is licensed under the [MIT License](LICENSE.md).

## Acknowledgments

- Special thanks to the contributors and developers who made this project possible.

## Contact Information

For any questions, feedback, or support requests, please contact:

- [Chathunka](mailto:cjtennakoon@gmail.com)

## About

This Flutter app is part of the UWB_Navigator project, which aims to provide accurate indoor localization using UWB technology. For more information about the project and its goals, visit the project repository: [UWB_Navigator Project](https://github.com/Chathunka/UWBNavigator_MobileApp.git).

---

Thank you for using the UWB_Navigator Flutter App! We hope this app helps you achieve accurate indoor localization using UWB sensors and the M5 Stack device. If you encounter any issues or have suggestions for improvements, please don't hesitate to reach out. Happy navigating!
