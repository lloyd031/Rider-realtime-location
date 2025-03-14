import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/pages/locations.dart';
import 'package:rider_realtime_location/pages/startpage.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class Ad_List extends StatefulWidget {
  final bool viewRide;
  final String? rid;
   Ad_List(this.rid,this.viewRide);

  @override
  State<Ad_List> createState() => _Ad_ListState();
}

class _Ad_ListState extends State<Ad_List> {
  
 
  String? selectedAdId="";
  
  @override
  Widget build(BuildContext context) {
    final ads = Provider.of<List<Ad_Model>?>(context);
    
     return Column(
      children: [
        Text((widget.viewRide==false)?"Assigned Ads":"Rides History"),
        for(int i=0 ; i<ads!.length; i++)
        Column(
          children: [
            TextButton(onPressed: (){
              if(widget.viewRide==false){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>StartPage(widget.rid,ads[i].id,widget.viewRide)));
              }else{
                setState(() {
                  
                  selectedAdId=ads[i].id;
                });
              }
            },child: Text("${ads[i].id}")),
            if(widget.viewRide==true && selectedAdId==ads[i].id)
            StreamProvider<List<RidesModel>>.value(
            value: DatabaseService(riderId:widget.rid,adId: ads[i].id).getRides, 
            initialData: List.empty(),
            child:Locations(rid: widget.rid,adId: ads[i].id,) ,)
          ],
        ), 
      ],
    );
  }
}