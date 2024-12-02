import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/add_exercises_page.dart';
import 'package:rep_track/pages/edit_exercises_page.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_page.dart';
import 'package:rep_track/services/exerciseList.dart';
import 'package:rep_track/services/firestore.dart';
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

