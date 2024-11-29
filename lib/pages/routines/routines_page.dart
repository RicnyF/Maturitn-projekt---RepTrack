import 'package:flutter/material.dart';


class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routines"),
        centerTitle: true,
        actions:[IconButton(onPressed: ()=>Navigator.pushNamed(context, '/add_routine_page'),icon: Icon(Icons.add),)],
      
      ),
      
    );
  }
}