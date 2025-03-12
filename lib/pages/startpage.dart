import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:rider_realtime_location/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:rider_realtime_location/pages/auth/login.dart';
import 'package:rider_realtime_location/pages/auth/signup.dart';

class StartPage extends StatefulWidget {
  final String? rid;
  final String? ad_id;
  StartPage(this.rid,this.ad_id);
  
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
        List<dynamic> keys=[];
        //start - all about geolocator and google map
        bool runOnBackground=false;
        late double lat;
        late double long;
        Future<Position> _determinePosition() async {
        bool locServiceEnabled;
        LocationPermission permission;

        // Test if location services are enabled.
        locServiceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!locServiceEnabled) {
          // Location services are not enabled don't continue
          // accessing the position and request users of the 
          // App to enable the location services.
          return Future.error('Location services are disabled.');
        }

          permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            // Permissions are denied, next time you could try
            // requesting permissions again (this is also where
            // Android's shouldShowRequestPermissionRationale 
            // returned true. According to Android guidelines
            // your App should show an explanatory UI now.
            return Future.error('Location permissions are denied');
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately. 
          return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
        } 

        // When we reach here, permissions are granted and we can
        // continue accessing the position of the device.
        return await Geolocator.getCurrentPosition();
      } 
      
      
      @override
      void initState() {
        _determinePosition().then((value){
                lat=value.latitude;
                long=value.longitude;
              });
        super.initState();
      }


    final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

      static const CameraPosition _duma = CameraPosition(
      target: LatLng(9.3068, 123.3054),
      zoom: 14.4746,);

      Future<void> _goToLocation() async {
       GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, long),
        zoom: 16)));
    }
    //start - all about geolocator and google map

    //offline db
    final _myBox=Hive.box('riderBox');
    //write
    void writeData(String ad_id, String rider_id, double lat, double long,String? timestamp){
      _myBox.add([rider_id, ad_id, lat, long, timestamp]);
      refreshData();
    }
    //read
    List<dynamic> readData(){
    
      for(int i=0; i<_myBox.length; i++){
        final _key=_myBox.getAt(i);
        keys.add(_key);
      }
      return keys;
    }
    //delete
    void deleteData(){
      _myBox.clear();
      print("deleted");
    }
    List<dynamic> res =[];
    void refreshData(){
      setState(() {
       res = readData();
      });
    }
  @override
  Widget build(BuildContext context) {
    
    //final _db=DatabaseService(riderId: widget.rid);
    //start still related to geolocator and google map
    void _liveLocation()async{
    late LocationSettings locationSettings= LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          
      );
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position? position) {
            setState(() {
              lat=position!.latitude;
              long=position.longitude;
            });
            if(runOnBackground==true){
              //_db.createAssignedAdDocOpDate("${widget.ad_id}", position!.latitude, position.longitude);
              DateTime now = DateTime.now();
              String timestamp="${now.month}-${now.day}-${now.second}-${now.year}";
             //writeData(widget.rid, widget.ad_id,position!.latitude, position.longitude,);
            }
            _goToLocation();
        });
     }
    //end still related to geolocator and google map.
    return WillPopScope(
      onWillPop: ()async{ 
        return false;
       },
      child: Scaffold(
        body: SafeArea(child: 
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: GoogleMap(
                mapType: MapType.terrain,
                onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
                initialCameraPosition: _duma,
                markers:(!_controller.isCompleted)?{}:{Marker(
                  position: LatLng(lat, long),
                  markerId: MarkerId('1'),),
                  }),
            ),
            Container(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    for(int i=0; i<keys.length; i++)
                    Text("${keys[i][0]} - ${keys[i][1]} - ${keys[i][2]}")
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor:(runOnBackground==true)?Colors.red[500]: Colors.blue,  // Set the text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Adjust padding
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,  // No rounded corners, making it rectangular
                    ),
                  ),
                  onPressed: ()async{
                    
                    _goToLocation();
                   _liveLocation();
                   if(runOnBackground==false){
                      //_db.createAssignedAdDocOpDate("${widget.ad_id}", lat, long);
                      await initializeService();
                      
                   }else{
                      stopBackgroundService();
                      Navigator.pop(context);
                   }
                   
                   setState(() {
                     runOnBackground=!runOnBackground;
                   });
                    
                   }, child: Text((runOnBackground==false)?"START":"STOP")),
                )
              ],
            ),
      
            
          ],
        )
        ),
      ),
    );
  }
}