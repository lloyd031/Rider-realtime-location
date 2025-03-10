import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/pages/startpage.dart';

class Ad_List extends StatefulWidget {
  final String? rid;
   Ad_List(this.rid);

  @override
  State<Ad_List> createState() => _Ad_ListState();
}

class _Ad_ListState extends State<Ad_List> {
  
  @override
  Widget build(BuildContext context) {
    final ads = Provider.of<List<Ad_Model>?>(context);
    return Column(
      children: [
        for(int i=0 ; i<ads!.length; i++)
        TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>StartPage(widget.rid,ads[i].id)));
        },child: Text("${ads[i].id}")), 
      ],
    );
  }
}