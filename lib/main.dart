import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uwb_navigator/screens/home.dart';
import 'package:uwb_navigator/screens/authentication_page.dart';
import 'package:uwb_navigator/screens/qr_scanner.dart';
import 'package:uwb_navigator/screens/three_dim_space.dart';
import 'package:uwb_navigator/screens/three_dim_spiral.dart';
import 'package:uwb_navigator/screens/wrapper.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/device_configuration.dart';
import 'package:uwb_navigator/utils/network_status_requester.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'UWB_Navigator',
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => Wrapper(),
      '/home': (context) => Home(),
      '/3dspiral' : (context) => ThreeDimSpiral(),
      '/QRScanner' : (context) => QRScanner(),
      '/auth' : (context) => AuthenticationPage(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/3dmap') {
        final devid = settings.arguments as Map<String,int>;
        return MaterialPageRoute(builder: (_) => ThreeDimSpace(devid["devid"]!,devid["mode"]!));
      }
      if (settings.name == '/deviceConfig') {
        final devid = settings.arguments as Map<String,int>;
        return MaterialPageRoute(builder: (_) => DeviceConfigure(devid["devid"]!,devid["mode"]!));
      }
      return null;
    },
  ));
}


