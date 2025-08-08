import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/Rider.dart';
import 'package:rider_realtime_location/pages/adlist.dart';
import 'package:rider_realtime_location/pages/components/mydrawer.dart';
import 'package:rider_realtime_location/pages/startride.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class Home extends StatefulWidget {
  
  final String? rider_id;
  final String? fn;
  final String? ln;
  final String? uname;
  final Function login;
  const Home({super.key, required this.rider_id,required this.fn,required this.ln,required this.uname, required this.login});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double lat;
  late double long;
  int ads=0;
  int screenView = 1;
  var _currentIndex = 1;
  void switchScreen(int screenNumber) {
    setState(() {
      screenView = screenNumber;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    lat = 9.3068;
    long = 123.3054;
  }
  void setAds(int count){
    setState(() {
      ads=count;
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var _myStateBox = Hive.box('stateBox');
    dynamic key = _myStateBox.get('state');
    List<Color> bg = [
      Color.fromRGBO(250, 227, 237, 1.0),
      Color.fromRGBO(251, 250, 227, 1.0),
      Color.fromRGBO(220, 252, 241, 1.0),
    ];
    List<Color> brdr = [
      Color.fromRGBO(231, 81, 111, 1.0),
      Color.fromRGBO(253, 219, 103, 1.0),
      Color.fromRGBO(14, 188, 128, 1.0),
    ];
    List<IconData> icn = [
      Icons.store,
      Icons.motorcycle,
      Icons.done_all_rounded,
    ];
    List<String> lbl = ["Campaigns", "My Rides", "Completed"];

    return (_myStateBox.isNotEmpty)
        ? StartRide(key[0], Ad_Model(key[1][0], key[1][1],key[1][2], key[1][3]), true)
        : Scaffold(
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Likes
              SalomonBottomBarItem(
                icon: Icon(Icons.favorite_border),
                title: Text("Rate App"),
                selectedColor: Colors.pink,
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.home_filled),
                title: Text("Home"),
                selectedColor: Colors.pink,
              ),

              

              /// Profile
              SalomonBottomBarItem(
                icon: Icon(Icons.person),
                title: Text("Me"),
                selectedColor: Colors.pink,
              ),
            ],
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(
                    Icons.menu_rounded,
                    color: Colors.grey[600],
                    size: 30,
                  ),
                );
              },
            ),
            elevation: 1,
            shadowColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          drawer: MyDrawer(switchScreen: switchScreen, login: widget.login),

          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good to see you, ${widget.fn}",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(172, 172, 172, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "You have ",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Color.fromRGBO(51, 51, 51, 1),
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          "${ads} campaign${(ads>1)?'s':''}",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Color.fromRGBO(89, 106, 253, 1),
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "this month",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(51, 51, 51, 1),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(
                          246,
                          246,
                          246,
                          1,
                        ), // light gray background
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search campaign...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600], // gray placeholder
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(
                                245,
                                245,
                                245,
                                0.5,
                              ), // very light gray background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: bg[i],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: brdr[i],
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      icn[i],
                                      size: 24,
                                      color: brdr[i],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  lbl[i],
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Today's Campaings",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(51, 51, 51, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Ad_List(widget.rider_id, false,setAds),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color:Color.fromRGBO(250, 227, 237, 1.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 130,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ready for your ', // Or any greeting
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  'next ride?', // Or any greeting
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Image.asset(
                              'assets/rider.png',
                              height: 170, // optional
                              fit:
                                  BoxFit
                                      .cover, // optional (e.g. contain, fill, fitWidth, etc.)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
/**
 * (screenView==0)?Text("My Profile")
      :(screenView==2)?Ad_List(widget.rid,true)
      :(screenView==4)?Archive(rid: widget.rid,):
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
        
        children: [
        Ad_List(widget.rid,false),
        ],
              ),
      )
 */