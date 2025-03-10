import 'package:flutter/material.dart';
import 'package:rider_realtime_location/pages/auth/signup.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/pages/startpage.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final  auth=DatabaseService();
  bool loading=false;
  @override
  Widget build(BuildContext context) {
    return(loading==true)?Loading(): Scaffold(
      body: SafeArea(child: Column(
        children: [
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>StartPage()));
          }, child: Text("ad 1")),
          SizedBox(height: 8,),
          TextButton(onPressed: ()async{
            setState(() {
              loading=true;
            });
            dynamic res = await auth.signOut();
            if(res==null){
              setState(() {
                loading=false;
              });
            }
            
            //Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUp()));
          }, child: Text("Sing Out")),
        ],
      )),
    );
  }
}