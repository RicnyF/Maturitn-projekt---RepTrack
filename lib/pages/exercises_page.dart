
import 'package:flutter/material.dart';

import 'package:rep_track/services/exerciseList.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}
 

class _ExercisesPageState extends State<ExercisesPage> {
 
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises"),
        centerTitle: true,
        
        actions: [
          IconButton(onPressed: () =>Navigator.of(context).pushNamed('/add_exercises_page'),icon: Icon(Icons.add),)

        ],
      ),
      body: ExerciseList());
  }
}

