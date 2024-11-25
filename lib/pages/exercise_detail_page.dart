import 'package:flutter/material.dart';

class ExerciseDetailPage extends StatelessWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const ExerciseDetailPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(exerciseData["name"], style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
        centerTitle: true,
      ),
      body:Text(exerciseData['name'])
    );
  }
}