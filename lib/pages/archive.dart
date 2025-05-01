import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class Archive extends StatefulWidget {
  final String? rid;
  const Archive({required this.rid});

  @override
  State<Archive> createState() => _ArchiveState();
}


class _ArchiveState extends State<Archive> {
final _myBox=Hive.box('riderBox');
List<dynamic> keys=[];
List<dynamic> keysUploaded=[];
List<dynamic> keysAll=[];
bool loading=false;
String currDate="";
bool isConn=true;

void uploadData()async{
        setState(() {
          loading=true;
        });
          
          for(int i=0; i<keys.length;i++){
            await SyncData(keys[i]);
            if(isConn==false){
                i=keys.length;
              }
          }
        for(int i=0; i<keysUploaded.length;i++){
            _myBox.delete("${keys[i][5]}${keys[i][6]}${keys[i][7]}${keys[i][4]}");
        }
         readData();
        
        setState(() {
        //runOnBackground=true;
        loading=false;
        });
        if(isConn==false){
                _showDialog();
        }
      
        
                         
  }
  void readData(){
      keys=[];
      keysAll=[];
      for(int i=0; i<_myBox.length; i++){
        final _key=_myBox.getAt(i);
        if(_key[0]==widget.rid && _key[8]==false){
          keys.add(_key);
        }
        keysAll.add(_key);
        
      }
    }
    //sync  to firebase if connected to internet
    SyncData(dynamic key)async{
      final db=DatabaseService(riderId: widget.rid, );
      try {
                        
                        final response = await http.get(Uri.parse('https://www.google.com'));
                        if (response.statusCode == 200) {
                          
                          
                          if(currDate!="${key[5]}${key[6]}${key[7]}"){
                            var documentRefYear = FirebaseFirestore.instance.collection('rider').doc(widget.rid).collection("assigned_ads").doc(key[1]).collection("year").doc(key[5]);
                          DocumentSnapshot documentSnapshot = await documentRefYear.get();
                          if(!documentSnapshot.exists){
                            await db.createDocYear(key, key[5]);
                          }
                          var documentRefMonth=documentRefYear.collection("month").doc(key[6]);
                          documentSnapshot = await documentRefMonth.get();
                          if(!documentSnapshot.exists){
                            await db.createDocMonth(key[1], key[5],key[6]);
                          }
                          var documentRefDay=documentRefMonth.collection("day").doc(key[7]);
                          documentSnapshot = await documentRefDay.get();
                          if(!documentSnapshot.exists){
                            await db.createDocDay(key[1],key[5],key[6],key[7]);
                          }
                          setState(() {
                            currDate="${key[5]}${key[6]}${key[7]}";
                          });
                          }
                            await db.createAssignedAdDocOpDate(key[1], key[2], key[3],key[4],key[5]
                          ,key[6],key[7]);
                          setState(() {
                            keysUploaded.add(key);
                          });
                          key[8]=true;
                          isConn=true;
                        } else {
                          isConn=false;
                        }
                      } on SocketException catch (_) {
                          isConn=false;
                      }
    }
  //show dialog if no internet
        void _showDialog(){
          showDialog(context: context, builder: 
          (context){
            return CupertinoAlertDialog(
              title: Text('No internet connection'),
              content: Text("You are not connected to the internet. All data will be saved locally. Make sure to sync it later."),
              actions: [
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                },
                child:Text("OKAY",style: TextStyle(color: Colors.blue),),),
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  uploadData();
                },
                child:Text("TRY AGAIN",style: TextStyle(color: Colors.green)),)
              ],
            );
          });
        }
    @override
  void initState() {
    // TODO: implement initState
    readData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final _db=DatabaseService(riderId: widget.rid);
    
    return (loading==true)?Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loading(),
              Text("${(keysUploaded.length/keys.length).toStringAsFixed(2)}%")
            ],
          ):Column(
      children: [
        Text("Trailmarks saved sa local db. this happen if dili ma sync sa app ang trailmarks due to internet error"),
        SizedBox(
          height: 20,
        ),
        Text("${keys.length}", style: TextStyle(fontWeight: FontWeight.bold),),
        Text("numbers of trailmarks saved"),
        SizedBox(
          height: 20,
        ),
        TextButton(onPressed: ()async{
          uploadData();
         }, child: Text("Sync")),
         SizedBox(
          height: 20,
        ),
        Text("need pa ni e improve sir. "),
        SizedBox(
          height: 20,
        ),
        Text("${keysAll.length}", style: TextStyle(fontWeight: FontWeight.bold),),
        Text("ignore this part"),
        TextButton(onPressed: ()async{
            _myBox.clear();
          
           readData();
           setState(() {});
         }, child: Text("Clear data")),
      ],
    );
  }
}