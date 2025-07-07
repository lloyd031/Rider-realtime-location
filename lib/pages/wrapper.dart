
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/rider.dart';
import 'package:rider_realtime_location/pages/auth/auth_wapper.dart';
import 'package:rider_realtime_location/pages/home.dart';

class Wrapper extends StatefulWidget {
  
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
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
                        SystemNavigator.pop(); // Close the dialog
                      },
                    ),
                    TextButton(
                      child: Text("Enable"),
                      onPressed: () async {
                        // Navigate to location settings (to enable location services)
                        await Geolocator.openLocationSettings();
                        Navigator.of(context).pop();
                         // Close the dialog
                      },
                    ),
                  ],
                );
              },
            );
          return Future.error('Location services are disabled.');
        }

        return await Geolocator.getCurrentPosition();
      }
      @override
  void initState() {
    // TODO: implement initState
    _determinePosition().then((value){});
    login();
    super.initState();
  }
  bool isLoggedIn=false;
  void login(){
    
     var userBox=Hive.box('userBox');
    if(userBox.isEmpty)
    {
      setState(() {
        isLoggedIn=false;
      });
    }else{
      setState(() {
        isLoggedIn=true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    
    if(isLoggedIn==false)
    {
      return Authenticate(login: login,);
    }else
    {
      var userBox=Hive.box('userBox');
      String? rider_id=userBox.get(0)[1].toString();
      return Home(rider_id,login);
      
    }
  }
}
