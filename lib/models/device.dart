class Devices{
  List<Device>? devices;
  Devices({this.devices});
}


class Device{
  int? id = 0;
  String? name = "";
  String? anchors = "";

  Device({this.id,this.name,this.anchors,});
}