import 'dart:async';
import 'package:uwb_navigator/models/device.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProviderLocal {
  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'uwbnavigator.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, uid TEXT, name TEXT, email TEXT, uname TEXT, pass TEXT)',
        );
        await db.execute(
          'CREATE TABLE devices(id INTEGER PRIMARY KEY, name TEXT, description TEXT, outputs INTEGER, inputs INTEGER, outnames TEXT, innames TEXT, otherdata TEXT)',
        );
        await db.execute(
          'CREATE TABLE devdata(id INTEGER PRIMARY KEY, devid INTEGER, inputdata TEXT, outdata TEXT, datetime TEXT)',
        );
      },
      version: 1,
    );
  }

  newDevice(Device newDevice) async {
    final db = await initDB();
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM devices");
    Object? id = table.first["id"];
    print("from database%%%%%%%%%%%%%%%");
    print(id);
    var raw = await db.rawInsert(
        "INSERT Into devices (id,name,description,outputs,inputs,outnames,inNames,otherdata)"
            " VALUES (?,?,?,?,?,?,?,?)",
        [
          id,
          newDevice.name,
          "",
          "",
          "",
          "",
          "",
          ""
        ]);
    print("return from database%%%%%%%%%%%%%%%");
    print(raw);
    return raw;
  }

  getDevice(int id) async {
    final db = await initDB();
  }

  Future<List<Device>> getAllDevices() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('devices');

    return List.generate(maps.length, (i) {
      //print(maps[i]['id'].toString());
      return Device(
        id: maps[i]['id'],
        name: maps[i]['name'],
        status: maps[i]['description'],
        type: maps[i]['outputs'],
        x: 0.0,
        y: 0.0,
        z: 0.0,
      );
    });
  }

  Future deleteDevice(int id) async {
    final db = await initDB();
    return db.delete("devices", where: "id = ?", whereArgs: [id]);
  }
}
