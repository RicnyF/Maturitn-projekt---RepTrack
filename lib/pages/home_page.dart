
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
 final _pageController = PageController(initialPage: 1);
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
    _pageController.animateToPage(_selectedIndex, duration: Duration(milliseconds: 200),curve: Curves.linear);
  });
}
static final List<Widget> _pages = <Widget>[
 FriendsPage(),
 WorkoutPage(),

      ProfilePage(),
      
];
 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        body:PageView(
          onPageChanged: (index){
            setState(() {
              _selectedIndex = index;
            });
            
          },
  
          controller: _pageController,
          children: _pages,
        ),
        bottomNavigationBar:CustomBottomAppBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped,)
    );
  }
}

