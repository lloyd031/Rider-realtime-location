
import 'dart:async';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/services/database_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rider_realtime_location/pages/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

void main()async{
  //WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
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
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final socket = io.io("your-server-url", <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });
  socket.onConnect((_) {
    print('Connected. Socket ID: ${socket.id}');
    // Implement your socket logic here
    // For example, you can listen for events or send data
  });

  socket.onDisconnect((_) {
    print('Disconnected');
  });
   socket.on("event-name", (data) {
    //do something here like pushing a notification
  });
  service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  service.on("start").listen((event) {});

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    socket.emit("event-name", "your-message");
    print("service is successfully running ${DateTime.now().second}");
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    
    print(position.latitude.toString() + " "+position.longitude.toString());
    
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: AuthService().rider,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home:  Wrapper(),
      ),
    );
  }
}
