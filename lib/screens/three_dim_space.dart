import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/trilateration_calculator.dart';
import 'package:uwb_navigator/utils/trilateration_calculator_vectormode.dart';
import 'package:web_socket_channel/io.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../db/db_provider_local.dart';
import 'package:uwb_navigator/utils/network_status_requester.dart';
import '../utils/ble.dart';

class ThreeDimSpace extends StatefulWidget {
  int id;
  int datamode;
  ThreeDimSpace(this.id, this.datamode, {super.key});
  @override
  State<ThreeDimSpace> createState() => _ThreeDimSpaceState(id,datamode);
}

class _ThreeDimSpaceState extends State<ThreeDimSpace> with TickerProviderStateMixin{
  int id;
  int datamode;
  _ThreeDimSpaceState(this.id,this.datamode);

  static List<Tab> uwbTabs = <Tab>[
    Tab(child: Container(height:20,child: Row(children: [Icon(Icons.threed_rotation),SizedBox(width: 5,),Text("Perspective view")],))),
    Tab(child: Container(height:20,child: Row(children: [Icon(Icons.looks_two_outlined),SizedBox(width: 5,),Text("Front/Top views")],))),
    //Tab(child: Row(children: [Icon(Icons.border_top_outlined),SizedBox(width: 5,),Text("Perspective")],)),
  ];

  late TabController _tabController;

  IOWebSocketChannel? channel;

  IOWebSocketChannel? channelWEB;

  late double _x = 100.0; double _y = 100.0; double _z = 100.0;

  late List<Sp3dObj> objs = UtilSp3dCommonParts.coordinateArrows(255);
  late Sp3dWorld lastworld;
  late Sp3dWorld world;
  bool isLoaded = false;
  Sp3dCamera? camera;
  Sp3dCamera? cameraTopView;
  Sp3dCamera? cameraFrontView;
  double unitConvertionFactor = 1;

  double xAxisHeight = 200.0;
  double yAxisHeight = 240.0;
  double zAxisHeight = 200.0;
  double stroakwidth = 4;
  double indicatorSize = 10;
  double offSet = 10;
  bool trace = false;
  Sp3dV3D previousPoint = Sp3dV3D(0, 0, 0);
  double axis_ratio = 1;

  bool addObjs = false;

  int anchorStartIndex = 0, tableStartIndex = 0, tableEndIndex = 0;

  double x1 = -1.0;double y1 = -1.0;double z1 = -1.0;double x2 = -1.0;double y2 = -1.0;double z2 = -1.0;double x3 = -1.0;double y3 = -1.0;double z3 = -1.0;double x4 = -1.0;double y4 = -1.0;double z4 = -1.0;double x5 = -1.0;double y5 = -1.0;double z5 = -1.0;
  String sx1 = "";String sy1 = "";String sz1 = "";String sx2 = "";String sy2 = "";String sz2 = "";String sx3 = "";String sy3 = "";String sz3 = "";String sx4 = "";String sy4 = "";String sz4 = "";String sx5 = "";String sy5 = "";String sz5 = "";
  bool dataLoaded = false;
  bool worldCreated = false;

  late List<BluetoothService> deviceServices;
  BluetoothDevice constDEV = BluetoothDevice(remoteId: DeviceIdentifier("B0:B2:1C:50:E7:A2"), localName: "UWB_Navigator", type: BluetoothDeviceType.le);

  bool allSet = false;
  bool update = true;
  bool algo1 = true;
  String algoname = "1";

  @override
  void initState() {
    super.initState();
    DBProviderLocal().getDevice(id).then((device) {
      print(device.anchors);
      if(device.anchors.toString() != "{}"){
        var json = jsonDecode(device.anchors.toString());
        setState(() {
          sx1 = json["x1"];sy1 = json["y1"];sz1 = json["z1"];sx2 = json["x2"];sy2 = json["y2"];sz2 = json["z2"];sx3 = json["x3"];sy3 = json["y3"];sz3 = json["z3"];sx5 = json["x5"];sy5 = json["y5"];sz5 = json["z5"];
          x1 = double.parse(sx1);y1 = double.parse(sy1);z1 = double.parse(sz1);x2 = double.parse(sx2);y2 = double.parse(sy2);z2 = double.parse(sz2);x3 = double.parse(sx3);y3 = double.parse(sy3);z3 = double.parse(sz3);x5 = double.parse(sx5);y5 = double.parse(sy5);z5 = double.parse(sz5);
          double max_dimention=0.0;
          if(x5>y5){
            max_dimention = x5;
            if(z5 > max_dimention){
              max_dimention = z5;
            }
          }else{
            max_dimention = y5;
            if(z5 > max_dimention){
              max_dimention = z5;
            }
          }
          print(max_dimention);
          axis_ratio = 250/max_dimention;

          x1 = x1*axis_ratio;x2 = x2*axis_ratio;x3 = x3*axis_ratio;x5 = x5*axis_ratio;
          y1 = y1*axis_ratio;y2 = y2*axis_ratio;y3 = y3*axis_ratio;y5 = y5*axis_ratio;
          z1 = z1*axis_ratio;z2 = z2*axis_ratio;z3 = z3*axis_ratio;z5 = z5*axis_ratio;
          xAxisHeight=x5; yAxisHeight=y5; zAxisHeight=z5;

          addWorld();
          dataLoaded = true;
        });
      }
    });
    _tabController = TabController( length: uwbTabs.length, vsync: this);
    //connectToWebSocket();
    if(datamode == 0) {
      initConnection();
    }else{
      connectToWebSocketWEBAPI();
    }
    camera = Sp3dCamera(Sp3dV3D(-200, 350, 1000), 800, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.9);
    cameraTopView = Sp3dCamera(Sp3dV3D(-75, 250, 600), 400, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.3);
    cameraFrontView = Sp3dCamera(Sp3dV3D(-75, 250, 600), 400, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.3);
  }

  void initConnection() async {
    var network_info = await NetworkInformation().getNetworkInfo();
    if(network_info["Wifi_Name"] == '"UWB_Navigator"') {
      connectToWebSocket();
      allSet = true;
    }else{
      BLE(_onBLEConnected,_onBLEError,id.toString()).checkBLE(constDEV);
      connectToWebSocketWEBAPI();
    }
  }

  void addWorld(){
    objs.addAll(UtilSp3dCommonParts.worldMeshes(255, split: 1));
    Sp3dObj room = createRoom();
    objs.add(room);
    //objs.add(room);
    anchorStartIndex = objs.length;
    addAnchors();
    tableStartIndex = objs.length;
    createTable();
    tableEndIndex = objs.length;
    loadImage();
    print(anchorStartIndex);
    print(tableStartIndex);
    print(tableEndIndex);
    setState(() {worldCreated = true; if(datamode == 1){listenToWebSocketWEBAPI();}});
  }

  void addAnchors(){
    Sp3dObj obj = UtilSp3dGeometry.sphere(5);
    obj.materials[0] = FSp3dMaterial.red.deepCopy()..strokeColor = const Color.fromARGB(255, 255, 0, 0);
    //obj.move(Sp3dV3D(y, z, x));
    obj.move(Sp3dV3D(y1, z1, x1));
    objs.add(obj);

    obj = UtilSp3dGeometry.sphere(5);
    obj.materials[0] = FSp3dMaterial.green.deepCopy()..strokeColor = const Color.fromARGB(255, 0, 255, 0);
    obj.move(Sp3dV3D(y2, z2, x2));
    objs.add(obj);

    obj = UtilSp3dGeometry.sphere(5);
    obj.materials[0] = FSp3dMaterial.blue.deepCopy()..strokeColor = const Color.fromARGB(255, 0, 0, 255);
    obj.move(Sp3dV3D(y3, z3, x3));
    objs.add(obj);
    objs.add(obj);
  }

  Sp3dObj createRoom() {
    // Create a room wireframe
    List<Sp3dV3D> vertices = [
      Sp3dV3D(0, 0, 0),
      Sp3dV3D(y5, 0, 0),
      Sp3dV3D(y5, z5, 0),
      Sp3dV3D(0, z5, 0),
      Sp3dV3D(0, 0, x5),
      Sp3dV3D(y5, 0, x5),
      Sp3dV3D(y5, z5, x5),
      Sp3dV3D(0, z5, x5),
    ];

    Sp3dMaterial material = Sp3dMaterial(
      Colors.cyan.withOpacity(0.1),
      false,
      2.0,
      Colors.cyan,
    );

    List<Sp3dFace> faces = [
      Sp3dFace([0, 1, 2, 3], 0),
      Sp3dFace([3, 2, 1, 0], 0),
      Sp3dFace([4, 5, 1, 0], 0),
      Sp3dFace([0, 1, 5, 4], 0),
      Sp3dFace([7, 4, 0, 3], 0),
      Sp3dFace([3, 0, 4, 7], 0),
      Sp3dFace([1, 2, 6, 5], 0),
      Sp3dFace([5, 6, 2, 1], 0),
      Sp3dFace([2, 3, 7, 6], 0),
      Sp3dFace([6, 7, 3, 2], 0),
      Sp3dFace([4, 5, 6, 7], 0),
      Sp3dFace([7, 6, 5, 4], 0),
    ];

    Sp3dFragment fragment = Sp3dFragment(faces);

    return Sp3dObj(vertices, [fragment], [material], []);
  }

  void createTable() {
    // Define the dimensions of the table
    double tableWidth = 40.0;
    double tableLength = 80.0;
    double tableHeight = 5.0;
    double legWidth = 5.0;
    double legHeight = 20.0;

    // Calculate half dimensions for convenience
    double halfTableWidth = tableWidth / 2;
    double halfTableLength = tableLength / 2;
    double halfTableHeight = tableHeight / 2;

    // Create vertices for the table top
    List<Sp3dV3D> vertices = [
      // Top surface vertices
      Sp3dV3D(-halfTableLength, halfTableHeight, -halfTableWidth),
      Sp3dV3D(-halfTableLength, halfTableHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, halfTableHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, halfTableHeight, -halfTableWidth),
      // Bottom surface vertices (same as top surface but with lower height)
      Sp3dV3D(-halfTableLength, -halfTableHeight, -halfTableWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight, -halfTableWidth),
    ];

    // Create materials
    Sp3dMaterial tableTopMaterial = Sp3dMaterial(
      Colors.transparent,
      false,
      2.0,
      Colors.brown,
    );

    Sp3dMaterial legMaterial = Sp3dMaterial(
      Colors.transparent,
      false,
      2.0,
      Colors.brown,
    );

    // Create faces for the table top
    List<Sp3dFace> tableTopFaces = [
      Sp3dFace([0, 1, 2, 3], 0), // Top surface
      Sp3dFace([4, 5, 6, 7], 0), // Bottom surface
      Sp3dFace([0, 1, 5, 4], 0), // Side 1
      Sp3dFace([1, 2, 6, 5], 0), // Side 2
      Sp3dFace([2, 3, 7, 6], 0), // Side 3
      Sp3dFace([3, 0, 4, 7], 0), // Side 4
    ];

    // Create vertices for the legs
    List<Sp3dV3D> legVertices = [
      // Leg 1
      Sp3dV3D(-halfTableLength, -halfTableHeight, -halfTableWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight, -halfTableWidth + legWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight, -halfTableWidth + legWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight, -halfTableWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight - legHeight, -halfTableWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight - legHeight, -halfTableWidth + legWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight - legHeight, -halfTableWidth + legWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight - legHeight, -halfTableWidth),

      // Leg 2
      Sp3dV3D(-halfTableLength, -halfTableHeight, halfTableWidth - legWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight, halfTableWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight, halfTableWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight, halfTableWidth - legWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight - legHeight, halfTableWidth - legWidth),
      Sp3dV3D(-halfTableLength, -halfTableHeight - legHeight, halfTableWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight - legHeight, halfTableWidth),
      Sp3dV3D(-halfTableLength + legWidth, -halfTableHeight - legHeight, halfTableWidth - legWidth),

      // Leg 3
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight, halfTableWidth - legWidth),
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight, halfTableWidth - legWidth),
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight - legHeight, halfTableWidth - legWidth),
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight - legHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight - legHeight, halfTableWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight - legHeight, halfTableWidth - legWidth),

      // Leg 4
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight, -halfTableWidth),
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight, -halfTableWidth + legWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight, -halfTableWidth + legWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight, -halfTableWidth),
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight - legHeight, -halfTableWidth),
      Sp3dV3D(halfTableLength - legWidth, -halfTableHeight - legHeight, -halfTableWidth + legWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight - legHeight, -halfTableWidth + legWidth),
      Sp3dV3D(halfTableLength, -halfTableHeight - legHeight, -halfTableWidth),
    ];

    // Create faces for the legs
    List<Sp3dFace> legFaces1 = [
      Sp3dFace([0, 1, 2, 3], 0),
      Sp3dFace([4, 5, 6, 7], 0),
      Sp3dFace([0, 1, 5, 4], 0),
      Sp3dFace([1, 2, 6, 5], 0),
      Sp3dFace([2, 3, 7, 6], 0),
      Sp3dFace([3, 0, 4, 7], 0),
    ];

    List<Sp3dFace> legFaces2 = [
      Sp3dFace([0, 1, 2, 3], 0),
      Sp3dFace([4, 5, 6, 7], 0),
      Sp3dFace([0, 1, 5, 4], 0),
      Sp3dFace([1, 2, 6, 5], 0),
      Sp3dFace([2, 3, 7, 6], 0),
      Sp3dFace([3, 0, 4, 7], 0),
    ];

    List<Sp3dFace> legFaces3 = [
      Sp3dFace([0, 1, 2, 3], 0),
      Sp3dFace([4, 5, 6, 7], 0),
      Sp3dFace([0, 1, 5, 4], 0),
      Sp3dFace([1, 2, 6, 5], 0),
      Sp3dFace([2, 3, 7, 6], 0),
      Sp3dFace([3, 0, 4, 7], 0),
    ];

    List<Sp3dFace> legFaces4 = [
      Sp3dFace([0, 1, 2, 3], 0),
      Sp3dFace([4, 5, 6, 7], 0),
      Sp3dFace([0, 1, 5, 4], 0),
      Sp3dFace([1, 2, 6, 5], 0),
      Sp3dFace([2, 3, 7, 6], 0),
      Sp3dFace([3, 0, 4, 7], 0),
    ];

// Create fragments for the table top and legs
    Sp3dFragment tableTopFragment = Sp3dFragment(tableTopFaces);
    Sp3dFragment legFragment1 = Sp3dFragment(legFaces1);
    Sp3dFragment legFragment2 = Sp3dFragment(legFaces2);
    Sp3dFragment legFragment3 = Sp3dFragment(legFaces3);
    Sp3dFragment legFragment4 = Sp3dFragment(legFaces4);

// Create the table top and four legs as separate objects
    Sp3dObj tableTop = Sp3dObj(vertices, [tableTopFragment], [tableTopMaterial], []);
    Sp3dObj leg1 = Sp3dObj(legVertices.sublist(0, 8), [legFragment1], [legMaterial], []);
    Sp3dObj leg2 = Sp3dObj(legVertices.sublist(8, 16), [legFragment2], [legMaterial], []);
    Sp3dObj leg3 = Sp3dObj(legVertices.sublist(16, 24), [legFragment3], [legMaterial], []);
    Sp3dObj leg4 = Sp3dObj(legVertices.sublist(24, 32), [legFragment4], [legMaterial], []);

    // Position the table top and legs
    tableTop.move(Sp3dV3D(100, 20, 75));
    leg1.move(Sp3dV3D(100, 20, 75));
    leg2.move(Sp3dV3D(100, 20, 75));
    leg3.move(Sp3dV3D(100, 20, 75));
    leg4.move(Sp3dV3D(100, 20, 75));

    // Add the table top and legs to a group
    List<Sp3dObj> tableAndLegs = [tableTop, leg1, leg2, leg3, leg4, leg4];

    objs.addAll(tableAndLegs);

  }

  void loadImage() async {
    world = Sp3dWorld(objs);
    world.initImages().then((List<Sp3dObj> errorObjs) { setState(() { isLoaded = true; });});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{Navigator.pushReplacementNamed(context, "/home"); return false;},
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[AppColor.AppBarPrimaryColor, AppColor.secondaryColor]),),),
          elevation: 0.0,
          title: Text('3D View', style: const TextStyle(color: Colors.white),),
          bottom: TabBar(
            tabs: uwbTabs,
            controller: _tabController,
          ),
        ),
        backgroundColor: AppColor.bgColor,
        body: worldCreated ? TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Container(
              color: AppColor.bgColor,
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(color: const Color.fromARGB(255, 255, 255, 255),
                          child: Sp3dRenderer(const Size(500, 500), const Sp3dV2D(0, 0), world, camera!, Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true,),
                            onPanUpdate:(update){
                              // setState(() {
                              //   // _offset += Offset(update.diffV.x,update.diffV.y);
                              //   // camera!.rotate(Sp3dV3D(0, 1, 0), _offset.dx * 0.01);
                              //   // if (camera != null) {
                              //   //   camera;
                              //   // }
                              // });
                            },
                            pinchZoomSpeed: 0.02, useClipping: true,
                            onPanStart: (data){setState(() {update = false;});},
                            onPanEnd: (data){setState(() {update = true;});},
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
                  Align(alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: (){
                              setState(() {
                                print(objs.length);
                                  objs.removeRange(tableStartIndex, objs.length);
                                  world = Sp3dWorld(objs);
                                  world.initImages();
                              });
                            },
                            child: Text("Clear All"),
                          ),
                          ElevatedButton(
                            onPressed: (){
                              setState(() {
                                if(algo1){
                                  algo1 = false;
                                  algoname = "2";
                                }else{
                                  algo1 = true;
                                  algoname = "1";
                                }
                              });
                            },
                            child: Text(algoname),
                          ),
                        ],
                      ),
                    )
                  )
                ],
              ),
            ),
            Container(padding: const EdgeInsets.all(4),color: AppColor.bgColor,
              child: SingleChildScrollView(
                child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(4),child: Text("Front View"),),
                      Container(color: const Color.fromARGB(255, 255, 255, 255), height: zAxisHeight+50,
                        child: Center(
                          child:Stack(
                            children: [
                              Transform(transform: Matrix4.identity()..translate(0.0,60,0.0),
                                alignment: Alignment.center,
                                child:Image.asset('assets/images/frontview.jpg', width: 250),
                              ),

                              Transform(transform: Matrix4.identity()..translate(0.0,zAxisHeight+offSet,0.0), alignment: Alignment.center, child:Container(width: yAxisHeight+offSet, height: stroakwidth, color: Colors.red,),),
                              Transform(transform: Matrix4.identity()..translate(0.0,offSet,0.0), alignment: Alignment.center, child:Container(width: yAxisHeight, height: stroakwidth-2, color: Colors.teal,),),
                              Transform(transform: Matrix4.identity()..translate(0.0,0.0,0.0), alignment: Alignment.center, child: Container(width: stroakwidth, height: zAxisHeight+offSet, color: Colors.green,),),
                              Transform(transform: Matrix4.identity()..translate(yAxisHeight,offSet,0.0), alignment: Alignment.center, child: Container(width: stroakwidth-2, height: zAxisHeight, color: Colors.teal,),),
                              Transform(transform: Matrix4.identity()..translate(_y,zAxisHeight-indicatorSize+stroakwidth-_z+offSet,0.0), alignment: Alignment.center, child: Container(width: indicatorSize, height: indicatorSize, color: Colors.black,),),
                            ],
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(4),child: Text("Top View"),),
                      Container(color: const Color.fromARGB(255, 255, 255, 255), height: xAxisHeight+50,
                        child: Center(
                          child:Stack(
                            children: [
                              Image.asset('assets/images/topview.jpg', width: 250),
                              Transform(transform: Matrix4.identity()..translate(0.0,0.0,0.0), alignment: Alignment.center, child:Container(width: yAxisHeight+offSet, height: stroakwidth, color: Colors.red,),),
                              Transform(transform: Matrix4.identity()..translate(0.0,xAxisHeight+stroakwidth-2,0.0), alignment: Alignment.center, child:Container(width: yAxisHeight, height: stroakwidth-2, color: Colors.teal,),),
                              Transform(transform: Matrix4.identity()..translate(0.0,0.0,0.0), alignment: Alignment.center, child: Container(width: stroakwidth, height: xAxisHeight+offSet, color: Colors.deepPurple,),),
                              Transform(transform: Matrix4.identity()..translate(yAxisHeight,stroakwidth,0.0), alignment: Alignment.center, child: Container(width: stroakwidth-2, height: xAxisHeight, color: Colors.teal,),),
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
              ),
            )
          ],
        ): Container(),
        bottomNavigationBar: ConvexAppBar(
            backgroundColor: AppColor.primaryColor,
            initialActiveIndex: 1,
            disableDefaultTabController: true,
            style: TabStyle.fixedCircle,
            height: 55,
            items: [
              const TabItem(icon: Icons.home, title: 'Home'),
              TabItem(icon: trace ? const Icon(Icons.fiber_manual_record_sharp, color: Colors.red, size: 35,) : const Icon(Icons.pause, color: Colors.red, size: 35,), title: 'Trace'),
              const TabItem(icon: Icons.settings, title: 'Config'),
            ],
            onTap: (int i) async{
              switch(i) {
                case 0 :
                  Navigator.pushReplacementNamed(context, "/home");
                  break;
                case 1 :
                    setState(() {if(trace){trace = false;}else{trace = true;}});
                  break;
                case 2 :
                  Map<String,int> args = {"devid":id, "mode": datamode};
                  Navigator.pushReplacementNamed(context, "/deviceConfig",arguments: args,);
                  break;
              }
            }
        ),
      ),
    );
  }

  Sp3dObj createLine(Sp3dV3D startPoint, Sp3dV3D endPoint, Color lineColor, double strokeWidth) {
    List<Sp3dV3D> vertices = [startPoint, endPoint];
    Sp3dMaterial material = Sp3dMaterial(
      Colors.transparent, // Background color (not used for stroke)
      false, // isFill
      strokeWidth, // Stroke width
      lineColor, // Stroke color
    );
    Sp3dFace face = Sp3dFace([0, 1], 0);
    Sp3dFragment fragment = Sp3dFragment([face]);
    return Sp3dObj(vertices, [fragment], [material], []);
  }

  Future disconnectWebSocket() async{await channel?.sink.close();}

  void connectToWebSocket() {
    channel = IOWebSocketChannel.connect('ws://192.168.4.1/ws');
    print("Connecting to web socket");
    channel!.stream.listen((message) async{
      String station1Distance = '0.0'; String station2Distance = '0.0'; String station3Distance = '0.0';
      print(message.toString());
      Map<String, dynamic> data = json.decode(message);
        try {station1Distance = data["state1"];} catch (e) {station1Distance = "0.0";print("No data");}
        try {station2Distance = data["state2"];} catch (e) {station2Distance = "0.0";print("No data");}
        try {station3Distance = data["state3"];} catch (e) {station3Distance = "0.0";print("No data");}

        plotPointer(double.parse(station1Distance), double.parse(station2Distance), double.parse(station3Distance),false,true);
    });
  }

  void connectToBLE() async{
    deviceServices = await constDEV.discoverServices(timeout: 20);
    for (BluetoothService service in deviceServices){
      if(service.serviceUuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
        allSet = true;
        print(service.serviceUuid);
        for (BluetoothCharacteristic characteristic in service.characteristics){
          if(characteristic.characteristicUuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a7"){
            print(characteristic.characteristicUuid.toString());
            characteristic.onValueReceived.listen((value) {String data = utf8.decode(value).toString();
              final parts = data.split(',');
              if(parts[0].toString() == "n" || parts[0].toString() == "") {parts[0] = "0.0";}
              if(parts[1].toString() == "n" || parts[1].toString() == "") {parts[1] = "0.0";}
              if(parts[2].toString() == "n" || parts[2].toString() == "") {parts[2] = "0.0";}
              plotPointer(double.parse(parts[0]), double.parse(parts[1]), double.parse(parts[2]),true,true);
            });
            await characteristic.setNotifyValue(true);
          }
        }
      }
    }
  }

  void plotPointer(double r1, double r2, double r3, bool sendCloud , bool calculate){
    if(update) {
      setState(() {
        if(calculate) {
          _x = r1 * 100 * axis_ratio;
          _y = r2 * 100 * axis_ratio;
          _z = r3 * 100 * axis_ratio;

          if (algo1) {
            if (_x > 0 && _y > 0 && _z > 0) {
              // List<double> coordinates = TrilaterationCalculator(W: 100, L: 100, r1: _x, r2: _y, r3: _z,).calculateCoordinates();
              List<double> coordinates = TrilaterationCalculator(W: x5, L: y5, r1: _x, r2: _y, r3: _z,).calculateCoordinates();
              print("Calculated Coordinates (x, y, z): ${coordinates[0]}, ${coordinates[1]}, ${coordinates[2]}");
              print("");
              if (_x > 0 && _y > 0 && _z > 0) {_x = coordinates[0];_y = coordinates[1];_z = coordinates[2];}
            }
          } else {
            if (_x > 0 && _y > 0 && _z > 0) {List<double> vec1 = [x1, y1, z1];List<double> vec2 = [x2, y2, z2];List<double> vec3 = [x3, y3, z3];
              List coordinates = TrilaterationCalculatorVectormode().GetCoordinates(vec1, vec2, vec3, _x, _y, _z, x5, y5, z5);
              print("Calculated Coordinates (x, y, z): ${coordinates[0][0]}, ${coordinates[0][1]}, ${coordinates[0][2]}");
              print("");
              if (_x > 0 && _y > 0 && _z > 0) {_x = coordinates[0][0];_y = coordinates[0][1];_z = coordinates[0][2];}
            }
          }
        }else{
          _x = r1;
          _y = r2;
          _z = r3;
        }

        if(sendCloud) {
          channelWEB!.sink.add("{\"devID\": \"0xc201\",\"x\":" + _x.toString() + ",\"y\":" + _y.toString() + ",\"z\":" + _z.toString() + "}");
        }

        objs.removeLast();

        if (trace) {print("tracing");
          if (previousPoint == Sp3dV3D(0, 0, 0)) {previousPoint = Sp3dV3D(_y, _z, _x);}
          else {Sp3dV3D endPoint = Sp3dV3D(_y, _z, _x);Sp3dObj line = createLine(previousPoint, endPoint, Colors.red, 2.0);objs.add(line);previousPoint = endPoint;}
        }else{previousPoint = Sp3dV3D(_y, _z, _x);}

        Sp3dObj obj = UtilSp3dGeometry.cube(10, 10, 10, 1, 1, 1);
        obj.materials[0] = FSp3dMaterial.grey.deepCopy()
          ..strokeColor = const Color.fromARGB(255, 0, 0, 0);
        obj.move(Sp3dV3D(_y-5, _z-5, _x-5));
        objs.add(obj);
        world = Sp3dWorld(objs);
        world.initImages();
      });
    }
  }

  Future disconnectWebSocketWEBAPI() async{await channelWEB?.sink.close();}

  void connectToWebSocketWEBAPI() {
    print("UWB_Navigator: Connecting to web app websocket");
    channelWEB = IOWebSocketChannel.connect(GlobalVariables.BASE_URL_WEB_SOCKET);
    print("Connecting to web socket");
  }

  void listenToWebSocketWEBAPI(){
    channelWEB!.stream.listen((message) async{
      String station1Distance = '0.0'; String station2Distance = '0.0'; String station3Distance = '0.0';
      print(message.toString());
      Map<String, dynamic> data = json.decode(message);
      print(data["devID"]);
      try {station1Distance = data["x"].toString();} catch (e) {station1Distance = "0.0";print("No data");}
      try {station2Distance = data["y"].toString();} catch (e) {station2Distance = "0.0";print("No data");}
      try {station3Distance = data["z"].toString();} catch (e) {station3Distance = "0.0";print("No data");}
      print("Data");
      print(station1Distance);
      print(station2Distance);
      print(station3Distance);

      plotPointer(double.parse(station1Distance), double.parse(station2Distance), double.parse(station3Distance),false,false);
    });
  }

  void _onBLEConnected(String status, BluetoothDevice device, String devid) async{
    switch(status) {
      case "BLEDEVICECONNECTED":
        connectToBLE();
        break;
      case "BLEDEVICENOTCONNECTED":
        print("");
        break;
    }
  }

  void _onBLEError(String status, String devid) async{
    switch(status) {
      case "BLESCANRESULTTIMEOUT":
        break;
    }
  }

  @override
  void dispose() {
    disconnectWebSocket();
    disconnectWebSocketWEBAPI();
    super.dispose();
  }
}
