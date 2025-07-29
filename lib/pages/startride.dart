import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/main.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/pages/wrapper.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class StartRide extends StatefulWidget {
  final String? rid;
  final Ad_Model? ad;
  final bool preserved;
  StartRide(this.rid, this.ad, this.preserved);

  @override
  State<StartRide> createState() => _StartRideState();
}

class _StartRideState extends State<StartRide> with SingleTickerProviderStateMixin {
  late double lat;
  late double long;
  bool loading = false;
  bool isRunning = false;
  List<dynamic> keys = [];
  bool uploaded = false;
  List<String> keysUploaded = [];
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
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
            content: Text(
              "Location services are disabled. Would you like to enable them?",
            ),
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
              content: Text(
                "We need location permissions to proceed. Please allow location permissions to continue.",
              ),
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
            content: Text(
              "We need location permissions to proceed. Please allow location permissions to continue.",
            ),
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
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void uploadData(_myBox) async {
    setState(() {
      loading = true;
    });

    for (int i = 0; i < keys.length; i++) {
      await SyncData(keys[i], _myBox);
      if (isConn == false) {
        i = keys.length;
      }
    }
    for (int i = 0; i < keysUploaded.length; i++) {
      _myBox.delete(keysUploaded[i]);
    }

    setState(() {
      //runOnBackground=true;
      loading = false;
    });
    if (isConn == false) {
      _showDialog(_myBox);
    } else {
      setState(() {
        uploaded = true;
      });
    }
  }

  void _showDialog(_myBox) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('No internet connection'),
          content: Text(
            "You are not connected to the internet. All data will be saved locally. Make sure to sync it later.",
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OKAY", style: TextStyle(color: Colors.blue)),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                uploadData(_myBox);
              },
              child: Text("TRY AGAIN", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  SyncData(dynamic key, _myBox) async {
    final db = DatabaseService(riderId: widget.rid);
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        if (currDate != "${key[5]}}") {
          var documentRefDate = FirebaseFirestore.instance
              .collection('date')
              .doc(key[5]);
          DocumentSnapshot documentSnapshot = await documentRefDate.get();
          if (!documentSnapshot.exists) {
            await db.createDocDate(key[5]);
          }
          setState(() {
            currDate = "${key[5]}";
          });
        }
        if (currRider != "${key[0]}") {
          var documentRefDate = FirebaseFirestore.instance
              .collection('date')
              .doc(key[5])
              .collection("rider")
              .doc(key[0]);
          DocumentSnapshot documentSnapshot = await documentRefDate.get();
          if (!documentSnapshot.exists) {
            await db.createRiderDocToDate(key[5]);
          }
          currRider = "${key[0]}";
        }
        await db.createAssignedAdDocOpDate(
          key[1],
          key[2],
          key[3],
          key[4],
          key[5],
        );
        keysUploaded.add("${key[5]}${key[4]}");
        key[6] = true;
        await _myBox.put("${key[5]}${key[4]}", key);
        keysUploaded.add("${key[5]}${key[4]}");
        isConn = true;
      } else {
        isConn = false;
      }
    } on SocketException catch (_) {
      isConn = false;
    }
  }

  void readData() async {
    if (Hive.isBoxOpen('riderBox')) {
      await Hive.box('riderBox').close(); // Close the old in-memory view
    }

    var _myBox = await Hive.openBox('riderBox'); // Reopen to sync latest data
    keys = [];
    for (int i = 0; i < _myBox.length; i++) {
      final _key = _myBox.getAt(i);
      if (_key != null && _key[0] == widget.rid && _key[1] == widget.ad!.id) {
        if (_key[6] == false) {
          keys.add(_key);
        } else {
          keysUploaded.add("${_key[5]}${_key[4]}");
        }
      }
    }
    if (keys.isNotEmpty) {
      uploadData(_myBox);
    } else {
      for (int i = 0; i < keysUploaded.length; i++) {
        _myBox.delete(keysUploaded[i]);
      }
      setState(() {
        uploaded = true;
      });
    }
  }

  @override
  void initState() {
    //keys=[];
    if (widget.preserved == false) {
      _determinePosition().then((value) {
        lat = value.latitude;
        long = value.longitude;
      });
      stopBackgroundService();
    }
  _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1), // Start just above the screen
      end: Offset(0, 0),    // Slide to normal position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
     _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final state = Hive.box('stateBox');
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child:
          (loading == true)
              ? Scaffold(
                body: Container(
                  height: double.maxFinite,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Loading()],
                  ),
                ),
              )
              : Scaffold(
                appBar: AppBar(
                  elevation: 1,
                  shadowColor: Colors.black,
                  backgroundColor: Colors.white,
                  leading:
                      (isRunning == false && widget.preserved == false)
                          ? IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back),
                          )
                          : Text(""),
                ),
                body: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 122, 193, 252), // Light blue
                          Colors.blueAccent,
                          Color(0xFF0D47A1), // Darker blue
                        ],
                      ),
                    ),
                    width: double.maxFinite,
                    child: Stack(
                      children: [

                       
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child:Container(
                            
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        0.1,
                                      ), // soft black shadow
                                      blurRadius: 6, // how soft the shadow is
                                      offset: Offset(0, 3), // x and y offset
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: Color.fromRGBO(231, 81, 111, 1.0),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Wait for the “You can now start driving” notification before closing the app.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                      
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                      
                                child: Text(
                                  (widget.ad!.name == "")
                                      ? "FAST Ads"
                                      : "${widget.ad!.name}",
                                  style: GoogleFonts.baloo2(
                                    color: Colors.grey.shade800,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Column(
                                children: [
                                  for (int i = 2; i >= 1; i--)
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        width: 10.0 * i,
                                        height: 10.0 * i,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10.0 * i,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              //Text("Realtime Rider Location", style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.red, fontSize: 20),),
                              //Lottie.asset('assets/rider.json'),
                              InkWell(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    (isRunning==true || widget.preserved==true)?SpinKitRipple(
                                      color: Colors.white,
                                      size: 120,
                                      duration: Duration(seconds: 5),
                                      
                                    ):SpinKitPulse(
                                      color: Colors.white,
                                      size: 120,
                                      duration: Duration(seconds: 8),
                                    ),
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        color:Colors.white.withOpacity(0.5)
                                      ),
                                      padding: EdgeInsets.all(20),
                      
                                      child: Image.asset(
                                        "assets/ride.png",
                                        width: 70,
                                      ),
                                    ),
                                  ],
                                ),
                      
                                onTap: () {
                                  if (uploaded == true) {
                                    if (widget.preserved == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Wrapper(),
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    if (isRunning == false &&
                                        widget.preserved == false) {
                                          _controller.forward();
                                      startBackgroundService();
                                      state.put('state', [
                                        widget.rid,
                                        [widget.ad!.id, widget.ad!.name],
                                      ]);
                                      setState(() {
                                        isRunning = true;
                                      });
                                      
                                    } else {
                                      if (uploaded == false) {
                                        stopBackgroundService();
                                        readData();
                                        setState(() {
                                          isRunning = false;
                                        });
                                      }
                                      state.clear();
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap the icon to ${(uploaded == true)
                                    ? "exit"
                                    : (isRunning == true || widget.preserved==true)
                                    ? "stop"
                                    : "start"}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                      
                          SizedBox(),
                        ],
                      ),]
                    ),
                  ),
                ),
              ),
    );
  }
}
