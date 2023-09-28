import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uwb_navigator/shared/variables.dart';

import '../db/db_provider_local.dart';
import '../models/user.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  late List<User> _users;
  @override
  void initState() {
    super.initState();
    DBProviderLocal().getAllUsers().then((users) {
      setState(() {_users = users.cast<User>();
        print("UWB_Navigator : User detected.");
        print(_users.length);
        if(_users.length == 0){
          Future.delayed(const Duration(milliseconds: 3000), (){
            Navigator.pushReplacementNamed(context, '/auth');
          });
        }else{
          Future.delayed(const Duration(milliseconds: 3000), (){
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg', width: 150,),
            const Text("UWB Navigator", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
            const SizedBox(height: 50,),
            const SpinKitCircle(
              color: Colors.white,
              size: 75.0,
            ),
          ],
        ),
      ),
    );
  }
}
