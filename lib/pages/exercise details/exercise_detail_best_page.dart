import 'package:flutter/material.dart';

class ExerciseDetailBestPage extends StatelessWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const ExerciseDetailBestPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});

  @override
  Widget build(BuildContext context) {
    return Text("Best");
  }
}