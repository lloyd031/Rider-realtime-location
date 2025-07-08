import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rider_realtime_location/models/Rider.dart';

class Apiservice {
  Apiservice();
  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.5:8000/api/riders/login'),

      body: {'username': username, 'password': password},
    );
    print('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String token = data['token'];
      int id = data['user']['id'];
      String fn = data['user']['fn'];
      String ln = data['user']['ln'];
      String uname = data['user']['username'];
      var box = Hive.box('userBox');
      box.put(0, [token, id, fn, ln, uname]);
      return token;
    } else {
      return null;
    }
  }

 
}
