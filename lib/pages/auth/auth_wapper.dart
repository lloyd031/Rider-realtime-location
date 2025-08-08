import 'package:flutter/material.dart';
import 'package:rider_realtime_location/pages/auth/login.dart';
import 'package:rider_realtime_location/pages/auth/signup.dart';

class Authenticate extends StatefulWidget {
  final Function login;
  const Authenticate({super.key, required this.login});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool islogin=true;
    void switchAuth(){
    setState(() {
      islogin=!islogin;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    return LogIn(switchAuth: switchAuth,login: widget.login,);
  }
}