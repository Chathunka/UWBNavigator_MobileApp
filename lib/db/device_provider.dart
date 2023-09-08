import 'package:uwb_navigator/models/device.dart';

class DeviceProvider{
  Future<List<Device>> getDevices() async{
    List<Device> dev_list = [];
    Device dev1 = Device(
      id: 1,
      name: "Tag",
      status: "active",
      type: "tag",
      x: 5.5,
      y: 10.5,
      z: 15.5,
    );
    try{
      dev_list.add(dev1);
      return dev_list!;
    }catch(e){
      print(e);
      return dev_list;
    }
  }
}