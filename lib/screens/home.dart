import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uwb_navigator/db/db_provider_local.dart';
import 'package:uwb_navigator/screens/device_card.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/ble.dart';
import 'package:uwb_navigator/utils/register_new_device.dart';
import 'package:uwb_navigator/utils/register_new_device_ble.dart';
import '../models/device.dart';
import 'package:web_socket_channel/io.dart';
import 'package:uwb_navigator/shared/variables.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Device>? _devices;

  IOWebSocketChannel? channel; // Declare the WebSocket channel as nullable

  String station1Distance = '0.0';
  String station2Distance = '0.0';
  String station3Distance = '0.0';

  bool isItem1Open = true;
  bool isItem2Open = false;

  ExpandableController userGuidController = ExpandableController(initialExpanded: true);
  ExpandableController deviceController = ExpandableController(initialExpanded: false);

  void initState() {
    super.initState();
    updateDevices();
  }

  void updateDevices(){
    DBProviderLocal().getAllDevices().then((devices) {
      setState(() {_devices = devices.cast<Device>();});
    });
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userGuidController.addListener((){
      if(userGuidController.value)deviceController.value=false;
    });
    deviceController.addListener((){
      if(deviceController.value)userGuidController.value=false;
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[AppColor.AppBarPrimaryColor, AppColor.secondaryColor]))),
        elevation: 0.0,
        title: const Text('UWB_Navigator', style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          TextButton.icon(icon: const Icon(Icons.qr_code, color: Colors.white,), label: const Text(''), onPressed: () {Navigator.pushNamed(context, '/QRScanner');},),
          TextButton.icon(icon: const Icon(Icons.menu, color: Colors.white,), label: const Text(''), onPressed: () {Navigator.pushNamed(context, '/3dspiral');},),
          TextButton.icon(icon: const Icon(Icons.network_check, color: Colors.white,), label: const Text(''), onPressed: () {Navigator.pushNamed(context, '/test');},),
        ],
      ),
      body: Container(
        child: _devices == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                ExpandablePanel(theme: const ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center, tapBodyToExpand: true, tapBodyToCollapse: true, hasIcon: false, ),
                  controller: userGuidController,
                  header: Container(decoration: BoxDecoration(border: Border.all(color: Colors.teal, width: 5), borderRadius: BorderRadius.only(topLeft: Radius.circular(10) , topRight: Radius.circular(10) ),),
                    child: Stack(children: <Widget>[
                      Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: <Color>[Colors.teal, Colors.teal, Colors.teal],),),),),
                      Row(
                        children: [
                          ExpandableIcon(theme: const ExpandableThemeData(expandIcon: Icons.arrow_right, collapseIcon: Icons.arrow_drop_down, iconColor: Colors.white, iconSize: 28.0, iconRotationAngle: pi / 2, iconPadding: EdgeInsets.only(right: 5), hasIcon: false,)),
                          const SizedBox(width: 10,), const Icon(Icons.list_alt,color: Colors.white,size: 28,), const SizedBox(width: 10,), const Text("UWB Navigator User Guid",style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ]),
                  ),
                  collapsed: Container(height: 20, decoration: BoxDecoration(border: Border.all(color: Colors.teal.shade200,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),),
                  expanded: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.teal.shade200,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),
                    child: Padding(padding: const EdgeInsets.all(16.0),
                      child: ExpansionPanelList(
                        expansionCallback: (int index, bool isExpanded) {setState(() {if(index == 0) {isItem1Open = !isExpanded;isItem2Open = false;}else {isItem2Open = !isExpanded;isItem1Open = false;}});},
                        children: [
                          ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return ListTile(tileColor: Colors.teal[400], selected: isItem1Open, selectedTileColor: Colors.teal[100], textColor: Colors.white, leading: CircleAvatar(child: Text('?')), title: Text('How to use UWB_Navigator ?'),);
                            },
                            body: const ListTile(title: Text('Item 1 child'), subtitle: Text('Details goes here'),),
                            isExpanded: isItem1Open,
                          ),
                          ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return ListTile(tileColor: Colors.teal[400], selected: isItem2Open, selectedTileColor: Colors.teal[100], textColor: Colors.white, leading: const CircleAvatar(child: Text('#')), title: const Text('UWB Tags'),);
                            },
                            body: const ListTile(title: Text('Item 2 child'), subtitle: Text('Details goes here'),),
                            isExpanded: isItem2Open,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                ExpandablePanel(theme: const ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center, tapBodyToExpand: true, tapBodyToCollapse: true, hasIcon: false,),
                  controller: deviceController,
                  header: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.teal, width: 5), borderRadius: const BorderRadius.only(topLeft: Radius.circular(10) , topRight: Radius.circular(10) ),),
                    child: Column(
                      children: [
                        Stack(children: <Widget>[
                          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: <Color>[Colors.teal, Colors.teal, Colors.teal,],),),),),
                          Row(
                            children: [
                              ExpandableIcon(theme: const ExpandableThemeData(expandIcon: Icons.arrow_right, collapseIcon: Icons.arrow_drop_down, iconColor: Colors.white, iconSize: 28.0, iconRotationAngle: pi / 2, iconPadding: EdgeInsets.only(right: 5), hasIcon: false,),),
                              const SizedBox(width: 10,), const Icon(Icons.developer_mode,color: Colors.white,size: 28,), const SizedBox(width: 10,), const Text("Devices",style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ),
                  collapsed: Container(height: 20, decoration: BoxDecoration(border: Border.all(color: Colors.teal.shade200,width: 3), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),),
                  expanded: Container(height: 330,
                    decoration: BoxDecoration(border: Border.all(color: Colors.teal.shade200,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),
                    child: _devices!.length == 0
                        ? const Padding(padding: EdgeInsets.all(16.0), child: const Center(child: Text("You have no devices currently. Please click (+) button to add new device.")),)
                        : Padding(padding: const EdgeInsets.all(8),
                      child: ListView.builder(itemCount: _devices!.length,
                        itemBuilder: (BuildContext context, int index) {
                          Device item = _devices![index];
                          return Dismissible(key: UniqueKey(),
                            child: Padding(padding: const EdgeInsets.only(top: 8),
                              child: DeviceCard(id: item.id.toString(), name: item.name!, status: item.status!, type: "tag", x: double.parse(station1Distance), y: double.parse(station2Distance), z: double.parse(station3Distance), onAreaClick: _onDeviceClicked,),
                            ),
                            onDismissed: (direction) async{await disconnectWebSocket();await DBProviderLocal().deleteDevice(item.id!);},
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.AppBarPrimaryColor,
        onPressed: () async{
          Map<Permission, PermissionStatus> statuses = await [Permission.location, Permission.locationWhenInUse, Permission.camera, Permission.bluetoothConnect,].request();
          if(statuses[Permission.camera] == PermissionStatus.granted && statuses[Permission.location] == PermissionStatus.granted && statuses[Permission.locationWhenInUse] == PermissionStatus.granted && statuses[Permission.bluetoothConnect] == PermissionStatus.granted){
            if(await CheckBluetooth()) {await RegisterNewDevice(context,_onDeviceConnected).dialogBuilder(Constants.DEVICE_CONNECT_MODE);}
          }else{
            permissionAlertBuilder(context);
          }
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  Future<void> permissionAlertBuilder(BuildContext context) {
    return showDialog<void>(useSafeArea: true, context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(titlePadding: const EdgeInsets.all(5), contentPadding: const EdgeInsets.only(top: 5, bottom: 5), backgroundColor: const Color.fromRGBO(250, 250, 250, 1.0),
            //Title
            title: Container(width: 400, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.teal, border: Border.all(color: Colors.teal,width: 2), borderRadius: BorderRadius.circular(5)), child: const Center(child: Text("Permission Request Handler", style: TextStyle(color: Colors.white),)),),
            content: Container(width: 400, height: 200, padding: const EdgeInsets.all(16), child: const Center(child: Text("Please enable all the requested permissions before using the app. Thanks."),),),
            actions: <Widget>[
              TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge,), child: const Text('Ok'), onPressed: () {openAppSettings();},),
              TextButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge,), child: const Text('Cancel'), onPressed: () {Navigator.of(context).pop();},),
            ],
          );
        });
      },
    );
  }

  // check adapter availability
  Future<bool> CheckBluetooth() async{
    if (await FlutterBluePlus.isAvailable == false) {
      print("Bluetooth not supported by this device");
      return false;
    }else {
      print("Bluetooth is available");
      BluetoothAdapterState s = await FlutterBluePlus.adapterState.map((s){print(s);return s;}).first;
      if (Platform.isAndroid && s == BluetoothAdapterState.off) {
        await FlutterBluePlus.turnOn(timeout: 15);
        BluetoothAdapterState s = await FlutterBluePlus.adapterState.map((s){print(s);return s;}).first;
        if(s == BluetoothAdapterState.on){
          print("Turned on");
          return true;
        }else{
          print("Please try again");
          return false;
        }
      }
      return true;
    }
  }

  void _onDeviceConnected(String status){
    switch(status) {
      case "WIFI_DEVICE_ADDED":
        updateDevices();
        if (channel == null) {connectToWebSocket();}
        break;
      case "WIFI_DEVICE_RECONNECTED":
        if (channel == null) {connectToWebSocket();}
        break;
      case "WIFI_DEVICE_RECONNECTED_GO3D":
        if (channel == null) {disconnectWebSocket();Navigator.pushNamed(context, '/3dmap');}
        break;
    }
  }

  void _onDeviceClicked(String status, String devid) async{
    switch(status) {
      case "WIFI_DEVICE_CONNECTED":
        connectToWebSocket();
        break;
      case "WIFI_DEVICE_NOT_CONNECTED":
        await RegisterNewDevice(context,_onDeviceConnected).reconnectDialogBuilder(Constants.DEVICE_RECONNECT_MODE,Constants.GO_HERE);
        break;
      case "WIFI_DEVICE_CONNECTED_GO3D":
        disconnectWebSocket();Navigator.pushNamed(context, '/3dmap');
        break;
      case "WIFI_DEVICE_NOT_CONNECTED_GO3D":
        await RegisterNewDevice(context,_onDeviceConnected).reconnectDialogBuilder(Constants.DEVICE_RECONNECT_MODE,Constants.GO_3D);
        break;
      case "BLE_DEVICE_CONNECTED":
        Navigator.pushNamed(context, '/3dmap');
        break;
    }
  }

  Future disconnectWebSocket() async{await channel?.sink.close();}

  void connectToWebSocket() {
    channel = IOWebSocketChannel.connect('ws://192.168.4.1/ws');
    channel!.stream.listen((message) {
      print(message.toString());
      Map<String, dynamic> data = json.decode(message);
      setState(() {
        try {station1Distance = data["state1"];} catch (e) {print("No data");}
        try {station2Distance = data["state2"];} catch (e) {print("No data");}
        try {station3Distance = data["state3"];} catch (e) {print("No data");}
      });
    });
  }



  void _onBLEData(String status , ScanResult result) async {
    print(status);
    if(status== "BLE_DEVICE_FOUND"){
    }
  }

}
