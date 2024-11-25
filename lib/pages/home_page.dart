import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:rep_track/components/my_bottom_bar.dart';
import 'package:rep_track/pages/friends_page.dart';
import 'package:rep_track/pages/profile_page.dart';

import 'package:rep_track/pages/workout_page.dart';

import 'package:rep_track/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   int _selectedIndex = 1;
  
  final FirestoreService firestoreService = FirestoreService();
  
  final TextEditingController textController= TextEditingController();
 
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
static const List<Widget> _pages = <Widget>[
 FriendsPage(),
 WorkoutPage(),

      ProfilePage(),
      
];
 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
        body:_pages.elementAt(_selectedIndex),
        bottomNavigationBar:CustomBottomAppBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped,)
    );
  }
}

