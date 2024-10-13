import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  
  const ProfilePage({super.key});
  
  void logout (BuildContext context){
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: null,
        actions: [
          IconButton(onPressed: ()=>logout(context), icon: Icon(Icons.logout))
        ],
        backgroundColor: null,
        ));
  }
}