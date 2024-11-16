import 'package:flutter/material.dart';

class StartNewWorkoutPage extends StatelessWidget {
  const StartNewWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Workout"),
        centerTitle: true,
      ),
    );
  }
}