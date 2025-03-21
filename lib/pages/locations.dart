import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/pages/startpage.dart';

class Locations extends StatefulWidget {
  final String? rid;
  final Ad_Model? ad;
  const Locations({required this.rid, required this.ad});

  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  @override
  Widget build(BuildContext context) {
    List<String?> date=[];
    final ads = Provider.of<List<RidesModel>?>(context);
    for(int i=0; i<ads!.length; i++){
      if(!date.contains(ads[i].createdAt)){
          date.add(ads[i].createdAt);
      }
    }
    return Column(
      children: [
        for(int i=0; i<date.length; i++)
        TextButton(onPressed: (){
            List<RidesModel>? myRides=[];
            for(int j=0; j<ads.length; j++){
              if(ads[j].createdAt==date[i]){
                myRides.add(ads[j]);
              }
            }
            print(myRides.length);
            print(myRides.length);
            print(myRides.length);
            print(myRides.length);
            print(myRides.length);
             Navigator.push(context, MaterialPageRoute(builder: (context)=>StartPage(widget.rid,widget.ad,true,myRides)));
             },child: Text("${date[i]}")),
        
      ],
    );
  }
}