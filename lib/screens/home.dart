import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uwb_navigator/db/db_provider_local.dart';
import 'package:uwb_navigator/screens/device_card.dart';
import 'package:uwb_navigator/screens/user_guide.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/register_new_device.dart';
import '../models/device.dart';
import 'package:web_socket_channel/io.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:uwb_navigator/utils/network_status_requester.dart';
import '../utils/ble.dart';


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
    updateDevices(true);
  }

  void updateDevices(bool initial){
    DBProviderLocal().getAllDevices().then((devices) {
      setState(() {_devices = devices.cast<Device>();if(_devices == null){}else{deviceController.value=true;userGuidController.value=false;}});
    });
  }

  @override
  void dispose() {
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: AppBar(
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[AppColor.AppBarPrimaryColor, AppColor.secondaryColor]))),
          elevation: 0.0,
          title: Text('UWB_Navigator', style: TextStyle(color: Colors.white),),
        ),
        body: Container(
          child: _devices == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  ExpandablePanel(theme: const ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center, tapBodyToExpand: true, tapBodyToCollapse: true, hasIcon: false, ),
                    controller: userGuidController,
                    header: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
                      child: Container(padding: EdgeInsets.all(8), color: AppColor.colorOne,
                        child: Stack(children: <Widget>[
                          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: <Color>[AppColor.colorOne, AppColor.colorOne, AppColor.colorOne],),),),),
                          Row(
                            children: [
                              ExpandableIcon(theme: const ExpandableThemeData(expandIcon: Icons.arrow_right, collapseIcon: Icons.arrow_drop_down, iconColor: Colors.white, iconSize: 28.0, iconRotationAngle: pi / 2, iconPadding: EdgeInsets.only(right: 5), hasIcon: false,)),
                              const SizedBox(width: 10,), const Icon(Icons.list_alt,color: Colors.white,size: 28,), const SizedBox(width: 10,), const Text("UWB Navigator User Guide",style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    collapsed: Container(height: 20, decoration: BoxDecoration(border: Border.all(color: AppColor.colorOne,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),),
                    expanded: Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColor.colorOne,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),
                      child: Padding(padding: const EdgeInsets.all(16.0),
                        child: UserGuid(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ExpandablePanel(theme: const ExpandableThemeData(headerAlignment: ExpandablePanelHeaderAlignment.center, tapBodyToExpand: true, tapBodyToCollapse: true, hasIcon: false,),
                    controller: deviceController,
                    header: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
                      child: Container(padding: EdgeInsets.all(8), color: AppColor.colorTwo,
                        child: Column(
                          children: [
                            Stack(children: <Widget>[
                              Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: <Color>[AppColor.colorTwo, AppColor.colorTwo, AppColor.colorTwo,],),),),),
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
                    ),
                    collapsed: Container(height: 20, decoration: BoxDecoration(border: Border.all(color: AppColor.colorTwo,width: 3), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),),
                    expanded: Container(height: 330,
                      decoration: BoxDecoration(border: Border.all(color: AppColor.colorTwo,width: 3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10) ),),
                      child: _devices!.length == 0
                          ? const Padding(padding: EdgeInsets.all(16.0), child: const Center(child: Text("You have no devices currently. Please click (+) button to add new device.")),)
                          : Padding(padding: const EdgeInsets.all(8),
                        child: ListView.builder(itemCount: _devices!.length,
                          itemBuilder: (BuildContext context, int index) {
                            Device item = _devices![index];
                            return Dismissible(key: UniqueKey(),
                              child: Padding(padding: const EdgeInsets.only(top: 8),
                                child: DeviceCard(id: item.id.toString(), name: item.name!, anchors: item.anchors!, onButtonClick:_onDeviceButtonClicked,),
                              ),
                              onDismissed: (direction) async{await DBProviderLocal().deleteDevice(item.id!);updateDevices(false);},
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
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: AppColor.primaryColor,
          initialActiveIndex: 1,
          disableDefaultTabController: true,
          height: 55,
          style: TabStyle.fixedCircle,
          items: [
              TabItem(icon: Icons.threed_rotation, title: 'Demo'),
              TabItem(icon: Icons.add, title: 'Add'),
              TabItem(icon: Icons.people, title: 'Profile'),
            ],
        onTap: (int i) async{
            switch(i) {
              case 1 :
                Map<Permission, PermissionStatus> statuses = await [Permission.location, Permission.locationWhenInUse, Permission.camera, Permission.bluetoothConnect,].request();
                if(statuses[Permission.camera] == PermissionStatus.granted && statuses[Permission.location] == PermissionStatus.granted && statuses[Permission.locationWhenInUse] == PermissionStatus.granted && statuses[Permission.bluetoothConnect] == PermissionStatus.granted){
                  if(await CheckBluetooth()) {await RegisterNewDevice(context,_onDeviceConnected).dialogBuilder(Constants.DEVICE_CONNECT_MODE);}
                }else{permissionAlertBuilder(context);}
                break;
              case 0 :
                Navigator.pushReplacementNamed(context, '/3dspiral');
                break;
              case 2 :
                break;
            }
        }
      ),
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

  void _onDeviceConnected(String status, String devid){
    print("..........................On device connected: " + status + " devid: " + devid);
    switch(status) {
      case "WIFI_DEVICE_ADDED":
        updateDevices(false);
        break;
      case "WIFI_DEVICE_RECONNECTED_GO3D":
        routeTo3D(devid,Constants.WIFI_MODE,0);
        break;
      case "BLE_DEVICE_ADDED":
        updateDevices(false);
        break;
      case "BLE_DEVICE_RECONNECTED_GO3D":
        routeTo3D(devid,Constants.BLE_MODE,0);
        break;
    }
  }

  void _onDeviceButtonClicked(String status, String devid) async{
    switch(status) {
      case "GO3D_CLICKED":
        kShowSnackBar(context, "Checking for device availability(Wi-Fi)...");
        var network_info = await NetworkInformation().getNetworkInfo();
        if(network_info["Wifi_Name"] == '"UWB_Navigator"') {
          routeTo3D(devid,Constants.WIFI_MODE, 0);
        }else{
          kShowSnackBar(context, "Checking for device availability(BLE)...");
          BluetoothDevice constDEV = BluetoothDevice(remoteId: DeviceIdentifier("B0:B2:1C:50:E7:A2"), localName: "UWB_Navigator", type: BluetoothDeviceType.le);
          BLE(_onBLEConnected,_onBLEError,devid).checkBLE(constDEV);
        }
        break;
      case "ONLINE_CLICKED":
        routeTo3D(devid,Constants.WIFI_MODE, 1);
        break;
    }
  }

  void _onBLEConnected(String status, BluetoothDevice device, String devid) async{
    switch(status) {
      case "BLESCANRESULT":
        BLE(_onBLEConnected,_onBLEError,devid).connectBLE(device);
        break;
      case "BLEDEVICECONNECTED":
        routeTo3D(devid,Constants.BLE_MODE,0);
        break;
      case "BLEDEVICENOTCONNECTED":
        await RegisterNewDevice(context,_onDeviceConnected).reconnectDialogBuilder(Constants.DEVICE_RECONNECT_MODE,devid);
        break;
    }
  }

  void _onBLEError(String status, String devid) async{
    switch(status) {
      case "BLESCANRESULTTIMEOUT":
        print("BLE device NOT FOUND on device card attempting to connect................................");
        await RegisterNewDevice(context,_onDeviceConnected).reconnectDialogBuilder(Constants.DEVICE_RECONNECT_MODE,devid);
        break;
    }
  }

  void routeTo3D(String devid, bool wifiy, int mode){
    DBProviderLocal().getDevice(int.parse(devid)).then((device) {
      print(device.anchors);
      Map<String,int> args = {"devid":device.id!, "mode": mode};
      if(device.anchors.toString() == "{}"){
        print("Anchors are empty. Set them first to complete the config");
        Navigator.pushReplacementNamed(context,"/deviceConfig",arguments: args,);
      }else{
        print("Anchors Already Set");
        Navigator.pushReplacementNamed(context,'/3dmap',arguments: args,);
      }
    });
  }

  void kShowSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
        SnackBar(
          backgroundColor: AppColor.white,
        content: Container(padding:EdgeInsets.all(32), child: Text(message,style: TextStyle(color: AppColor.primaryColor),)),
        duration: const Duration(seconds: 2),
        )
    );
  }
}
