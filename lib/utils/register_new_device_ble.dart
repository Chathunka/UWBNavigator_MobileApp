import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:uwb_navigator/db/db_provider_local.dart';
import 'package:uwb_navigator/models/device.dart';
import 'package:uwb_navigator/utils/ble.dart';

MobileScannerController cameraController = MobileScannerController();

class RegisterNewDeviceBLE {
  bool showQR = true;
  bool showWifi = false;
  String QRdata = "";
  String devSerial = "";
  String ssid = '', password = '';
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  String selectedWifi = "No Wifi Selected";
  bool shouldCheckCan = true;

  late StreamSubscription _streamSubscription;
  bool devaddmode = false;

  String DEVSSID = "UWB_Navigator";
  String DEVPWD = "12345678";

  void Function(String) onData;
  final BuildContext _context;

  late BLE bleInstance;

  RegisterNewDeviceBLE(this._context,this.onData){
    _startWifiScan();
    bleInstance = BLE(_onBLEData);
  }

  Future<void> dialogBuilder() {
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
                                  if(QRdata.contains("UWB_Navigator",0)){QRdata = "UWB_Navigator";}
                                  setState(() { devSerial = QRdata; showQR = false;});
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 10.0,),
                        const Text('Device Details :', style: TextStyle(color: Colors.black),),
                        const SizedBox(height: 10.0,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(onChanged: (s) {if (s.isNotEmpty) devSerial = s;}, decoration: const InputDecoration(hintText: "Device Serial"),),
                        ),
                        ElevatedButton(onPressed:(){ setState(() => showQR = false);}, child: const Text("Click to Add device")),
                      ],
                    )
                    : Container(
                      child: Padding(padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: const EdgeInsets.all(8.0), child: Text("Device Name: "+devSerial),),
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
                TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge,), child: const Text('Cancel'), onPressed: () {Navigator.of(context).pop();},),
                TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge,), child: const Text('Add'), onPressed: () {connectBLE(DEVSSID,DEVPWD,true);},),
              ],
            ),
          );
        });
      },
    );
  }

  void decodeSerial(String serial){

  }

  Future<void> connectBLE(String ssid, String password, bool mode) async {
    devaddmode = mode;
    try {
      final Map<String, dynamic> arguments = {'arg1': ssid, 'arg2': password};
      bleInstance.scanDevice("B0:B2:1C:50:E7:A2");
    } on PlatformException catch (e) {}
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

  Future<void> _onBLEData(String status) async {
    print(status);
    if(status== "BLE_DEVICE_FOUND"){
      if(devaddmode) {await deviceDescriptor("");Navigator.of(_context).pop();onData("BLE_DEVICE_ADDED");}else {onData("BLE_DEVICE_CONNECTED");}
    }
  }

  void kShowSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }
}