import 'package:flutter/material.dart';


class CustomBottomAppBar extends StatelessWidget {
 final int selectedIndex;
 final ValueChanged<int> onItemTapped;
  const CustomBottomAppBar({
    super.key, required this.selectedIndex, required this.onItemTapped
  });

  @override
  Widget build(BuildContext context) {
   
   


    return BottomNavigationBar(
          iconSize: 35,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Friends',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: 'Add workout',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_box),
        label: 'Profile',
      ),
      
    ],
    currentIndex: selectedIndex, //New
  onTap: onItemTapped,
  );
  }
}
