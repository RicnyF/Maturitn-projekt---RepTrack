import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
      appBar: AppBar(
      automaticallyImplyLeading: false,
      title: 
      const Text("Friends"),
      centerTitle: true,),

    );
  }
}