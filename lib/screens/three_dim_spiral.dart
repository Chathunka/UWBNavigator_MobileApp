import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    camera = Sp3dCamera(Sp3dV3D(350, -50, 1000), 800, radian: 0.3);
    objs.addAll(UtilSp3dCommonParts.coordinateArrows(255));
    objs.addAll(UtilSp3dCommonParts.worldMeshes(255, split: 1));
    loadImage();
    load3DOBJ();
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      createSpiral();
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  Future<void> load3DOBJ()async {
    try {
      final path = await _localPath;
      print(path.toString());
      final contents = File('$path/assets/images/box.txt').readAsString();
      print (contents);
    } catch (e) {
      print('Error loading 3D model: $e');
    }
  }

  void loadImage() async {
    world = Sp3dWorld(objs);
    await world.initImages();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<String> loadAsset(BuildContext context) async {
      return await DefaultAssetBundle.of(context).loadString('assets/images/box.txt');
    }
    var data = loadAsset(context);
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Map'),
      ),
      body: isLoaded
          ? Column(
            children: [
              Container(
                color: const Color.fromARGB(60, 12, 12, 12),
                child: Sp3dRenderer(
                  Size(500, 500),
                  Sp3dV2D(400, 400),
                  world,
                  camera!,
                  Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
                ),
              ),
            ],
          )
          : Center(
            child: CircularProgressIndicator(),
          ),
    );
  }

  void createSpiral() {
    setState(() {
      loopcount++;
      heightcount++;
      int numPoints = 10;
      double radius = 50.0;
      double height = 2;

      objs.removeLast();

      if (loopcount > numPoints) {
        loopcount = 1;
        //objs.removeRange(2, objs.length); // Remove previous spiral lines
      }

      double angle = 2 * pi * loopcount / numPoints;
      double y = radius * cos(angle);
      double z = radius * sin(angle);
      double x = height * heightcount / 2;

      Sp3dV3D endPoint = Sp3dV3D(x, y, z);
      Sp3dObj line = createLine(previousPoint, endPoint, Colors.blue, 2.0);
      objs.add(line);

      previousPoint = endPoint;

      Sp3dObj pointer = UtilSp3dGeometry.sphere(10);
      pointer.materials[0] = FSp3dMaterial.red.deepCopy();
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
