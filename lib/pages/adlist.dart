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
  final Function setAds;
  Ad_List(this.rid, this.viewRide,this.setAds);

  @override
  State<Ad_List> createState() => _Ad_ListState();
}

class _Ad_ListState extends State<Ad_List> {
  List<Ad_Model?> adsList = [];
  
  Future<void> fetchAds() async {
    String rider_id = widget.rid.toString();
    final response = await http.get(
      Uri.parse('https://ads.getapp.com.ph/api/campaigns?rider_id=$rider_id'),
    );

    if (response.statusCode == 200) {
      adsList.clear();
      final List<dynamic> data = jsonDecode(response.body);
      for (var item in data) {
        Ad_Model ad = Ad_Model(item['id'].toString(), item['name']);
        setState(() {
          adsList.add(ad);
        });
        print(
          "ads from api " + item['name'],
        ); // or access fields like item['name'], item['id'], etc.
      }
      widget.setAds(adsList.length);
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      height: 130, // total height including padding
      child: PageView.builder(
        controller: PageController(
          viewportFraction: 1.0, //usa ka box at a
        ),
        itemCount: adsList.length,
        itemBuilder: (context, index) {
          return AdDetail(
            rid: widget.rid,
            viewRide: widget.viewRide,
            ad: adsList[index],
            indx: index,
          );
        },
      ),
    );
  }
}

/**
 * for(Ad_Model? ad in adsList)
                  AdDetail(rid: widget.rid, viewRide: widget.viewRide,ad: ad,),
 */
class AdDetail extends StatelessWidget {
  final Ad_Model? ad;
  final String? rid;
  final bool? viewRide;
  final int? indx;
  const AdDetail({
    super.key,
    required this.rid,
    required this.viewRide,
    required this.ad,
    required this.indx
  });

  @override
  Widget build(BuildContext context) {
    List<Color> bg = [
     Colors.blueAccent,
     Colors.green.shade500,
      Colors.redAccent,
    ];
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    (viewRide == false)
                        ? StartRide(rid, ad, false)
                        : StartPage(rid, ad),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: screenWidth,
          decoration: BoxDecoration(
            color:(indx!<3)?bg[indx!]:bg[indx!%3],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad!.name,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Lorem ipsum dolor sit amet, consect adipiscing elit olor.",
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    color: const Color.fromARGB(164, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "July 30 2025.",
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 28,)
                ],
              ),
              SizedBox(height: 4),
              
            ],
          ),
        ),
      ),
    );
  }
}
 /**
  * Container(
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
  */