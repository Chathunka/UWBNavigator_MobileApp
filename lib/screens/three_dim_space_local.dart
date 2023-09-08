import 'package:flutter/material.dart';
import 'dart:math';

class ThreeDimentionalBox extends StatefulWidget {
  const ThreeDimentionalBox({Key? key}) : super(key: key);

  @override
  State<ThreeDimentionalBox> createState() => _ThreeDimentionalBoxState();
}

class _ThreeDimentionalBoxState extends State<ThreeDimentionalBox> {
  Offset _offset = Offset.zero;
  double widthheight = 250.0;
  double stroakwidth = 4;

  double Size = 250.0;

  double _Scale = 1;
  double _baseScale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => setState(() => _offset += details.delta),
      // onScaleStart: (ScaleStartDetails scaleStartDetails) {
      //   _baseScale = _Scale;
      // },
      // onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
      //   // don't update the UI if the scale didn't change
      //   if (scaleUpdateDetails.scale == 1.0) {
      //     return;
      //   }
      //   setState(() {
      //     _Scale = (_baseScale * scaleUpdateDetails.scale).clamp(0.5, 5.0);
      //     widthheight = _Scale * Size;
      //   });
      // },
      child: Scaffold(
        appBar: AppBar(
          title: Text("3D Cube"),
        ),
        body: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.01 * _offset.dy)
            ..rotateY(-0.01 * _offset.dx),
          alignment: FractionalOffset.center,
          child: Center(
            child:Stack(
              children: [
                Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0,widthheight,-widthheight/2),
                  alignment: Alignment.center,
                  child:Container(
                    width: widthheight,
                    height: stroakwidth,
                    color: Colors.green,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0,0.0,-widthheight/2),
                  alignment: Alignment.center,
                  child: Container(
                    width: stroakwidth,
                    height: widthheight,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..rotateY(-pi/2)
                    ..translate(0.0,widthheight,widthheight/2),
                  alignment: Alignment.center,
                  child: Container(
                    width: widthheight,
                    height: stroakwidth,
                    color: Colors.blueAccent,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(100.0,100.0,0.0),
                  alignment: Alignment.center,
                  child: Container(
                    width: stroakwidth,
                    height: stroakwidth,
                    color: Colors.black,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
