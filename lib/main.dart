import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/AdState.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rider_realtime_location/pages/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture=MobileAds.instance.initialize();
  final adState=AdState(initFuture);
  await Firebase.initializeApp();
  await Hive.initFlutter();
  var box= await Hive.openBox('riderBox');
  var state= await Hive.openBox('stateBox');
  await initializeService();
  await initializeNotifications();  
  runApp(Provider.value(
    value: adState,
    builder: (context, child)=>const MyApp(),
  ),);
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
   DartPluginRegistrant.ensureInitialized();
   

  flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
  // bring to foreground
  await Firebase.initializeApp();
  await Hive.initFlutter();
    var box = await Hive.openBox('riderBox');
    if (Hive.isBoxOpen('stateBox')) {
          await Hive.box('stateBox').close(); // Close the old in-memory view
      }
    var state=await Hive.openBox('stateBox');
    final key=state.get('state');
    db=DatabaseService(riderId:key[0]);
    rid=key[0];
    adId=key[1][0];
    late LocationSettings locationSettings= LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          
      );
    
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position? position) async{

             if(moved==false){
              moved=true;
             }else{
              Future((){
              writeData(position!,box);
             });
             }
             if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: 'FAST Ads',
                content: 'Ad is running!',
              );
            }
        });
     
     
  
}

 bool isConn=true;
 String currDate="";
 
 writeData(Position pos, var box){

        DateTime now = DateTime.now();
        String yyyy=now.year.toString();
        String mm=DateFormat('MMMM').format(now);
        String dd=now.day.toString();
        String timestamp = "${DateTime.now().millisecondsSinceEpoch}";
        box.put("$yyyy$mm$dd$timestamp",[rid,adId, pos.latitude, pos.longitude, timestamp,yyyy,mm,dd,false]);
        Future(()async{
          await syncData("$yyyy$mm$dd$timestamp",box);
        });
    }

    syncData(String k,var box)async{
      
      try {
                        
            final response = await http.get(Uri.parse('https://www.google.com'));
            if (response.statusCode == 200) {
              
              
              final key=box.get(k);
              if(currDate!="${key[5]}${key[6]}${key[7]}"){
                var documentRefYear = FirebaseFirestore.instance.collection('rider').doc(rid).collection("assigned_ads").doc(adId).collection("year").doc(key[5]);
              DocumentSnapshot documentSnapshot = await documentRefYear.get();
              if(!documentSnapshot.exists){
                await db.createDocYear(adId, key[5]);
              }
              var documentRefMonth=documentRefYear.collection("month").doc(key[6]);
              documentSnapshot = await documentRefMonth.get();
              if(!documentSnapshot.exists){
                await db.createDocMonth(adId, key[5],key[6]);
              }
              var documentRefDay=documentRefMonth.collection("day").doc(key[7]);
              documentSnapshot = await documentRefDay.get();
              if(!documentSnapshot.exists){
                await db.createDocDay(adId,key[5],key[6],key[7]);
              }
                currDate="${key[5]}${key[6]}${key[7]}";
              
              }
                await db.createAssignedAdDocOpDate(key[1], key[2], key[3],key[4],key[5],key[6],key[7]);
                key[8]=true;
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
    return StreamProvider.value(
      value: AuthService().rider,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Wrapper(),
      ),
    );
  }
}
