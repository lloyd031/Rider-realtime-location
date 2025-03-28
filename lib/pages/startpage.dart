import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/pages/components/dateAndYearDropdown.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:rider_realtime_location/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class StartPage extends StatefulWidget {
  final String? rid;
  final Ad_Model? ad;
  final bool? viewRide;
  StartPage(this.rid,this.ad,this.viewRide);
  
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
        // used to view riders trialmark history
        bool isTimerRun=false; // used to make sure that timer only start once
        Set<Polyline> _poly={};
        List<LatLng> points=[];
        bool loading=false;
        List<dynamic> keys=[];
        List<RidesModel>? trailmark=[];
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
      
      
      @override
      void initState() {
        if(widget.viewRide==false){
          _determinePosition().then((value){
                lat=value.latitude;
                long=value.longitude;
              });
        readData();
        }else{
          lat=9.3068;
          long=123.3054;
        }
        super.initState();
      }
      
      String year='';
      String month='';
      setMonthYear(String mm, String yy){
        setState(() {
          year=yy;
          month=mm;
        });
        print(mm+" "+yy);
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
        zoom: 15,
        tilt: 50,)));
      
    }
    //start - all about geolocator and google map

    //offline db
    final _myBox=Hive.box('riderBox');
    //write
    Future writeData() async{
      for(int i=0; i<points.length; i++){
        DateTime now = DateTime.now();
        String yyyy=now.year.toString();
        String mm=now.month.toString();
        String dd=now.day.toString();
        String timestamp=now.hour.toString() +"-"+now.minute.toString()+"-"+now.second.toString()+"-"+now.millisecond.toString();
        await _myBox.put("$yyyy$mm$dd$timestamp",[widget.rid, widget.ad!.id, points[i].latitude, points[i].longitude, timestamp,yyyy,mm,dd]);
        
      }
      setState(() {
        readData();
      });
    }
    
    //read
    void readData(){
      keys=[];
      for(int i=0; i<_myBox.length; i++){
        final _key=_myBox.getAt(i);
        if(_key[0]==widget.rid && _key[1]==widget.ad!.id ){
          keys.add(_key);
        }
        
      }
    }
    
   

    void SyncData(DatabaseService db)async{
      try {
                        final response = await http.get(Uri.parse('https://www.google.com'));
                        if (response.statusCode == 200) {
                          setState(() {
                            loading=true;
                          });
                          
                          for(int i=0; i<points.length; i++)
                          {
                            DateTime now = DateTime.now();
                            String yyyy=now.year.toString();
                            String mm=DateFormat('MMMM').format(now);
                            String dd=now.day.toString();
                            String timestamp="${now.hour}-${now.minute}-${now.second}-${now.millisecond}";
                            //await db.setYear("${widget.ad!.id}",yyyy);
                            await db.createAssignedAdDocOpDate(widget.ad!.id, points[i].latitude, points[i].longitude,timestamp,yyyy,mm,dd);
                           
                           }
                          
                          back();
                        } else {
                          
                          setState(() {
                            runOnBackground=true;
                            loading=false;
                             _showDialog(db);
                          });
                        }
                      } on SocketException catch (_) {
                        setState(() {
                          runOnBackground=true;
                          loading=false;
                           _showDialog(db);
                        });
                      }
    }
    void back(){
      stopBackgroundService();
      setState(() {
          runOnBackground=false;
          });
      Navigator.pop(context);
    }
        void _showDialog(DatabaseService db){
          showDialog(context: context, builder: 
          (context){
            return CupertinoAlertDialog(
              title: Text('No internet connection'),
              content: Text("You are not connected to the internet. All data will be saved locally. Make sure to sync it later."),
              actions: [
                MaterialButton(onPressed: ()async{
                  setState(() {
                    loading=true;
                  });
                  
                  await writeData();
                  Navigator.pop(context);
                  back();
                },
                child:Text("OKAY",style: TextStyle(color: Colors.blue),),),
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  SyncData(db);
                },
                child:Text("TRY AGAIN",style: TextStyle(color: Colors.green)),)
              ],
            );
          });
        }
  void addPolyline(){
      setState(() {
        points.add(LatLng(lat, long));
      _poly.clear();
      _poly.add(Polyline(polylineId: PolylineId("id"),
      points: points,
      width: 8,
      color: Colors.deepOrange));
      });
    }
  void viewTrail(List<RidesModel>? trail){
    setState(() {
      trailmark=trail;
    });
    for(int i=0; i<trailmark!.length; i++){
        setState(() {
          lat = trailmark![i].lat;
          long = trailmark![i].long;
          addPolyline();
          });
          }
          _goToLocation();
                                        
  }
  @override
  Widget build(BuildContext context) {
    DateTime currDate = DateTime.now();
    
    final _db=DatabaseService(riderId: widget.rid, );
    void _liveLocation()async{
    late LocationSettings locationSettings= LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
          
      );
    
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position? position) {
            setState(() {
              lat=position!.latitude;
              long=position.longitude;
             });
            if(runOnBackground==true){
               addPolyline();
              if(isTimerRun==false){
                isTimerRun=true;
              }
              _goToLocation();
            }
            
        });
     }
    
     
    
    return WillPopScope(
      onWillPop: ()async{ 
        return false;
       },
      child:(loading==true)?Loading(): Scaffold(
        appBar:  AppBar(
          title: Text((widget.ad!.name=="")?"FAST Ads":"${widget.ad!.name}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
          automaticallyImplyLeading: false,
          elevation: 1,
          shadowColor: Colors.black,
          backgroundColor:Colors.white,
          actions: <Widget>[
          if(widget.viewRide==false)
          TextButton(onPressed: ()async{
                    if(widget.viewRide==false){
                        if(runOnBackground==false){
                            
                            _goToLocation();
                            _liveLocation();
                            await initializeService();
                            setState(() {
                              runOnBackground=true;
                            });
                            
                            
                            
                        }else{
                              
                            SyncData(_db);
                            
                        }
                    }
                 
                
                }, child: Text((runOnBackground==false)?"START":"STOP", style: TextStyle(color:(runOnBackground==false)?Colors.green[700]:Colors.red[700]),)),
          if(runOnBackground==false)
          TextButton(onPressed: ()async{
            
                 Navigator.pop(context); 
          }, child: Text("BACK", style: TextStyle(color:Colors.red[700]),))
        ],
          
      ),
        body: SafeArea(child: 
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
            Expanded(
              flex: 1,
              child: GoogleMap(
                polylines: _poly,
                mapType: MapType.terrain,
                onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                
              },
                initialCameraPosition: _duma,
                markers:(!_controller.isCompleted)?{}:{Marker(
                  position: LatLng(lat, long),
                  markerId: MarkerId('1'),),
                },
                ),
            ),
            if(widget.viewRide==true)
            Container(
              decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow color
                  offset: Offset(0, -5), // Top shadow by shifting the shadow upward
                  blurRadius: 10, // How blurred the shadow is
                  spreadRadius: 2, // How much the shadow spreads
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), // Top-left border radius
                topRight: Radius.circular(8), // Top-right border radius
              ),
            ),
            
              child:Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MonthAndYear(adId: widget.ad!.id,rId: widget.rid, setMonthYear: setMonthYear,),
                        //Text("${DateFormat('MMMM').format(currDate)} ${currDate.year}" ,style: TextStyle(fontSize: 20,),),
                        Icon(Icons.more_horiz, color:Colors.red[500],)
                      ],
                    ),
                  SizedBox(height: 16,),
                  if(year!="" && month!="")
                    StreamProvider<List<String>>.value(
                    value: DatabaseService(riderId:widget.rid,adId: widget.ad!.id,year:year, month: month).getDays,
                    initialData: List.empty(),
                    child:MyDays(viewTrail: viewTrail,adId: widget.ad!.id,mm: month,rid:widget.rid,yy: year,) ,),
                  if(year=="" && month=="")
                  MyDays(viewTrail: null,adId: widget.ad!.id,mm: month,rid:widget.rid,yy: year,)
                  ],
                ),
              )
            ),
           
            Container(
              padding: EdgeInsets.all(8),
              height: 45, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.white, // White color for the container
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(1), // Shadow color
                    spreadRadius: 2, // Spread radius of the shadow
                    blurRadius: 4, // Blur radius for the shadow
                    offset: Offset(0, 4), // Shadow position (top shadow)
                  ),
                ],
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:(widget.viewRide==true)?
                    [
                      Row(
                        children: [
                          Icon(Icons.map,color:Colors.green,),
                          SizedBox(width: 8,),
                          Text("Distance Traveled ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),)
                        ],
                      ),
                      Text("${(trailmark!.isEmpty)?0:((trailmark!.length-1)*50)/1000} Km", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color:Colors.black),)
                    ]
                    : [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,color:(runOnBackground==false)? Colors.red:Colors.green,),
                          SizedBox(width: 8,),
                          Text("Location change", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),)
                        ],
                      ),
                      Text((points.length==0)?"0.0 Km":"${((points.length-1)*50)/1000} Km", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color:(runOnBackground==false)? Colors.black54:Colors.black),)
                    ],
                ),
            ),
      
            
          ],
        )
        ),
      ),
    );
  }
}