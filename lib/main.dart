import 'dart:async';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/services/auth.dart';
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
  await initializeNotifications();  
  runApp(const MyApp());
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

       flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
     
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'FAST Ads',
          'Background running',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'Fast Ads',
              'FAST ADS FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              importance: Importance.low,
              priority: Priority.low,
              silent: true,
              vibrationPattern: null,
              enableVibration: false,
              
            ),
          ),
        );
      }
    }
  });
  
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
