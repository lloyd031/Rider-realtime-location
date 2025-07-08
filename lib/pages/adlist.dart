import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/main.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/pages/startpage.dart';
import 'package:rider_realtime_location/pages/startride.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
class Ad_List extends StatefulWidget {
  final bool viewRide;
  final String? rid;
   Ad_List(this.rid,this.viewRide);

  @override
  State<Ad_List> createState() => _Ad_ListState();
}

class _Ad_ListState extends State<Ad_List> {
  
  List<Ad_Model?> adsList=[];
  Future<void> fetchAds() async {
  String rider_id=widget.rid.toString();
  final response = await http.get(Uri.parse('http://192.168.1.5:8000/api/campaigns?rider_id=$rider_id'),
  );

  if (response.statusCode == 200) {
    adsList.clear();
    final List<dynamic> data = jsonDecode(response.body);
    for (var item in data) {
      Ad_Model ad=Ad_Model(item['id'].toString(), item['name']);
      setState(() {
        adsList.add(ad);
      });
      print("ads from api "+ item['name']); // or access fields like item['name'], item['id'], etc.
    }
  } else {
    throw Exception('Failed to load users');
  }
}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //stopBackgroundService();
    fetchAds();
  }
  
  @override
  Widget build(BuildContext context) {
     
     return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        /**
         * Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Text((widget.viewRide==false)?"Available Ad":"Mao ni ang mga trailmarks sa rider sir per date", style: GoogleFonts.roboto( fontSize: 20, color: Colors.black)),
        ),
         */
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Column(
              children: [
                
                Column(
                  children: [
                    for(Ad_Model? ad in adsList)
                    AdDetail(rid: widget.rid, viewRide: widget.viewRide,ad: ad,),
                    
                  ],
                ),
                
                /**
                 * 
                 */
                if(widget.viewRide==true) 
                Text("Note: data fetched from firebase. Riders needs to sync their local db to firebase first in order to be shown here"),
                SizedBox(
                  height: 20,
                ),
              ],
                 ),
         ),
       ],
     );
     
  }
}

 class AdDetail extends StatelessWidget {
  final Ad_Model? ad;
  final String? rid;
  final bool? viewRide;
  const AdDetail({super.key, required this.rid, required this.viewRide, required this.ad});
  
  @override
  Widget build(BuildContext context) {
    
    return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => (viewRide == false)
            ? StartRide(rid, ad, false)
            : StartPage(rid, ad),
      ),
    );
  },
  child: Container(
    margin: EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            ad!.name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      ],
    ),
  ),
);
  }
}
 