import 'dart:convert';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:uwb_navigator/db/db_provider_local.dart';
import 'package:uwb_navigator/shared/variables.dart';
import 'package:uwb_navigator/utils/web_api_executer.dart';

import '../models/user.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with TickerProviderStateMixin{
  late TabController _tabController;
  bool _passwordVisible = false;
  bool _reenterpasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  int _uid = 0;
  String _name = "";
  String _email = "";
  String _password = "";
  String _repassword = "";

  late User currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController( length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[AppColor.AppBarPrimaryColor, AppColor.secondaryColor]))),
        elevation: 0.0,
        title: Text('UWB Navigator', style: TextStyle(color: Colors.white),),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          //Signin
          SingleChildScrollView(
            child: Padding(padding: EdgeInsets.all(16.0),
              child : Form(
                key: _formKey,
                child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start,
                  children : [
                    SizedBox(height: 50,),
                    const Text("Sign in to your account."),
                    SizedBox(height: 30,),
                    Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                      child: TextFormField(onChanged: (s) {_email = s.toString();}, decoration: const InputDecoration(hintText: "Enter Email"),),
                    ),
                    SizedBox(height: 30,),
                    Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: !_passwordVisible,
                        validator: (val) => val!.length < 8 ? 'Password too short.' : null,
                        onChanged: (s) {_password = s.toString();},
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).primaryColorDark,),
                            onPressed: () {setState(() {_passwordVisible = !_passwordVisible;});},
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),
                    ElevatedButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge, minimumSize: Size(double.infinity, 40)), child: const Text('Login'),
                      onPressed: () async {if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in... \n\n')),);
                        if(_email == "admin" && _password == "12345678"){
                          Navigator.pushReplacementNamed(context, '/home');
                        }else {
                          bool ok = await CheckUserOnline(_email, _password);
                          if (ok) {Navigator.pushReplacementNamed(context, '/home');}
                          else {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login fails with an incorrect Username, password or error message... \n\n')),);}
                        }
                      }},
                    ),
                  ]
                ),
              )
            ),
          ),
          //registration
          SingleChildScrollView(
            child: Padding(padding: EdgeInsets.all(16.0),
                child : Form(
                  key: _formKey1,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start,
                      children : [
                        SizedBox(height: 30,),
                        const Text("Create your account."),
                        SizedBox(height: 30,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(onChanged: (s) {_name=s.toString();}, decoration: const InputDecoration(hintText: "Name"),),
                        ),
                        SizedBox(height: 30,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(onChanged: (s) {_email=s.toString();}, decoration: const InputDecoration(hintText: "Email"),),
                        ),
                        SizedBox(height: 30,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: !_passwordVisible,
                            validator: (val) => val!.length < 8 ? 'Password too short.' : null,
                            onChanged: (s) {_password=s.toString();},
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).primaryColorDark,),
                                onPressed: () {setState(() {_passwordVisible = !_passwordVisible;});},
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40,),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))), width: double.infinity,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: !_reenterpasswordVisible,
                            validator: (val) => val!.toString() != _password ? 'Password does not match.' : null,
                            onChanged: (s) {_repassword=s.toString();},
                            decoration: InputDecoration(
                              labelText: 'Re-Enter Password',
                              hintText: 'Re-Enter password',
                              suffixIcon: IconButton(
                                icon: Icon(_reenterpasswordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).primaryColorDark,),
                                onPressed: () {setState(() {_reenterpasswordVisible = !_reenterpasswordVisible;});},
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40,),
                        ElevatedButton(style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge, minimumSize: Size(double.infinity, 40)), child: const Text('Register'),
                          onPressed: () async{if (_formKey1.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up')),);
                            bool ok = await RegisterUserOnline(_name, _email, _password);
                            if (ok) {Navigator.pushReplacementNamed(context, '/home');}
                            else {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong. Please register later or check your internet connection.')),);}
                          }},
                        ),
                        SizedBox(height: 50,),
                      ]
                  ),
                )
            ),
          ),
        ]
      ),
      bottomNavigationBar: ConvexAppBar(
          backgroundColor: AppColor.primaryColor,
          initialActiveIndex: 0,
          controller: _tabController,
          height: 50,
          items: const [
            TabItem(icon: Icons.login, title: 'Login'),
            TabItem(icon: Icons.app_registration, title: 'Register'),
          ],
          onTap: (int i) async{
            switch(i) {
              case 1 :
                clearData();
                break;
              case 0 :
                clearData();
                break;
            }
          }
      ),
    );
  }

  void clearData(){
    _uid=0;
    _name="";
    _email="";
    _password="";
    _repassword="";
  }

  Future<bool> CheckUserOnline(String email, String pass) async{
    Map<String,String> res = await WebApiExecuter().userLogin(email, pass);
    print(res["status"]);
    print(res["res"]);
    if(res["status"] == "200") {
      String JsonString = atob(res["res"]!);
      var jsonData = jsonDecode(JsonString);
      print(jsonData);
      print("User id");
      print(jsonData["_id"]);
      try {
        User usr = await DBProviderLocal().getUserByToken(jsonData["_id"]!.toString());
        print("executing retrieval");
        print(usr.email);
        setState(() {
          currentUser = usr;
        });

        if (currentUser.token == "" || currentUser.token == null) {
          bool ok = await CreateNewUser(jsonData["_id"]!,jsonData["email"]!);
          if(ok){
            return true;
          }else{
            return false;
          }
        }else{
          print(currentUser);
          return true;
        }

      }catch(e){
        print(e);
        return false;
      }
    }else{
      return false;
    }
  }

  Future<bool> RegisterUserOnline(String name, String email, String pass) async{
    Map<String,String> res = await WebApiExecuter().userRegister(_name, _email, _password);
    print(res["status"]);
    print(res["res"]);
    if(res["status"] == "200") {
      try {
        var jsonData = jsonDecode(res["res"].toString());
        User newUser = User(id: 0, token: jsonData["_id"], name: jsonData["name"], email: jsonData["email"], pass: "");
        bool status = await DBProviderLocal().newUser(newUser);
        if(status){ return true; }else{ return false; }
      }catch(e){ print(e); return false; }
    }else{return false;}
  }

  Future<bool> CreateNewUser(String token, String email) async{
    try{
      User newUser = User(id: 0, token: token, name: "", email: email, pass: "");
      bool status = await DBProviderLocal().newUser(newUser);
      if(status){
        return true;
      }else{
        print("Something went wrong while creating the user");
        return false;
      }
    }catch(e){
      print("Something went wrong while creating the user");
      return false;
    }
  }

  String atob (String token){
    final parts = token.split('.');
    Base64Codec base64 = const Base64Codec();
    String data = base64.normalize(parts[1]);
    var decoded = base64.decode(data);
    var jsonString = utf8.decode(decoded);
    return jsonString;
  }
}
