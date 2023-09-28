import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class ThreeDimSpiral extends StatefulWidget {
  const ThreeDimSpiral({Key? key}) : super(key: key);

  @override
  _ThreeDimSpiralState createState() => _ThreeDimSpiralState();
}

class _ThreeDimSpiralState extends State<ThreeDimSpiral> {
  late Timer _timer;

  List<Sp3dObj> objs = [];
  late Sp3dWorld world;
  bool isLoaded = false;

  Sp3dCamera? camera;

  int loopcount = 0;
  int heightcount = 0;
  Sp3dV3D previousPoint = Sp3dV3D(0, 0, 0);

  double _x = 0, _y = 0, _z = 0;


  @override
  void initState() {
    super.initState();
    //camera = Sp3dCamera(Sp3dV3D(350, -50, 1000), 800, radian: 0.3);
    camera = Sp3dCamera(Sp3dV3D(-200, 350, 1000), 800, rotateAxis: Sp3dV3D(0, 1, 0), radian: -0.9);
    objs.addAll(UtilSp3dCommonParts.coordinateArrows(255));
    objs.addAll(UtilSp3dCommonParts.worldMeshes(255, split: 1));

    // Create a room
    Sp3dObj room = createRoom();
    objs.add(room);
    objs.add(room);

    loadImage();
    _timer = Timer.periodic(Duration(milliseconds: 2), (timer) {
      createSpiral();
    });
  }

  Sp3dObj createRoom() {
    // Create a room wireframe
    List<Sp3dV3D> vertices = [
      Sp3dV3D(0, 0, 0),
      Sp3dV3D(250, 0, 0),
      Sp3dV3D(250, 200, 0),
      Sp3dV3D(0, 200, 0),
      Sp3dV3D(0, 0, 200),
      Sp3dV3D(250, 0, 200),
      Sp3dV3D(250, 200, 200),
      Sp3dV3D(0, 200, 200),
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  // Future<void> load3DOBJ()async {
  //   try {
  //     final path = await _localPath;
  //     print(path.toString());
  //     final contents = File('$path/assets/images/box.txt').readAsString();
  //     print (contents);
  //   } catch (e) {
  //     print('Error loading 3D model: $e');
  //   }
  // }

  void loadImage() async {
    world = Sp3dWorld(objs);
    await world.initImages();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{Navigator.pushReplacementNamed(context, "/home"); return false;},
      child: Scaffold(
        appBar: AppBar(
          title: Text('3D Map'),
        ),
        body: isLoaded
            ? Container(
              padding: EdgeInsets.all(4),
              color: AppColor.bgColor,
              child: Column(
                children: [
                  Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Sp3dRenderer(const Size(500, 500), const Sp3dV2D(0, 0), world, camera!, Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true,),
                      onPanUpdate:(update){
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
                // setState(() {
                //   // _offset += Offset(update.diffV.x,update.diffV.y);
                //   // camera!.rotate(Sp3dV3D(0, 1, 0), _offset.dx * 0.01);
                //   // if (camera != null) {
                //   //   camera;
                //   // }
                // });
              ),
            )
            : const Center(
              child: CircularProgressIndicator(),
            ),
        bottomNavigationBar: ConvexAppBar(
            backgroundColor: AppColor.primaryColor,
            initialActiveIndex: 1,
            disableDefaultTabController: true,
            style: TabStyle.fixedCircle,
            height: 55,
            items: const [
              TabItem(icon: Icons.home, title: 'Home'),
              TabItem(icon: Icons.threed_rotation, title: '3D demo'),
              TabItem(icon: Icons.abc_outlined, title: 'Tutorial'),
            ],
            onTap: (int i) async{
              switch(i) {
                case 0 :
                  Navigator.pushReplacementNamed(context, "/home");
                  break;
                case 1 :
                  _timer.cancel();
                  Navigator.pushReplacementNamed(context, '/3dspiral');
                  break;
              }
            }
        ),
      ),
    );
  }

  void createSpiral() {
    setState(() {
      loopcount++;
      heightcount++;
      int numPoints = 20;
      double radius = 50.0;
      double height = 2;
      objs.removeLast();
      if (loopcount > numPoints) {loopcount = 1;}
      double angle = 2 * pi * loopcount / numPoints;
      double y = radius * cos(angle) + 100; // center of room
      double z = radius * sin(angle) + 100; // center of room
      double x = height * heightcount * 0.5;
      setState(() {_x = x; _y = y; _z = z;});
      if(x>250){_timer.cancel();}
      Sp3dV3D endPoint = Sp3dV3D(x, y, z);
      Sp3dObj line = createLine(previousPoint, endPoint, Colors.red, 2.0);
      objs.add(line);
      previousPoint = endPoint;
      Sp3dObj pointer = UtilSp3dGeometry.sphere(10);
      pointer.materials[0] = FSp3dMaterial.blueNonWire.deepCopy();
      pointer.move(Sp3dV3D(x, y, z)); // Move the pointer to the current position
      objs.add(pointer); // Add the pointer to the objs list
      world = Sp3dWorld(objs);
      world.initImages();
    });
  }


  Sp3dObj createLine(
      Sp3dV3D startPoint, Sp3dV3D endPoint, Color lineColor, double strokeWidth) {
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
