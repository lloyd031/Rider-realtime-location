
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/rider.dart';
import 'package:rider_realtime_location/pages/auth/auth_wapper.dart';
import 'package:rider_realtime_location/pages/auth/signup.dart';
import 'package:rider_realtime_location/pages/home.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:rider_realtime_location/pages/auth/login.dart';

class Wrapper extends StatefulWidget {
  
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final  auth=DatabaseService();
  
  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<RiderObj?>(context);
    if(user==null)
    {
      return Authenticate();
    }else
    {
      
      return Home();
      
    }
  }
}
