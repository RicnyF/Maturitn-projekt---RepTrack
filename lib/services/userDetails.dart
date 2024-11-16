import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentSnapshot<Map<String,dynamic>>> getUserDetails() async{
    final User ? currentUser = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance.collection("Users").doc(currentUser!.email).get();
  }
