import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';


class DatabaseService {
  //databse crud
  final _db=FirebaseFirestore.instance;
  final CollectionReference riderCollection=FirebaseFirestore.instance.collection("rider");
  final String? riderId;
  final String? adId;
  DatabaseService({required this.riderId, this.adId});
 

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
  Future createAssignedAdDocOpDate(String? ad_id, double lat, double long,String timestamp, String createdAt)async{
    
     return await riderCollection.doc(riderId).collection("assigned_ads").doc(ad_id).collection("rides").doc().set({
      'lat':lat,
      'long':long,
      'ad_id':ad_id,
      'created_at':createdAt,
      'timestamp':timestamp
     });
  }

  //get ad stream
  Stream<List<Ad_Model>> get getAssignedAd{
    return riderCollection.doc(riderId).collection("assigned_ads").snapshots().map(_adFromSnapShot);
  }
  List<Ad_Model> _adFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      
      return Ad_Model(doc.id);
    }).toList();
  }

  //get rides stream
  
  Stream<List<RidesModel>> get getRides{
    return riderCollection.doc(riderId).collection("assigned_ads").doc(adId).collection("rides").orderBy("timestamp").snapshots().map(_ridesFromSnapShot);
  }
  List<RidesModel> _ridesFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      return RidesModel(doc.id,doc.get("lat"),doc.get('long'),doc.get('timestamp'),doc.get('created_at'));
    }).toList();
  }
  
    
  
  
  
  
  }
  