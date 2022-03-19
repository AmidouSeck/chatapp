import 'package:flutter/material.dart';
import 'package:chatapp/main.dart';
//import 'package:chatapp/screens/forgot.dart';
import 'package:chatapp/screens/signup.dart';

//les routes
Map<String, Widget Function(BuildContext)> routes(BuildContext context) {
  DateTime now = DateTime.now();
  _getHour() {
    return int.parse(now.hour.toString());
  }

  return {
    "": (context) => MyApp(),
   
    "signup": (context) => Signup(),
    //"forgot": (context) => Forgot(),
    /*"userHome": (context) => HomeScreen(
          dark: false,
        ),
    "forgot": (context) => Forgot(),
    "verify_your_mail": (context) => VerifyYourEmail(),
    "change_password": (context) => ChangePassword(),*/
  };
}