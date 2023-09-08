import 'package:flutter/material.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/network_status_requester.dart';

class DeviceCard extends StatefulWidget {
  String? id;String? name;String? status;String? type;double? x;double? y;double? z;
  void Function(String,String) onAreaClick;
  DeviceCard({Key? key, required this.id, required this.name, required this.status, required this.type, required this.x, required this.y, required this.z, required this.onAreaClick});
  @override
  State<DeviceCard> createState() => _DeviceCardState(id: id, name: name, status: status, type: type, x: x, y: y, z: z, onAreaClick: onAreaClick);
}

class _DeviceCardState extends State<DeviceCard> {
  String? id;String? name;String? status;String? type;double? x;double? y;double? z;void Function(String,String) onAreaClick;

  _DeviceCardState({required this.id, required this.name, required this.status, required this.type, required this.x, required this.y, required this.z, required this.onAreaClick});

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
                        if(type == "tag") ...[
                          Text(name!), const SizedBox(height: 10,),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [const SizedBox(width: 10,), Text("X : " + x.toString()), const SizedBox(width: 10,),],
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [const SizedBox(width: 10,), Text("Y : " + y.toString()), const SizedBox(width: 10,),],
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [const SizedBox(width: 10,), Text("Z : " + z.toString()), const SizedBox(width: 10,),],
                          ),
                        ]
                      ],
                    ),
                  ),
                  Container(height: 120, width: 100, color: Colors.white10,
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton( child: const Text(" 3D Map "),onPressed: () async{ var network_info = await NetworkInformation().getNetworkInfo();
                          if(network_info["Wifi_Name"] == '"UWB_Navigator"') {onAreaClick("WIFI_DEVICE_CONNECTED_GO3D", "1");}else{onAreaClick("WIFI_DEVICE_NOT_CONNECTED_GO3D", "1");}
                        },),
                        ElevatedButton( child: const Text("Location"),onPressed: (){},),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async{
              var network_info = await NetworkInformation().getNetworkInfo();
              if(network_info["Wifi_Name"] == '"UWB_Navigator"') {onAreaClick("WIFI_DEVICE_CONNECTED", "1");}else{onAreaClick("WIFI_DEVICE_NOT_CONNECTED", "1");}
            },
          ),
          if (isUpdating) Positioned.fill(child: Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white,),),),),
        ],
      ),
    );
  }
}
