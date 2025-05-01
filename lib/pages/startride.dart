import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rider_realtime_location/main.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/pages/wrapper.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class StartRide extends StatefulWidget {
  final String? rid;
  final Ad_Model? ad;
  final bool preserved;
  StartRide(this.rid,this.ad,this.preserved);
  

  @override
  State<StartRide> createState() => _StartRideState();
}

class _StartRideState extends State<StartRide> {
        late double lat;
        late double long;
        bool loading=false;
        bool isRunning=false;
        List<dynamic> keys=[];
        bool uploaded=false;
        
        Future<Position> _determinePosition() async {
              bool locServiceEnabled;
              LocationPermission permission;
              

              
              // Test if location services are enabled.
              locServiceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!locServiceEnabled) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Enable Location Services"),
                        content: Text("Location services are disabled. Would you like to enable them?"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text("Enable"),
                            onPressed: () async {
                              // Navigate to location settings (to enable location services)
                              await Geolocator.openLocationSettings();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                return Future.error('Location services are disabled.');
              }

                permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Location Permission Denied"),
                        content: Text("We need location permissions to proceed. Please allow location permissions to continue."),
                        actions: <Widget>[
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context); 
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return Future.error('Location permissions are denied');
                }
              }
              
              if (permission == LocationPermission.deniedForever) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Location Permission Denied"),
                        content: Text("We need location permissions to proceed. Please allow location permissions to continue."),
                        actions: <Widget>[
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context); 
                            },
                          ),
                        ],
                      );
                    },
                  );
                // Permissions are denied forever, handle appropriately. 
                return Future.error(
                  'Location permissions are permanently denied, we cannot request permissions.');
              } 

              // When we reach here, permissions are granted and we can
              // continue accessing the position of the device.
              return await Geolocator.getCurrentPosition();
            }
        void uploadData(_myBox)async{
          setState(() {
            loading=true;
          });
            
            for(int i=0; i<keys.length;i++){
              await SyncData(keys[i]);
              if(isConn==false){
                  i=keys.length;
                }
            }
          for(int i=0; i<keysUploaded.length;i++){
              _myBox.delete("${keys[i][5]}${keys[i][6]}${keys[i][7]}${keys[i][4]}");
          }
          
          setState(() {
          //runOnBackground=true;
          loading=false;
          });
          if(isConn==false){
                  _showDialog(_myBox);
          }else{
            setState(() {
              uploaded=true;
            });
          }
                          
        }
        void _showDialog(_myBox){
          showDialog(context: context, builder: 
          (context){
            return CupertinoAlertDialog(
              title: Text('No internet connection'),
              content: Text("You are not connected to the internet. All data will be saved locally. Make sure to sync it later."),
              actions: [
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child:Text("OKAY",style: TextStyle(color: Colors.blue),),),
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  uploadData(_myBox);
                },
                child:Text("TRY AGAIN",style: TextStyle(color: Colors.green)),)
              ],
            );
          });
          
        }
        SyncData(dynamic key)async{
            final db=DatabaseService(riderId: widget.rid, );
            try {
                              
                              final response = await http.get(Uri.parse('https://www.google.com'));
                              if (response.statusCode == 200) {
                                
                                
                                if(currDate!="${key[5]}${key[6]}${key[7]}"){
                                  var documentRefYear = FirebaseFirestore.instance.collection('rider').doc(widget.rid).collection("assigned_ads").doc(key[1]).collection("year").doc(key[5]);
                                DocumentSnapshot documentSnapshot = await documentRefYear.get();
                                if(!documentSnapshot.exists){
                                  await db.createDocYear(key, key[5]);
                                }
                                var documentRefMonth=documentRefYear.collection("month").doc(key[6]);
                                documentSnapshot = await documentRefMonth.get();
                                if(!documentSnapshot.exists){
                                  await db.createDocMonth(key[1], key[5],key[6]);
                                }
                                var documentRefDay=documentRefMonth.collection("day").doc(key[7]);
                                documentSnapshot = await documentRefDay.get();
                                if(!documentSnapshot.exists){
                                  await db.createDocDay(key[1],key[5],key[6],key[7]);
                                }
                                setState(() {
                                  currDate="${key[5]}${key[6]}${key[7]}";
                                });
                                }
                                  await db.createAssignedAdDocOpDate(key[1], key[2], key[3],key[4],key[5]
                                ,key[6],key[7]);
                                setState(() {
                                  keysUploaded.add(key);
                                });
                                key[8]=true;
                                isConn=true;
                              } else {
                                isConn=false;
                              }
                            } on SocketException catch (_) {
                                isConn=false;
                            }
          }
      
       void readData()async{
        if (Hive.isBoxOpen('riderBox')) {
          await Hive.box('riderBox').close(); // Close the old in-memory view
        }

        var _myBox = await Hive.openBox('riderBox'); // Reopen to sync latest data
        keys=[];
        for(int i=0; i<_myBox.length; i++){
          final _key=_myBox.getAt(i);
          if(_key!=null && _key[0]==widget.rid && _key[8]==false ){
            keys.add(_key);
          }
          
        }
        if(keys.isNotEmpty){
          
          uploadData(_myBox);
        }else{
            setState(() {
              uploaded=true;
            });
          
        }
      }
       
      @override
      void initState() {
        //keys=[];
          if(widget.preserved==false){
            _determinePosition().then((value){
                lat=value.latitude;
                long=value.longitude;
              });
          }
         
        super.initState();
      }
  @override
  Widget build(BuildContext context) {
    final state=Hive.box('stateBox');
    return WillPopScope(
      onWillPop: ()async{ 
        return false;
       },
      child:(loading==true)?Scaffold(
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
        appBar:  AppBar(
          title: Text((widget.ad!.name=="")?"FAST Ads":"${widget.ad!.name}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
          automaticallyImplyLeading: false,
          elevation: 1,
          shadowColor: Colors.black,
          backgroundColor:Colors.white,
          actions: <Widget>[
          if(isRunning==false)
          TextButton(onPressed: ()async{
            
                 Navigator.pop(context); 
          }, child: Text("BACK", style: TextStyle(color:Colors.red[700]),))
        ],
          
      ),
        body: SafeArea(child: 
        Container(
          color: Colors.white,
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text((widget.ad!.name=="")?"FAST Ads":"${widget.ad!.name}", style: TextStyle(fontWeight: FontWeight.bold, color: const Color.fromARGB(221, 29, 29, 29), fontSize: 16),),
              
              (uploaded==true)?TextButton(
                onPressed: () {
                  if(widget.preserved==true){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>Wrapper()));
                  }else{
                    Navigator.pop(context);
                  }
                  
                }, 
                style: TextButton.styleFrom(
                  backgroundColor:Colors.green[600],
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                 "Done",
                  style: TextStyle(color: Colors.white),
                ),
              ):TextButton(
                onPressed: (){
                  if(isRunning==false && widget.preserved==false){
                  startBackgroundService();
                  state.put('state', [widget.rid, [widget.ad!.id, widget.ad!.name]]);
                  setState(() {
                    isRunning=true;
                  });
                  
                  }else
                  {
                    if(uploaded==false){
                      stopBackgroundService();
                      readData();
                      setState(() {
                        isRunning=false;
                      });
                      }
                      state.clear();
                  }
                }, 
                style: TextButton.styleFrom(
                  backgroundColor: (isRunning==false && widget.preserved==false)?Colors.green[600]:Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  (isRunning == false && widget.preserved==false) ? "Start" :"Stop",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        )
        ),
      ),
    );
  }
}