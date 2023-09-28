import 'dart:async';
import 'package:uwb_navigator/models/device.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';

class DBProviderLocal {
  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'uwbnavigator.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, token TEXT, name TEXT, email TEXT, pass TEXT)',
        );
        await db.execute(
          'CREATE TABLE devices(id INTEGER PRIMARY KEY, name TEXT, anchors TEXT)',
        );
        await db.execute(
          'CREATE TABLE devdata(id INTEGER PRIMARY KEY, devid INTEGER, inputdata TEXT, outdata TEXT, datetime TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<bool> newUser(User newUser) async {
    final db = await initDB();
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM users");
    Object? id = table.first["id"];
    print(id);
    try {
      var raw = await db.rawInsert(
          "INSERT Into users (id,token,name,email,pass)"
              " VALUES (?,?,?,?,?)",
          [
            id,
            newUser.token,
            newUser.name,
            newUser.email,
            newUser.pass
          ]);
      print(raw);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<User> getUserById(int id) async {
    final db = await initDB();
    List<Map> result = await db.rawQuery('SELECT * FROM users WHERE id=?', [id]);
    late User usr;
    result.forEach((row) {usr = User(id: row['id'], token: row['token'], name: row['name'], email: row['email'], pass: row['pass'],);print(row);});
    return usr;
  }

  Future<User> getUserByToken(String Token) async {
    final db = await initDB();
    List<Map> result = await db.rawQuery('SELECT * FROM users WHERE token=?', [Token]);
    User usr = User(id: 0, token: "", name: "", email: "", pass: "");
    result.forEach((row) {usr = User(id: row['id'], token: row['token'], name: row['name'], email: row['email'], pass: row['pass'],);print(row);});
    return usr;
  }

  Future<List<User>> getAllUsers() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        token: maps[i]['token'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        pass: maps[i]['pass']
      );
    });
  }

  Future deleteUserById(int id) async {
    final db = await initDB();
    return db.delete("users", where: "id = ?", whereArgs: [id]);
  }

  newDevice(Device newDevice) async {
    final db = await initDB();
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM devices");
    Object? id = table.first["id"];
    print(id);
    var raw = await db.rawInsert(
        "INSERT Into devices (id,name,anchors)"
            " VALUES (?,?,?)",
        [
          id,
          newDevice.name,
          newDevice.anchors,
        ]);
    print(raw);
    return raw;
  }

  Future<Device> getDevice(int id) async {
    final db = await initDB();
    List<Map> result = await db.rawQuery('SELECT * FROM devices WHERE id=?', [id]);
    late Device dev;
    result.forEach((row) {dev = Device(id: row['id'], name: row['name'], anchors: row['anchors'],);print(row);});
    return dev;
  }

  updatetDevice(Device dev) async {
    final db = await initDB();
    List<Map> result = await db.rawQuery('UPDATE devices SET anchors=? WHERE id=?', [dev.anchors,dev.id]);
    return result;
  }

  Future<List<Device>> getAllDevices() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('devices');

    return List.generate(maps.length, (i) {
      return Device(
        id: maps[i]['id'],
        name: maps[i]['name'],
        anchors: maps[i]['anchors'],
      );
    });
  }

  Future deleteDevice(int id) async {
    final db = await initDB();
    return db.delete("devices", where: "id = ?", whereArgs: [id]);
  }
}
