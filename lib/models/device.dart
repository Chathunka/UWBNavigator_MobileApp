class Devices{
  List<Device>? devices;
  Devices({this.devices});
}


class Device{
  int? id = 0;
  String? name = "";
  String? status = "";
  String? type = "";
  double? x = 0.0;
  double? y = 0.0;
  double? z = 0.0;

  Device({this.id,this.name,this.status,this.type,this.x,this.y,this.z});
}