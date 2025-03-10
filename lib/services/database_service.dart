import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rider_realtime_location/models/rider.dart';

class DatabaseService {
  //databse crud
  final _db=FirebaseFirestore.instance;
  final _auth=FirebaseAuth.instance;
  
  //create rider model
  RiderObj? _UserFromFirebase(User? user)
  {
    
    return user!=null?RiderObj(user.uid):null;
  }
  //listen to authentication changes
  Stream<RiderObj?> get rider{
    return _auth.authStateChanges().map(_UserFromFirebase);
  }
  //authentication
  
  //signup with email and password
   Future signUp(String email, String pw) async
   {
      try{
          UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: pw);
          User? user=result.user;
          //create a document for the user with uid in firebase
          //await DatabaseService(user?.uid,user?.email,null).updateUserData(fn, ln, profile,accType);
          return _UserFromFirebase(user);
      }catch(e)
      {
          print(e.toString());
          return null;
      }
   }
 Future signIn(String email, String password) async
   {
      try{
          UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
          User? user=result.user;
          return _UserFromFirebase(user);
      }catch(e)
      {
          return null;
      }
   }

   //signout
  Future signOut() async
    { 
      try
      {
          return await _auth.signOut();
      }catch(e)
      {
          print(e.toString());
          return null;
      }
    }
trackLocation(double lat, double long){
    try{
      _db.collection("locations").add({
        "long":long.toString(),
        "lat":lat.toString()
      });
      
    }catch(e){}
  }
}