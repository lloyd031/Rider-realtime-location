import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_realtime_location/models/Ad.dart';

class DatabaseService {
  //databse crud
  final _db=FirebaseFirestore.instance;
  final CollectionReference riderCollection=FirebaseFirestore.instance.collection("rider");
  final String? riderId;
  DatabaseService({required this.riderId});
 

  Future storeDetails(String fn, String ln,)async{
     return await riderCollection.doc(riderId).set({
      'fn':fn,
      'ln':ln
     });
  }
  Future createAssignedAdDoc(String name, String ad_id)async{
     return await riderCollection.doc(riderId).collection("assigned_ads").doc(ad_id).set({
      'name':name,
      'status':'inc'
     });
  }
  Future createAssignedAdDocOpDate(String? ad_id, double lat, double long)async{
    DateTime now = DateTime.now();
    String dateFormat=now.month.toString() +"-"+now.day.toString()+"-"+now.year.toString();
     return await riderCollection.doc(riderId).collection("assigned_ads").doc(ad_id).collection(dateFormat).doc().set({
      'lat':lat,
      'long':long
     });
  }

  //get prod stream
  Stream<List<Ad_Model>> get getAssignedAd{
    return riderCollection.doc(riderId).collection("assigned_ads").snapshots().map(_adFromSnapShot);
  }
  List<Ad_Model> _adFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      
      return Ad_Model(doc.id);
    }).toList();
  }
  
  }