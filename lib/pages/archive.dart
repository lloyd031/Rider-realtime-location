import 'dart:io';

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
final _myBox=Hive.box('riderBox');
List<dynamic> keys=[];
List<dynamic> keysAll=[];
bool loading=false;
class _ArchiveState extends State<Archive> {
  void readData(){
      keys=[];
      keysAll=[];
      for(int i=0; i<_myBox.length; i++){
        final _key=_myBox.getAt(i);
        if(_key[0]==widget.rid){
          keys.add(_key);
        }
        keysAll.add(_key);
        
      }
    }
    //sync  to firebase if connected to internet
    void SyncData(DatabaseService db)async{
      try {
                        final response = await http.get(Uri.parse('https://www.google.com'));
                        if (response.statusCode == 200) {
                          setState(() {
                            loading=true;
                          });
                          for(int i=0; i<keys.length; i++)
                          {
                            //_myBox.add([widget.rid, widget.ad_id, lat, long, timestamp]);
                             await db.createAssignedAdDocOpDate(keys[i][1], keys[i][2], keys[i][3],keys[i][4],keys[i][5]);
                             print(keys[i]);
                             _myBox.delete("${keys[i][5]}${keys[i][4]}");
                             
                          }
                          setState(() {
                            readData();
                            loading=false;
                          });
                        } else {
                          setState(() {
                            loading=false;
                             _showDialog(db);
                          });
                        }
                      } on SocketException catch (_) {
                        setState(() {
                          loading=false;
                           _showDialog(db);
                        });
                      }
    }
  //show dialog if no internet
        void _showDialog(DatabaseService db){
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
                  SyncData(db);
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
    
    return (loading==true)?Loading():Column(
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
          SyncData(_db);
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
          setState(() {
           readData();
          });
         }, child: Text("Clear data")),
      ],
    );
  }
}