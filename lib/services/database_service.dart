import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/Rider.dart';
import 'package:rider_realtime_location/models/rides_model.dart';


class DatabaseService {
  //databse crud
  final _db=FirebaseFirestore.instance;
  final CollectionReference riderCollection=FirebaseFirestore.instance.collection("rider");
  final CollectionReference adCollection=FirebaseFirestore.instance.collection("ad");
  final CollectionReference dateCollection=FirebaseFirestore.instance.collection("date");
  final String? riderId;
  final String? adId;
  final String? year;
  final String? month;
  final String? day;
  DatabaseService({required this.riderId, this.adId, this.year, this.month, this.day});
 

  Future storeDetails(String fn, String ln, String email)async{
     return await riderCollection.doc(riderId).set({
      'fn':fn,
      'ln':ln,
      'email':email,
      
     });
  }
  Future createDocDate( String? date)async{
     return await dateCollection.doc(date).set({
      'n':'d'
     });
  }
  Future createRiderDocToDate( String? date)async{
     return await dateCollection.doc(date).collection("rider").doc(riderId).set({
      'n':'d'
     });
  }
  
  Future createAssignedAdDocOpDate(String? adId, double lat, double long,String? timestamp,String? date)async{
    
     return await dateCollection.doc(date).collection("rider").doc(riderId).collection("rides").doc().set({
      'lat':lat,
      'long':long,
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
      
      return Ad_Model(doc.id,"");
    }).toList();
  }

  // ignore: slash_for_doc_comments
  /**
   * Ride Stream
   * Stream<List<RidesModel>> get getRides{
    return riderCollection.doc(riderId).collection("assigned_ads").doc(adId).collection("year").doc(year).collection("month").doc(month).collection("day").doc(day).collection("rides").orderBy("timestamp").snapshots().map(_ridesFromSnapShot);
  }
  List<RidesModel> _ridesFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      return RidesModel(doc.id,doc.get("lat"),doc.get('long'),doc.get('timestamp'));
    }).toList();
  }
   */
  
  
  
   Stream<Ad_Model?> get adData
  {
      return adCollection.doc(adId).snapshots().map(_adDataFromSnapshot);  
  }
  //
  Ad_Model? _adDataFromSnapshot(DocumentSnapshot snapshot)
  {
    
    return Ad_Model(adId,snapshot.get("name"));
  } 
  
  Stream<RiderObj?> get riderDetails
  {
      return riderCollection.doc(riderId).snapshots().map(_riderDataFromSnapshot);  
  }
  //
  RiderObj? _riderDataFromSnapshot(DocumentSnapshot snapshot)
  {
    
    return RiderObj(riderId,snapshot.get("email"),snapshot.get("fn"),snapshot.get("ln"));
  } 
  Stream<List<String>> get getYears{
    return riderCollection.doc(riderId).collection("assigned_ads").doc(adId).collection("year").snapshots().map(_yearsFromSnapShot);
  }
  List<String> _yearsFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      return doc.id;
    }).toList();
  }
  Stream<List<String>> get getMonths{
    return riderCollection.doc(riderId).collection("assigned_ads").doc(adId).collection("year").doc(year).collection("month").snapshots().map(_monthsFromSnapShot);
  }
  List<String> _monthsFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      return doc.id;
    }).toList();
  }
  Stream<List<String>> get getDays{
    return riderCollection.doc(riderId).collection("assigned_ads").doc(adId).collection("year").doc(year).collection("month").doc(month).collection("day").snapshots().map(_daysFromSnapShot);
  }
  List<String> _daysFromSnapShot(QuerySnapshot snapshot)
  {
    return snapshot.docs.map((doc){
      return doc.id;
    }).toList();
  }
  
  Future<List<RidesModel>> getDocuments(String? adId, String? yyyy, String? mm, String dd) async {
    QuerySnapshot querySnapshot = await riderCollection.doc(riderId).collection("assigned_ads").doc(adId).collection("year").doc(yyyy).collection("month").doc(mm).collection("day").doc(dd).collection("rides").orderBy("timestamp").get();
    return querySnapshot.docs.map((ride){
      //this.id, this.lat, this.long, this.timestamp
      return RidesModel("", ride.get("lat"), ride.get("long"), ride.get("timestamp"));
    }).toList();
  }

   
  }
  
  
  