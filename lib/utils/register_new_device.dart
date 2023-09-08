import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uwb_navigator/utils/ble.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:uwb_navigator/db/db_provider_local.dart';
import 'package:uwb_navigator/models/device.dart';
import 'package:uwb_navigator/shared/variables.dart';

MobileScannerController cameraController = MobileScannerController();

class RegisterNewDevice {
  bool showQR = true;
  bool showWifi = false;
  String QRdata = "";

  String ssid = '', password = '';
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  String selectedWifi = "No Wifi Selected";
  bool shouldCheckCan = true;

  static const platform = MethodChannel('com.iotes/connectDeviceAP');
  static const stream = EventChannel('com.iotes/listenDeviceAP');
  late StreamSubscription _streamSubscription;

  late BLE bleInstance;

  String DEV_NAME = "";
  bool _DEV_ADD_MODE = false; // 0 => reconnect
  bool _GO_3D = false; // 1 => direct to 3D view

  bool _CON_MODE = false; // 0 => WIFI
  String _DEVSSID = "UWB_Navigator";
  String _DEVPWD = "12345678";
  String _UUID = "";

  void Function(String) onData;
  final BuildContext _context;

  late ScanResult deviceResult;

  RegisterNewDevice(this._context,this.onData){
    bleInstance = BLE(_onBLEData);
    _startWifiScan();
  }


  Future<void> dialogBuilder(bool mode) {
    _DEV_ADD_MODE = mode;
    return showDialog<void>(
      useSafeArea: true,
      context: _context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(titlePadding: const EdgeInsets.all(5), contentPadding: const EdgeInsets.only(top: 5, bottom: 5), backgroundColor: const Color.fromRGBO(250, 250, 250, 1.0),
              //Title
              title: Container(width: 400, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.teal, border: Border.all(color: Colors.teal,width: 2), borderRadius: BorderRadius.circular(5)),
                child: const Center(child: Text("Register new Device", style: TextStyle(color: Colors.white),)),
              ),
              content: Column(
                children: [
                  Center(
                    child: showQR ? Column(mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 400, height: 400,
                            child: Center(
                              child: MobileScanner(fit: BoxFit.contain,
                                overlay: Container(width: 200, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.teal,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2) ),),),
                                controller: MobileScannerController(returnImage: true,),
                                onDetect: (capture) {
                                  final List<Barcode> barcodes = capture.barcodes;final Uint8List? image = capture.image;
                                  for (final barcode in barcodes) {QRdata = barcode.rawValue.toString();}
                                  if(decodeSerial(QRdata)){setState(() { DEV_NAME = _DEVSSID; showQR = false;});}else{}
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 10.0,),
                        const Text('Device Details :', style: TextStyle(color: Colors.black),),
                        const SizedBox(height: 10.0,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(onChanged: (s) {if (s.isNotEmpty) QRdata = s;}, decoration: const InputDecoration(hintText: "Device Serial"),),
                        ),
                        ElevatedButton(onPressed:(){
                          if(decodeSerial(QRdata)){setState(() { DEV_NAME = _DEVSSID; showQR = false;});}else{}
                          }, child: const Text("Click to Add device")),
                      ],
                    )
                    : Container(
                      child: Padding(padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: const EdgeInsets.all(8.0), child: Text("Device Name: "+DEV_NAME),),
                            const SizedBox(height: 10.0,),
                            Container(padding: EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Wifi scan button
                                  ElevatedButton.icon(icon: const Icon(Icons.perm_scan_wifi), label: const Text('Scan wifi networks.'), onPressed: () async {
                                    List<WiFiAccessPoint> ap = await _getWifiScannedResults(context);
                                      setState(() {
                                        accessPoints = ap;
                                        showWifi = true;
                                      });
                                    }),
                                  //Wifi scan box
                                  Container(
                                    child: showWifi
                                      ?Container(width: double.infinity,height: 200,decoration: BoxDecoration(border: Border.all(color: Colors.teal, width: 3), borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                                        child: Container(width: 400, height: 150,
                                          child: Center(
                                            child: accessPoints.isEmpty
                                              ? const Text("Scan to see results.")
                                              : ListView.separated(itemCount: accessPoints.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final signalIcon = accessPoints[index].level >= -80 ? Icons.signal_wifi_4_bar : Icons.signal_wifi_0_bar;
                                                  return ListTile(visualDensity: VisualDensity.compact, leading: Icon(signalIcon),
                                                      title: Text(accessPoints[index].ssid), //subtitle: Text(accessPoints[index].capabilities),
                                                      onTap: () {setState(() {selectedWifi = accessPoints[index].ssid;});});
                                                },separatorBuilder: (BuildContext context, int index) { return const Divider(); },
                                              ),
                                          ),
                                        ),
                                      )
                                      :Container(),
                                  ),
                                  const SizedBox(height: 10.0,),
                                  //wifi ssid
                                  Container(child: const Text('Wi-Fi ssid :', style: TextStyle(color: Colors.black),),),
                                  Container(padding: EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                                    child: TextFormField(style: const TextStyle(color: Colors.teal),
                                      controller: TextEditingController()..text = selectedWifi,
                                      onChanged: (s) {if (s.isNotEmpty) ssid = s;},
                                      decoration: const InputDecoration(hintText: "Wi-Fi ssid"),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0,),
                                  //wifi password
                                  Container(child: const Text('Wifi password :', style: TextStyle(color: Colors.black),),),
                                  Container(padding: EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                                    child: TextFormField(style: TextStyle(color: Colors.teal), onChanged: (s) {if (s.isNotEmpty) password = s;}, decoration: InputDecoration(hintText: "PASSWORD"),),
                                  ),
                                  const SizedBox(height: 10.0,),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                showQR ? Container() : TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge,), child: const Text('Cancel'), onPressed: () {Navigator.of(context).pop();},),
                showQR ? Container() : TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge,), child: const Text('Add'), onPressed: () {connectDevice();},),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> reconnectDialogBuilder(bool mode, bool go3d) {
    _DEV_ADD_MODE = mode;
    _GO_3D = go3d;
    return showDialog<void>(
      useSafeArea: true,
      context: _context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(titlePadding: const EdgeInsets.all(5), contentPadding: const EdgeInsets.only(top: 5, bottom: 5), backgroundColor: const Color.fromRGBO(250, 250, 250, 1.0),
              //Title
              title: Container(width: 400, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.teal, border: Border.all(color: Colors.teal,width: 2), borderRadius: BorderRadius.circular(5)),
                child: const Center(child: Text("Reconnect Device", style: TextStyle(color: Colors.white),)),
              ),
              content: Column(
                children: [
                  Center(
                    child: showQR ? Column(mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 400, height: 400,
                          child: Center(
                            child: MobileScanner(fit: BoxFit.contain,
                              overlay: Container(width: 200, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.teal,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2) ),),),
                              controller: MobileScannerController(returnImage: true,),
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;final Uint8List? image = capture.image;
                                for (final barcode in barcodes) {QRdata = barcode.rawValue.toString();}
                                if(decodeSerial(QRdata)){showQR = false;connectDevice();}else{}
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0,),
                        const Text('Device Details :', style: TextStyle(color: Colors.black),),
                        const SizedBox(height: 10.0,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(onChanged: (s) {if (s.isNotEmpty) QRdata = s;}, decoration: const InputDecoration(hintText: "Device Serial"),),
                        ),
                        Row(
                          children: [
                            ElevatedButton(onPressed:(){
                              _CON_MODE = Constants.BLE_MODE; showQR = false; connectDevice();
                            }, child: const Text("BLE MODE")),
                            ElevatedButton(onPressed:(){
                              _CON_MODE = Constants.WIFI_MODE; showQR = false; connectDevice();
                            }, child: const Text("Wi-Fi MODE")),
                          ],
                        )
                      ],
                    )
                        : Container(),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> connectDevice()async {
    if(_CON_MODE){
      print("Connect in BLE mode 0000000000000000000000000000000000");
      connectBLE(_DEVSSID,_DEVPWD);
    }else{
      print("Connect in WIFI mode 0000000000000000000000000000000000");
      connectAP(_DEVSSID,_DEVPWD);
    }
  }

  //WIFI methods
  Future<void> connectAP(String ssid, String password) async {
    try {
      final Map<String, dynamic> arguments = {'arg1': Constants.DEFAULT_DEV_NAME, 'arg2': Constants.DEFAULT_DEV_PASS};
      await platform.invokeMethod('connectDevice', arguments);
      _streamSubscription = stream.receiveBroadcastStream().listen(_listenStream);
    } on PlatformException catch (e) {}
  }

  void _listenStream(value) async{
    if (value == 1.0) {_streamSubscription.cancel();
      if(_DEV_ADD_MODE) {await deviceDescriptor("");Navigator.of(_context).pop();onData("WIFI_DEVICE_ADDED");} else if(_GO_3D){onData("WIFI_DEVICE_RECONNECTED_GO3D");} else {onData("WIFI_DEVICE_RECONNECTED");}
    }
  }

  //BLE methods
  Future<void> connectBLE(String ssid, String password) async {
    try {
      final Map<String, dynamic> arguments = {'arg1': ssid, 'arg2': password};
      bleInstance.scanDevice("B0:B2:1C:50:E7:A2");
    } on PlatformException catch (e) {}
  }

  Future<void> _onBLEData(String status) async {
    print(status);
    switch(status){
      case "BLE_DEVICE_FOUND" :
        bleInstance.ConnectDevice();
        break;
      case "BLE_DEVICE_CONNECTED" :
        if(_DEV_ADD_MODE) {await deviceDescriptor("");Navigator.of(_context).pop();onData("BLE_DEVICE_ADDED");}else {onData("BLE_DEVICE_CONNECTED");}
        break;
    }
  }

  //Common Methods
  bool decodeSerial(String serial){
    if(serial.contains("BRY",0)){
      final parts = serial.split('#');
      if(parts.length == 4){
        _DEVSSID = "UWB_Navigator"+parts[1];
        _UUID = parts[2];
        if(parts[3] == "1"){
          _CON_MODE = Constants.BLE_MODE;
        }else if(parts[3] == "0"){
          _CON_MODE = Constants.WIFI_MODE;
        }
        return true;
      }else {
        return false;
      }
    }else{
      print("QR data not in format");
      return false;
    }
  }

  Future deviceDescriptor(String otherdata) async {
    Device dev = Device(id: 1, name: "UWB_Navigator_Tag", status: "Connected", type: "Tag", x: 0.0, y: 0.0, z: 0.0,);
    await DBProviderLocal().newDevice(dev);
  }

  Future<void> _startWifiScan() async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        //kShowSnackBar(context, "Cannot start scan: $can");
        return;
      }
    }
    final result = await WiFiScan.instance.startScan();
  }

  Future<bool> _canGetWifiScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canGetScannedResults();
      if (can != CanGetScannedResults.yes) {
        kShowSnackBar(context, "Cannot get wifi scanned results: $can");
        return false;
      }
    }
    return true;
  }

  Future<List<WiFiAccessPoint>> _getWifiScannedResults(BuildContext context) async {
    List<WiFiAccessPoint> ap = await _startListeningToWifiScanResults(context);
    ap = await WiFiScan.instance.getScannedResults();
    return ap;
  }

  Future<List<WiFiAccessPoint>> _startListeningToWifiScanResults(BuildContext context) async {
    List<WiFiAccessPoint> ap =[];
    if (await _canGetWifiScannedResults(context)) {
      subscription = WiFiScan.instance.onScannedResultsAvailable.listen((result) => ap = result);
    }
    return ap;
  }

  void kShowSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }
}