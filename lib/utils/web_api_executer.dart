import 'dart:convert';

import 'package:http/http.dart' as http;

import '../shared/variables.dart';

class WebApiExecuter {

  Future<Map<String,String>> userLogin(String email, String pass) async{
    String res;
    String status;
    try {
      var logindata = {"email": email, 'password': pass};
      String jsonStr = jsonEncode(logindata);
      final response = await http.post(
          Uri.parse('${GlobalVariables.BASE_URL_WEB_API}authenticate'),
          body: jsonStr,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          });
      if (response.statusCode == 200) {
        status = "200";
        res = response.body.toString();
      } else {
        res = "";
        throw Exception(response.statusCode.toString());
      }
    } catch (e) {
      status = "404";
      res = e.toString();
    }
    return {"status":status,"res":res};
  }

  Future<Map<String,String>> userRegister(String name, String email, String pass) async{
    String res;
    String status;
    try {
      var registerdata = {"name": name, "email": email, 'password': pass};
      String jsonStr = jsonEncode(registerdata);
      final response = await http.post(
          Uri.parse('${GlobalVariables.BASE_URL_WEB_API}register'),
          body: jsonStr,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          });
      if (response.statusCode == 200) {
        status = "200";
        res = response.body.toString();
      } else {
        res = "";
        throw Exception(response.statusCode.toString());
      }
    } catch (e) {
      status = "404";
      res = e.toString();
    }
    return {"status":status,"res":res};
  }

}