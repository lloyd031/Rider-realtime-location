import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Rider.dart';
import 'package:rider_realtime_location/services/auth.dart';

class MyDrawer extends StatefulWidget {
  final Function login;
  final Function? switchScreen;
  const MyDrawer({super.key, required this.switchScreen, required this.login});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final  auth=AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                    accountName: Text('Rider'), accountEmail: Text('username'),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Image.network('https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                        width: 90,
                        height:90,
                        fit:BoxFit.cover),
                      ),
                    ),
                    decoration: const BoxDecoration(
                      color:Colors.blue,
                      image: DecorationImage(image: NetworkImage('https://images.pexels.com/photos/323311/pexels-photo-323311.jpeg?auto=compress&cs=tinysrgb&w=400'
                      ),
                      fit:BoxFit.cover,
                      ),
                    ),
                    ),
                ListTile(
                  leading:const Icon(Icons.person),
                  title:const Text('My Profile'),
                  onTap: (){
                    widget.switchScreen!(0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading:const Icon(Icons.add_business_rounded),
                  title:const Text('My Ads'),
                  onTap: (){
                    widget.switchScreen!(1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading:const Icon(Icons.motorcycle),
                  title:const Text('My Rides'),
                  onTap: (){
                    widget.switchScreen!(2);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading:const Icon(Icons.upload),
                  title:const Text('Sync Data'),
                  onTap: (){
                    widget.switchScreen!(4);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading:const Icon(Icons.star),
                  title:const Text('Rate App'),
                  onTap: (){},
                ),
                ListTile(
                  leading:const Icon(Icons.share),
                  title:const Text('Share'),
                  onTap: (){},
                ),
                
                /**
                 * const Divider(),
                ListTile(
                  leading:const Icon(Icons.notifications),
                  title:const Text('Notifications'),
                  onTap: (){},
                  trailing: ClipOval(
                    child: Container(
                      color:Colors.red,
                      width:20,
                      height:20,
                      child:const Center(
                        child: Text('2',
                        style: TextStyle(fontSize: 12, color: Colors.white),),
                      )
                    ),
                  ),
                ),
                 */
                const Divider(),
                ListTile(
                  leading:const Icon(Icons.exit_to_app),
                  title:const Text('Signout'),
                  onTap: (){
                   var box=Hive.box('userBox');
                   box.clear();
                   widget.login;
                   SystemNavigator.pop();
                  },
                ),
              ],
            ),
      );
  }
}