import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/pages/locations.dart';
import 'package:rider_realtime_location/pages/startpage.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

class Ad_List extends StatefulWidget {
  final bool viewRide;
  final String? rid;
   Ad_List(this.rid,this.viewRide);

  @override
  State<Ad_List> createState() => _Ad_ListState();
}

class _Ad_ListState extends State<Ad_List> {
  
 
  
  @override
  Widget build(BuildContext context) {
    final ads = Provider.of<List<Ad_Model>?>(context);
     
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
                
                for(int i=0 ; i<ads!.length; i++)
                Column(
                  children: [
                    StreamProvider<Ad_Model?>.value(
                    value: DatabaseService(riderId:widget.rid,adId: ads[i].id).adData, 
                    initialData: Ad_Model("", ""),
                    child:AdDetail(rid: widget.rid, viewRide: widget.viewRide,) ,),
                    
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
  final String? rid;
  final bool? viewRide;
  const AdDetail({super.key, required this.rid, required this.viewRide});

  @override
  Widget build(BuildContext context) {
    final adData = Provider.of<Ad_Model>(context);
    return Column(
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>StartPage(rid,adData,viewRide)));
                          },
                          child:  Text("${adData.name}",overflow: TextOverflow.ellipsis, style: GoogleFonts.roboto(fontSize: 18, color: Colors.black,)),
                        ),
                      ],
                    );
  }
}