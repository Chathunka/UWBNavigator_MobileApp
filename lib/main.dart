import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uwb_navigator/screens/home.dart';
import 'package:uwb_navigator/screens/qr_scanner.dart';
import 'package:uwb_navigator/screens/three_dim_space.dart';
import 'package:uwb_navigator/screens/three_dim_space_local.dart';
import 'package:uwb_navigator/screens/three_dim_spiral.dart';
import 'package:uwb_navigator/screens/wrapper.dart';
import 'package:uwb_navigator/shared/variables.dart';
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
      '/3dmap': (context) => ThreeDimSpace(),
      '/3dspiral' : (context) => ThreeDimSpiral(),
      '/QRScanner' : (context) => QRScanner(),
      '/test' : (context) => MyHomePage(title: 'Flutter Demo Home Page')
    },
  ));
}


