import 'package:flutter/material.dart';

class ExerciseDetailHistoryPage extends StatelessWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const ExerciseDetailHistoryPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});


  @override
  Widget build(BuildContext context) {
    return Text("History");
  }
}