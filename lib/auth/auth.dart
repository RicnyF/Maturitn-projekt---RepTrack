import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/auth/login_or_register.dart';
import 'package:rep_track/pages/home_page.dart';
import 'package:rep_track/pages/sandbox.dart';



logout(BuildContext context)  {
     FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (context) => AuthPage(),
  ),
  (Route<dynamic> route) => false,
);
    }
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
       builder: (context,snapshot){
        if (snapshot.hasData){
          return  const HomePage();
        }
        else{
          return const LoginOrRegister();
        }
       })
    );
  }
}