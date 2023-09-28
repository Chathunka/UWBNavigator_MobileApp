import 'package:flutter/material.dart';

class AppColor {
  static const Color AppBarPrimaryColor = Colors.teal;
  static const Color primaryColor = Colors.teal;
  static const Color secondaryColor = Colors.tealAccent;
  static const Color errorRed = Color(0xFFFF6E6E);

  static const Color bgColor= Color.fromARGB(255, 244, 245, 249);
  static const Color white= Colors.white;

  static const Color colorOne= Colors.blueAccent;
  static const Color colorTwo= Colors.deepOrangeAccent;

  // static const Color colorOne= Colors.teal;
  // static const Color colorTwo= Colors.teal;

}

class Constants {
  static const bool DEVICE_RECONNECT_MODE = false;
  static const bool DEVICE_CONNECT_MODE = true;
  static const bool GO_3D = true;
  static const bool GO_HERE = false;
  static const bool WIFI_MODE = false;
  static const bool BLE_MODE = true;

  static const String DEFAULT_DEV_NAME = "UWB_Navigator";
  static const String DEFAULT_DEV_PASS = "12345678";
}

class GlobalVariables{
  static const String BASE_URL_WEB_API =  "http://172.16.4.78:3000/api/";
  static const String BASE_URL_WEB_SOCKET =  "ws://172.16.4.78:7071/";
}