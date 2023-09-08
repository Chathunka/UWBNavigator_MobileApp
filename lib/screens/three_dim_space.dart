import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:uwb_navigator/screens/device_card.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/trilateration_calculator.dart';
import 'package:web_socket_channel/io.dart';

class ThreeDimSpace extends StatefulWidget {
  const ThreeDimSpace({super.key});

  @override
  State<ThreeDimSpace> createState() => _ThreeDimSpaceState();
}

class _ThreeDimSpaceState extends State<ThreeDimSpace> with TickerProviderStateMixin{

  static List<Tab> uwbTabs = <Tab>[
    Tab(child: Row(children: [Icon(Icons.threed_rotation),SizedBox(width: 5,),Text("Perspective view")],)),
    Tab(child: Row(children: [Icon(Icons.looks_two_outlined),SizedBox(width: 5,),Text("Front/Top views")],)),
    //Tab(child: Row(children: [Icon(Icons.border_top_outlined),SizedBox(width: 5,),Text("Perspective")],)),
  ];

  late TabController _tabController;

  IOWebSocketChannel? channel;
  String station1Distance = '0.0'; String station2Distance = '0.0'; String station3Distance = '0.0';

  late double _x = 0.0; double _y = 0.0; double _z = 0.0;

  late List<Sp3dObj> objs = UtilSp3dCommonParts.coordinateArrows(255);
  late Sp3dWorld lastworld;
  late Sp3dWorld world;
  bool isLoaded = false;
  Sp3dCamera? camera;
  Sp3dCamera? cameraTopView;
  Sp3dCamera? cameraFrontView;
  double unitConvertionFactor = 1;

  double xAxisHeight = 200.0;
  double yAxisHeight = 250.0;
  double zAxisHeight = 200.0;
  double stroakwidth = 4;
  double indicatorSize = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController( length: uwbTabs.length, vsync: this);
    connectToWebSocket();
    camera = Sp3dCamera(Sp3dV3D(-200, 350, 1000), 800, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.9);
    cameraTopView = Sp3dCamera(Sp3dV3D(-75, 250, 600), 400, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.3);
    cameraFrontView = Sp3dCamera(Sp3dV3D(-75, 250, 600), 400, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.3);
    objs.addAll(UtilSp3dCommonParts.worldMeshes(255, split: 1));
    addAnchors();
    loadImage();
  }

  void addAnchors(){
    Sp3dObj obj = UtilSp3dGeometry.sphere(5);
    obj.materials[0] = FSp3dMaterial.red.deepCopy()..strokeColor = const Color.fromARGB(255, 255, 0, 0);
    //obj.move(Sp3dV3D(x, z, y));
    obj.move(Sp3dV3D(100, 200, 0));
    objs.add(obj);

    obj = UtilSp3dGeometry.sphere(5);
    obj.materials[0] = FSp3dMaterial.green.deepCopy()..strokeColor = const Color.fromARGB(255, 0, 255, 0);
    obj.move(Sp3dV3D(200, 100, 0));
    objs.add(obj);

    obj = UtilSp3dGeometry.sphere(5);
    obj.materials[0] = FSp3dMaterial.blue.deepCopy()..strokeColor = const Color.fromARGB(255, 0, 0, 255);
    obj.move(Sp3dV3D(0, 200, 200));
    objs.add(obj);
    objs.add(obj);
  }

  void loadImage() async {
    world = Sp3dWorld(objs);
    world.initImages().then((List<Sp3dObj> errorObjs) { setState(() { isLoaded = true; });});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[AppColor.AppBarPrimaryColor, AppColor.secondaryColor]),),),
        elevation: 0.0,
        title: const Text('UWB_Navigator 3D view', style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          TextButton.icon( icon: const Icon(Icons.menu, color: Colors.white,), label: const Text(''), onPressed: () {},),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: uwbTabs,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Container(color: const Color.fromARGB(60, 12, 12, 12),
                  child: Sp3dRenderer(const Size(500, 500), const Sp3dV2D(0, 0), world, camera!, Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true,),
                    onPanUpdate:(update){
                      // setState(() {
                      //   // _offset += Offset(update.diffV.x,update.diffV.y);
                      //   // camera!.rotate(Sp3dV3D(0, 1, 0), _offset.dx * 0.01);
                      //   // if (camera != null) {
                      //   //   camera;
                      //   // }
                      // });
                    },pinchZoomSpeed: 0.02, useClipping: true,
                  ),
                ),
                const SizedBox(height: 10,),
                Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.teal.withAlpha(200),width: 3.0), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Wrap(direction: Axis.horizontal,
                    children: [
                      Row(children: [Text("X : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.withOpacity(0.6)),), Text(_x.toString()),],),
                      Row(children: [Text("Y : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.withOpacity(0.6)),), Text(_y.toString()),],),
                      Row(children: [Text("Z : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.withOpacity(0.6)),), Text(_z.toString()),],),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.all(4),
            child: ListView(
              children: [
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(4),child: Text("Front View"),),
                    Container(color: const Color.fromARGB(60, 12, 12, 12), height: zAxisHeight+50,
                      child: Center(
                        child:Stack(
                          children: [
                            Transform(transform: Matrix4.identity()..translate(0.0,zAxisHeight,0.0), alignment: Alignment.center, child:Container(width: yAxisHeight, height: stroakwidth, color: Colors.red,),),
                            Transform(transform: Matrix4.identity()..translate(0.0,0.0,0.0), alignment: Alignment.center, child: Container(width: stroakwidth, height: zAxisHeight, color: Colors.green,),),
                            Transform(transform: Matrix4.identity()..translate(_y,zAxisHeight-indicatorSize+stroakwidth-_z,0.0), alignment: Alignment.center, child: Container(width: indicatorSize, height: indicatorSize, color: Colors.black,),),
                          ],
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(4),child: Text("Top View"),),
                    Container(color: const Color.fromARGB(60, 12, 12, 12), height: xAxisHeight+50,
                      child: Center(
                        child:Stack(
                          children: [
                            Transform(transform: Matrix4.identity()..translate(0.0,0.0,0.0), alignment: Alignment.center, child:Container(width: yAxisHeight, height: stroakwidth, color: Colors.red,),),
                            Transform(transform: Matrix4.identity()..translate(0.0,0.0,0.0), alignment: Alignment.center, child: Container(width: stroakwidth, height: xAxisHeight, color: Colors.deepPurple,),),
                            Transform(transform: Matrix4.identity()..translate(_y,_x,0.0), alignment: Alignment.center, child: Container(width: indicatorSize, height: indicatorSize, color: Colors.black,),),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.teal.withAlpha(200),width: 3.0), borderRadius: const BorderRadius.all(Radius.circular(5))),
                      child: Wrap(direction: Axis.horizontal,
                        children: [
                          Row(children: [Text("X : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.withOpacity(0.6)),), Text(_x.toString()),],),
                          Row(children: [Text("Y : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.withOpacity(0.6)),), Text(_y.toString()),],),
                          Row(children: [Text("Z : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.withOpacity(0.6)),), Text(_z.toString()),],),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }



  Future disconnectWebSocket() async{await channel?.sink.close();}

  void connectToWebSocket() {
    channel = IOWebSocketChannel.connect('ws://192.168.4.1/ws');
    channel!.stream.listen((message) {print(message.toString());
      Map<String, dynamic> data = json.decode(message);
      setState(() {
        try {station1Distance = data["state1"];} catch (e) {station1Distance = "0.0";print("No data");}
        try {station2Distance = data["state2"];} catch (e) {station2Distance = "0.0";print("No data");}
        try {station3Distance = data["state3"];} catch (e) {station3Distance = "0.0";print("No data");}

        _x = double.parse(station1Distance) * 100;
        _y = double.parse(station2Distance) * 100;
        _z = double.parse(station3Distance) * 100;

        if(_x>0 && _y>0 && _z>0){
          List<double> coordinates = TrilaterationCalculator(W: 100, H: 100, r1: _x, r2: _y, r3: _z,).calculateCoordinates();
          print("Calculated Coordinates (x, y, z): ${coordinates[0]}, ${coordinates[1]}, ${coordinates[2]}");
          _x = coordinates[0]; _y = coordinates[1]; _z = coordinates[2];
        }
        Sp3dObj obj = UtilSp3dGeometry.cube(10, 10, 10, 1, 1, 1);
        obj.materials[0] = FSp3dMaterial.grey.deepCopy()..strokeColor = const Color.fromARGB(255, 0, 0, 0);
        obj.move(Sp3dV3D(_y, _z, _x));
        objs.removeLast();
        objs.add(obj);
        world = Sp3dWorld(objs);
        world.initImages();
      });
    });
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }
}
