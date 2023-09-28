import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLE {
  Function(String, BluetoothDevice, String) onData;
  Function(String, String) onError;
  late ScanResult deviceResult;
  bool BLEresultSet = false;
  String _DEVID;
  BLE(this.onData, this.onError, this._DEVID);


  //BLE methods
  Future<void> searchBLE() async {
    bool UnableToFound = true;
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.localName == "UWB_Navigator" && r.device.remoteId.toString() == "B0:B2:1C:50:E7:A2") {
          if (BLEresultSet == false) {
            deviceResult = r;
            print('${r.device} found! rssi: ${r.rssi}');
            BLEresultSet = true;
            UnableToFound = false;
            onData("BLESCANRESULT",r.device,_DEVID);
            await FlutterBluePlus.stopScan();
            print("Stopping");
            break;
          }
        }
      }
    });
    FlutterBluePlus.startScan(timeout: Duration(seconds: 2), androidUsesFineLocation: true);
    Future.delayed(const Duration(milliseconds: 3000), () async{
      if(UnableToFound){
        onError("BLESCANRESULTTIMEOUT",_DEVID);
      }
    });
  }

  Future<void> connectBLE(BluetoothDevice dev) async {
    Future.delayed(const Duration(milliseconds: 2000), () async{
      dev.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          print("..............................Disconnected from BLE class ONCONNECT");
          onData("BLEDEVICENOTCONNECTED",dev,_DEVID);
        }else if(state == BluetoothConnectionState.connected){
          print("..............................Connected from BLE class ONCONNECT");
          onData("BLEDEVICECONNECTED",dev,_DEVID);
        }
      });
      try {
        await dev.connect();
      }catch(e){}
    });
  }

  Future<void> checkBLE(BluetoothDevice dev) async {
    try {
      await dev.connect(timeout: Duration(seconds: 5));
    } catch (e) {
      print("..............................ERROR from BLE class ONSEARCH");
      onData("BLEDEVICEERROR", dev, _DEVID);
    }
    Future.delayed(const Duration(milliseconds: 200), () async{
      late var subscription;
      subscription = dev.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          print("..............................Disconnected from BLE class ONSEARCH");
          subscription.cancel();
          onData("BLEDEVICENOTCONNECTED",dev,_DEVID);
        }else if(state == BluetoothConnectionState.connected){
          print("..............................Connected from BLE class ONSEARCH");
          subscription.cancel();
          onData("BLEDEVICECONNECTED",dev,_DEVID);
        }
      });
    });
  }
}