import 'dart:convert';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:uwb_navigator/shared/variables.dart';

import '../db/db_provider_local.dart';
import '../models/device.dart';

class DeviceConfigure extends StatefulWidget {
  int _DEVID;
  int datamode;
  DeviceConfigure(this._DEVID, this.datamode, {super.key});

  @override
  State<DeviceConfigure> createState() => _DeviceConfigureState(_DEVID,datamode);
}

class _DeviceConfigureState extends State<DeviceConfigure> {
  int _DEVID;
  int datamode;
  _DeviceConfigureState(this._DEVID, this.datamode);
  double x1 = -1.0;double y1 = -1.0;double z1 = -1.0;double x2 = -1.0;double y2 = -1.0;double z2 = -1.0;double x3 = -1.0;double y3 = -1.0;double z3 = -1.0;double x4 = -1.0;double y4 = -1.0;double z4 = -1.0;double x5 = -1.0;double y5 = -1.0;double z5 = -1.0;
  String sx1 = "";String sy1 = "";String sz1 = "";String sx2 = "";String sy2 = "";String sz2 = "";String sx3 = "";String sy3 = "";String sz3 = "";String sx4 = "";String sy4 = "";String sz4 = "";String sx5 = "";String sy5 = "";String sz5 = "";
  bool dataLoaded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DBProviderLocal().getDevice(_DEVID).then((device) {
        print(device.anchors);
        if(device.anchors.toString() != "{}"){
          var json = jsonDecode(device.anchors.toString());
          setState(() {
            sx1 = json["x1"];sy1 = json["y1"];sz1 = json["z1"];sx2 = json["x2"];sy2 = json["y2"];sz2 = json["z2"];sx3 = json["x3"];sy3 = json["y3"];sz3 = json["z3"];sx5 = json["x5"];sy5 = json["y5"];sz5 = json["z5"];
            x1 = double.parse(sx1);y1 = double.parse(sy1);z1 = double.parse(sz1);x2 = double.parse(sx2);y2 = double.parse(sy2);z2 = double.parse(sz2);x3 = double.parse(sx3);y3 = double.parse(sy3);z3 = double.parse(sz3);x5 = double.parse(sx5);y5 = double.parse(sy5);z5 = double.parse(sz5);
          });
        }
        setState(() {dataLoaded = true;});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{Navigator.pushReplacementNamed(context, "/home"); return false;},
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[AppColor.AppBarPrimaryColor, AppColor.secondaryColor]),),),
          elevation: 0.0,
          title: Text('Device Configurations', style: TextStyle(color: Colors.white),),
        ),
        body: dataLoaded ? SingleChildScrollView(
          child: Container(color: AppColor.bgColor,padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Center(
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20.0,),
                      const Text('Anchor 1 coordinates:(cm)', style: TextStyle(color: Colors.black),),
                      const SizedBox(height: 10.0,),
                      Container(color: AppColor.white,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("X:",style: TextStyle(color: Colors.deepPurple),), Container( width: 100, child: TextFormField(initialValue:sx1, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) x1 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "x"),),),
                            const Text("Y:",style: TextStyle(color: Colors.red),),        Container( width: 100, child: TextFormField(initialValue:sy1, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) y1 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "y"),),),
                            const Text("Z:",style: TextStyle(color: Colors.green),),      Container( width: 100, child: TextFormField(initialValue:sz1, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) z1 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "z"),),),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0,),
                      const Text('Anchor 2 coordinates:(cm)', style: TextStyle(color: Colors.black),),
                      const SizedBox(height: 10.0,),
                      Container(color: AppColor.white,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("X:",style: TextStyle(color: Colors.deepPurple),), Container( width: 100, child: TextFormField(initialValue:sx2, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) x2 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "x"),),),
                            const Text("Y:",style: TextStyle(color: Colors.red),),        Container( width: 100, child: TextFormField(initialValue:sy2, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) y2 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "y"),),),
                            const Text("Z:",style: TextStyle(color: Colors.green),),      Container( width: 100, child: TextFormField(initialValue:sz2, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) z2 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "z"),),),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0,),
                      const Text('Anchor 3 coordinates:(cm)', style: TextStyle(color: Colors.black),),
                      const SizedBox(height: 10.0,),
                      Container(color: AppColor.white,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("X:",style: TextStyle(color: Colors.deepPurple),), Container( width: 100, child: TextFormField(initialValue:sx3, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) x3 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "x"),),),
                            const Text("Y:",style: TextStyle(color: Colors.red),),        Container( width: 100, child: TextFormField(initialValue:sy3, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) y3 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "y"),),),
                            const Text("Z:",style: TextStyle(color: Colors.green),),      Container( width: 100, child: TextFormField(initialValue:sz3, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) z3 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "z"),),),
                          ],
                        ),
                      ),

                      // const SizedBox(height: 30.0,),
                      // const Text('Anchor 4 coordinates:(cm)', style: TextStyle(color: Colors.black),),
                      // const SizedBox(height: 10.0,),
                      // Container(color: AppColor.white,
                      //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       const Text("X:",style: TextStyle(color: Colors.deepPurple),),
                      //       Container( width: 100,
                      //         child: TextFormField(onChanged: (s) {if (s.isNotEmpty) x4 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "x"),),
                      //       ),
                      //       const Text("Y:",style: TextStyle(color: Colors.red),),
                      //       Container( width: 100,
                      //         child: TextFormField(onChanged: (s) {if (s.isNotEmpty) y4 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "y"),),
                      //       ),
                      //       const Text("Z:",style: TextStyle(color: Colors.green),),
                      //       Container( width: 100,
                      //         child: TextFormField(onChanged: (s) {if (s.isNotEmpty) z4 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "z"),),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 30.0,),
                      const Text('Room Dimensions:(cm)', style: TextStyle(color: Colors.black),),
                      const SizedBox(height: 10.0,),
                      Container(color: AppColor.white,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("W:",style: TextStyle(color: Colors.deepPurple),), Container( width: 100, child: TextFormField(initialValue:sx5, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) x5 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "x"),),),
                            const Text("L:",style: TextStyle(color: Colors.red),),        Container( width: 100, child: TextFormField(initialValue:sy5, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) y5 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "y"),),),
                            const Text("H:",style: TextStyle(color: Colors.green),),      Container( width: 100, child: TextFormField(initialValue:sz5, keyboardType:TextInputType.number,onChanged: (s) {if (s.isNotEmpty) z5 = double.tryParse(s)!;}, decoration: const InputDecoration(hintText: "z"),),),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ): Container(),

        bottomNavigationBar: ConvexAppBar(
            backgroundColor: Colors.teal,
            initialActiveIndex: 0,
            disableDefaultTabController: true,
            height: 60,
            style: TabStyle.fixedCircle,
            items: [
              TabItem(icon: Icons.save_alt_outlined, title: 'Save'),
            ],
            onTap: (int i) async{
              switch(i) {
                case 0 :
                  if(x1>-1 && y1> -1 && z1 >-1 && x2>-1 && y2> -1 && z2 >-1 && x3>-1 && y3> -1 && z3 >-1  && x5>-1 && y5> -1 && z5 >-1){
                    String anchor = "{\"x1\":\"$x1\",\"y1\":\"$y1\",\"z1\":\"$z1\",\"x2\":\"$x2\",\"y2\":\"$y2\",\"z2\":\"$z2\",\"x3\":\"$x3\",\"y3\":\"$y3\",\"z3\":\"$z3\",\"x5\":\"$x5\",\"y5\":\"$y5\",\"z5\":\"$z5\"}";
                    Device dev = Device(id: _DEVID, name: "Tag", anchors: anchor,);
                    await DBProviderLocal().updatetDevice(dev);
                    DBProviderLocal().getDevice(_DEVID).then((device) {
                      print(device.anchors);
                      if(device.anchors.toString() == "{}"){
                        print("Anchors are empty set them first to complete the config");
                        Navigator.pushReplacementNamed(context, "/deviceConfig",arguments: device.id,);
                      }else{
                        Map<String,int> args = {"devid":device.id!, "mode": datamode};
                        Navigator.pushReplacementNamed(context, '/3dmap', arguments: args,);
                      }
                    });
                  }else{
                    showDialog<String>(context: context, builder: (BuildContext context) => AlertDialog(
                        title: Container(width: double.infinity, padding: const EdgeInsets.all(4),color: AppColor.errorRed, child: const Center(child: Text('Alert...'))),
                        content: Container(padding: EdgeInsets.all(4),child: const Text('Please specify all the vales to continue...')),
                        actions: <Widget>[
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ),
                        ],
                      ),);
                  }
                  break;
              }
            }
        ),
      ),
    );
  }
}
