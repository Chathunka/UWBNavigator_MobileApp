import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uwb_navigator/shared/variables.dart';

class DeviceCard extends StatefulWidget {
  String? id;String? name;String? anchors;
  void Function(String,String) onButtonClick;
  DeviceCard({Key? key, required this.id, required this.name, required this.anchors, required this.onButtonClick});
  @override
  State<DeviceCard> createState() => _DeviceCardState(id: id, name: name, anchors: anchors, onButtonClick: onButtonClick);
}

class _DeviceCardState extends State<DeviceCard> {
  String? id;String? name;String? anchors;void Function(String,String) onButtonClick;
  _DeviceCardState({required this.id, required this.name, required this.anchors, required this.onButtonClick});
  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.primaryColor,),
      child: Stack(
        children: [
          InkWell(
            child: Card(clipBehavior: Clip.antiAlias,
              child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container( height: 120,
                    child: Image.asset('assets/images/tag.png', height: 120,),
                  ),
                  Container(height: 120, width: 160, padding: EdgeInsets.all(8), color: Colors.teal[100],
                    child: Wrap(
                      children: [
                          Text(name!), const SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  Container(height: 120, width: 100, color: Colors.white10,
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton( child: const Text(" 3D Map "),onPressed: (){onButtonClick("GO3D_CLICKED",id!);},),
                        ElevatedButton( child: const Text("  Online  "),onPressed: (){onButtonClick("ONLINE_CLICKED",id!);},),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async{
            },
          ),
          if (isUpdating) Positioned.fill(child: Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white,),),),),
        ],
      ),
    );
  }
}
