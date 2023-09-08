import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uwb_navigator/shared/variables.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 3000), (){
      Navigator.pushReplacementNamed(context, '/home');
    });
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg', width: 150,),
            const SizedBox(
              height: 50,
            ),
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
