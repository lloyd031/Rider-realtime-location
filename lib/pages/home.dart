import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/pages/adlist.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/pages/startpage.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class Home extends StatefulWidget {
  final String? rid;
  const Home(this.rid);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final  auth=AuthService();
  bool loading=false;
  @override
  Widget build(BuildContext context) {
    return(loading==true)?Loading(): Scaffold(
      body: SafeArea(child:StreamProvider<List<Ad_Model>>.value(
        value: DatabaseService(riderId:widget.rid).getAssignedAd, initialData: List.empty(),
        child:Column(
        children: [
          Ad_List(widget.rid),
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
      ) ,) ),
    );
  }
}
/**
 * 
 */