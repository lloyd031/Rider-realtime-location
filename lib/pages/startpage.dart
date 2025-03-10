import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        
        
        bool runOnBackground=false;
        String location="";
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
              setState(() {
                location="$lat $long";
              });
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
  @override
  Widget build(BuildContext context) {
    final _db=DatabaseService(riderId: widget.rid);
    void _liveLocation()async{
    late LocationSettings locationSettings= LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          
      );
    
   
    
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position? position) {
            setState(() {
              location= "${position!.latitude} ${position.longitude}";
              lat=position!.latitude;
              long=position.longitude;
            });
            if(runOnBackground==true){
              _db.createAssignedAdDocOpDate("${widget.ad_id}", position!.latitude, position.longitude);
            }
            _goToLocation();
        });
     }
    
    return Scaffold(
      body: SafeArea(child: 
      Column(
        children: [
          Text(location),
          SizedBox(height: 8,),
          Container(
            height: 500,
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
          SizedBox(height: 8,),
          TextButton(onPressed: ()async{
             _liveLocation();
             if(runOnBackground==false){
                await initializeService();
             }else{
                stopBackgroundService();
             }
             
             setState(() {
               runOnBackground=!runOnBackground;
             });
            
          }, child: Text((runOnBackground==false)?"START":"STOP")),

          
        ],
      )
      ),
    );
  }
}