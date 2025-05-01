import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/pages/components/dateAndYearDropdown.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:rider_realtime_location/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StartPage extends StatefulWidget {
  final String? rid;
  final Ad_Model? ad;
  StartPage(this.rid,this.ad);
  
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
        // used to view riders trialmark history
        Set<Polyline> _poly={};
        List<LatLng> points=[];
        bool loading=false;
        List<dynamic> keys=[];
        List<dynamic> keysToUpload=[];
        List<dynamic> keysUploaded=[];
        List<RidesModel>? trailmark=[];
        //start - all about geolocator and google map
        bool runOnBackground=false;
        late double lat;
        late double long;
        String currDate="";
        int selectedDay=0;
        bool isConn=true;
      
      @override
      void initState() {
        //keys=[];
        
          lat=9.3068;
          long=123.3054;
        
        super.initState();
      }
      
      String year='';
      String month='';
      setMonthYear(String mm, String yy){
        setState(() {
          year=yy;
          month=mm;
          selectedDay=0;
        });
        print(mm+" "+yy);
      }
      void selectDay(int day){
        setState(() {
        selectedDay=day;
        });
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
    void back(){
      keys=[];
      stopBackgroundService();
      setState(() {
          runOnBackground=false;
          });
      Navigator.pop(context);
    }
  void addPolyline(){
        points.add(LatLng(lat, long));
      _poly.clear();
      _poly.add(Polyline(polylineId: PolylineId("id"),
      points: points,
      width: 8,
      color: Colors.deepOrange));
      
      
      
    }
  void viewTrail(List<RidesModel> trail){
    setState(() {
       points.clear();
      trailmark=trail;
    });
    for(RidesModel ride in trail){
        setState(() {
          lat = ride.lat;
          long = ride.long;
          addPolyline();
          });
          }
          _goToLocation();
                                        
  }
  
  

  @override
  Widget build(BuildContext context) {
    
    
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
              Text("${(keysUploaded.length/keysToUpload.length*100).toStringAsFixed(2)}%")
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
                    child:MyDays(selectDay: selectDay, viewTrail: viewTrail,adId: widget.ad!.id,mm: month,rid:widget.rid,yy: year, dd: selectedDay,) ,),
                  if(year=="" && month=="")
                  MyDays(selectDay: selectDay, viewTrail: null,adId: widget.ad!.id,mm: month,rid:widget.rid,yy: year,dd: selectedDay,)
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
                    children:
                    [
                      Row(
                        children: [
                          Icon(Icons.map,color:Colors.green,),
                          SizedBox(width: 8,),
                          Text("Distance Traveled ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),)
                        ],
                      ),
                      Text("${(trailmark!.isEmpty)?0:((trailmark!.length-1)*100)/1000} Km", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color:Colors.black),)
                    ]
                    
                ),
            ),
      
            
          ],
        )
        ),
      ),
    );
  }
}