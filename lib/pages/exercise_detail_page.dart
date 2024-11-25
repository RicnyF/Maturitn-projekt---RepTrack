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
      appBar: AppBar(),
      body:Text(exerciseData['name'])
    );
  }
}