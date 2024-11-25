import 'package:flutter/material.dart';


class CustomBottomAppBar extends StatefulWidget {
 final int selectedIndex;
 final ValueChanged<int> onItemTapped;
  const CustomBottomAppBar({
    super.key, required this.selectedIndex, required this.onItemTapped
  });

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  @override
  Widget build(BuildContext context) {
   
   


    return BottomNavigationBar(
          iconSize: 35,
          selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: Theme.of(context).colorScheme.secondary,
    items: <BottomNavigationBarItem>[
      
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
    currentIndex: widget.selectedIndex, //New
  onTap: widget.onItemTapped,
  );
  }
}
