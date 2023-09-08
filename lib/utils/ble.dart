import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLE {
  bool deviceFound = false;
  bool deviceConnected = false;
  bool deviceServiceDetected = false;
  String msg = "";
  String msg1 = "";
  String msg2 = "";
  String msg3 = "";
  late ScanResult deviceResult;
  late List<BluetoothService> deviceServices;
  String devRemoteId = "B0:B2:1C:50:E7:A2";
  void Function(String) onData;

  BLE(this.onData);

  Future<void> scanDevice(String devRemoteID) async {
    var subscription = FlutterBluePlus.scanResults.listen((results) async{
      for (ScanResult r in results) {
        if(r.device.localName == "UWB_Navigator" && r.device.remoteId.toString() == devRemoteID) {
          msg = r.device.localName + r.device.remoteId.toString();
          deviceResult = r;
          print('${r.device} found! rssi: ${r.rssi}'); await FlutterBluePlus.stopScan(); print("Stopping");break;
        }
      }
      await FlutterBluePlus.stopScan();
      onData("BLE_DEVICE_FOUND");
    });
    FlutterBluePlus.startScan(timeout: Duration(seconds: 2));
  }

  Future<void> ConnectDevice() async{
    deviceResult.device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {}else if(state == BluetoothConnectionState.connected){
        deviceConnected = true;
        onData("BLE_DEVICE_CONNECTED");
      }
    });
    await deviceResult.device.connect();
  }

  Future<void> DisconnectDevice() async{
    deviceResult.device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {deviceConnected = false;}
    });
    await deviceResult.device.disconnect(timeout: 35);
  }

  Stream<int> timedCounter(Duration interval, [int? maxCount]) {
    late StreamController<int> controller;
    Timer? timer;
    int counter = 0;

    void tick(_) {
      counter++;
      controller.add(counter); // Ask stream to send counter values as event.
      if (counter == maxCount) {
        timer?.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
    }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      timer?.cancel();
      timer = null;
    }

    controller = StreamController<int>(
        onListen: startTimer,
        onPause: stopTimer,
        onResume: startTimer,
        onCancel: stopTimer);

    return controller.stream;
  }

  Future<void> ReadData() async{
    deviceServices = await deviceResult.device.discoverServices(timeout: 20);
    print("Service detected888888888888");
    for (BluetoothService service in deviceServices){
      if(service.serviceUuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
        print(service.serviceUuid);
        for (BluetoothCharacteristic characteristic in service.characteristics){
          if(characteristic.characteristicUuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a7"){
            print(characteristic.characteristicUuid.toString());
            characteristic.onValueReceived.listen((value) {
                msg1 = utf8.decode(value);
            });
            await characteristic.setNotifyValue(true);
          }
          if(characteristic.characteristicUuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8"){
            print(characteristic.characteristicUuid.toString());
            characteristic.onValueReceived.listen((value) {
                msg2 = utf8.decode(value);
            });
            await characteristic.setNotifyValue(true);
          }
          if(characteristic.characteristicUuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a9"){
            print(characteristic.characteristicUuid.toString());
            characteristic.onValueReceived.listen((value) {
                msg3 = utf8.decode(value);
            });
            await characteristic.setNotifyValue(true);
          }
        }
      }
    }
  }
}