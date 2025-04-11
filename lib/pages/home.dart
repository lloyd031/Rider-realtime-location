import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/Rider.dart';
import 'package:rider_realtime_location/pages/adlist.dart';
import 'package:rider_realtime_location/pages/archive.dart';
import 'package:rider_realtime_location/pages/components/mydrawer.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class Home extends StatefulWidget {
  final String? rid;
  const Home(this.rid);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int screenView=1;
  
  void switchScreen(int screenNumber){
    setState(() {
      screenView=screenNumber;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    bool loading=false;
    return(loading==true)?Scaffold(
        body: Container(
          height: double.maxFinite,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loading(),
            ],
          ),
        ),
      ): Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        leading: Builder( builder: (BuildContext context) { return IconButton(
          onPressed:(){Scaffold.of(context).openDrawer();}, 
          icon: Icon(Icons.menu,color: Colors.red[600],size: 25,)); }),
      elevation: 1,
      shadowColor: Colors.black,
      backgroundColor:Colors.white,
      
      ),
      drawer:StreamProvider<RiderObj?>.value(
        value: DatabaseService(riderId:widget.rid).riderDetails,
        initialData: RiderObj("", "", "",""),
        child:
          MyDrawer(switchScreen: switchScreen),
        
      ) ,
          
      
      body:SafeArea(child:StreamProvider<List<Ad_Model>>.value(
        value: DatabaseService(riderId:widget.rid).getAssignedAd,
        initialData: List.empty(),
        child:(screenView==0)?Text("My Profile")
        :(screenView==2)?Ad_List(widget.rid,true)
        :(screenView==4)?Archive(rid: widget.rid,):
        Column(
        children: [
          
          Ad_List(widget.rid,false),
        ],
      ) ,) ),
    );
  }
}
/**
 * 
 */