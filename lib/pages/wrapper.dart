
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/rider.dart';
import 'package:rider_realtime_location/pages/auth/auth_wapper.dart';
import 'package:rider_realtime_location/pages/auth/signup.dart';
import 'package:rider_realtime_location/pages/home.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:rider_realtime_location/pages/auth/login.dart';

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
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<RiderObj?>(context);
    if(user==null)
    {
      return Authenticate();
    }else
    {
      return Home(user.uid);
      
    }
  }
}
