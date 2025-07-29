import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rider_realtime_location/pages/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  var box= await Hive.openBox('riderBox');
  var userBox= Hive.openBox('userBox');
  var state= await Hive.openBox('stateBox');
  
  await initializeService();
  initializeNotifications();
  runApp(const MyApp(),);
}

Future<void> initializeNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Android-specific implementation
  final AndroidFlutterLocalNotificationsPlugin? androidSpecific =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  if (androidSpecific != null) {
    bool? permissionGranted = await androidSpecific.requestNotificationsPermission();
    if (permissionGranted != null && permissionGranted != true) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  }
}
 
void startBackgroundService() {
  
  final service = FlutterBackgroundService();
  service.startService();
    
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
late var db;
late String rid;
late String adId;
bool moved=false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final socket = io.io("your-server-url", <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });
  
  socket.onConnect((_) {
    print('Connected. Socket ID: ${socket.id}');
  });

  socket.onDisconnect((_) {
    print('Disconnected');
  });

  socket.on("event-name", (data) {
    // Do something here like pushing a notification
  });
   
  service.on("stop").listen((event) {
    service.stopSelf();
    flutterLocalNotificationsPlugin.cancelAll();
    print("Background process is now stopped");
  });
  
  service.on("start").listen((event) {
    // Handle start event if needed
  });
   
   

  flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
  // bring to foreground
  await Firebase.initializeApp();
  await Hive.initFlutter();
    var box = await Hive.openBox('riderBox');
    if (Hive.isBoxOpen('stateBox')) {
          await Hive.box('stateBox').close(); // Close the old in-memory view
      }
    var state=await Hive.openBox('stateBox');
    final keyState=state.get('state');
    db=DatabaseService(riderId:keyState[0]);
    rid=keyState[0];
    adId=keyState[1][0];
    late LocationSettings locationSettings= LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          
      );
    
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position? position) async{

             Future((){
              writeData(position!,box);
             });
             if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: 'FAST Ads',
                content: 'You can now start driving',
              );
            }
        });
     
     
  
}

 bool isConn=true;
 String currDate="";
 String currRider="";
 
 writeData(Position pos, var box){

        DateTime now = DateTime.now();
        String yyyy=now.year.toString();
        String mm=DateFormat('MMMM').format(now);
        String dd=now.day.toString();
        String timestamp = "${DateTime.now().millisecondsSinceEpoch}";
        String date="$mm-$dd-$yyyy";
        box.put("$date$timestamp",[rid,adId, pos.latitude, pos.longitude, timestamp,date,false]);
        Future(()async{
          await syncData("$date$timestamp",box);
        });
    }

    syncData(String k,var box)async{
      
      try {
                        
            final response = await http.get(Uri.parse('https://www.google.com'));
            if (response.statusCode == 200) {
              
              
              final key=box.get(k);
              
              if(currDate!="${key[5]}"){
                var documentRefDate = FirebaseFirestore.instance.collection('date').doc(key[5]);
              DocumentSnapshot documentSnapshot = await documentRefDate.get();
              if(!documentSnapshot.exists){
                await db.createDocDate(key[5]);
              }
                currDate="${key[5]}";
              
              }
              if(currRider!="${key[0]}"){
                var documentRefDate = FirebaseFirestore.instance.collection('date').doc(key[5]).collection("rider").doc(key[0]);
              DocumentSnapshot documentSnapshot = await documentRefDate.get();
              if(!documentSnapshot.exists){
                await db.createRiderDocToDate(key[5]);
              }
                currRider="${key[0]}";
              
              }
                await db.createAssignedAdDocOpDate(key[1], key[2], key[3],key[4],key[5]);
                key[6]=true;
                await box.put(k, key);
                isConn=true;
            } else {
              isConn=false;
            }
          } on SocketException catch (_) {
              isConn=false;
          }
    }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Wrapper(),
    );
  }
}
