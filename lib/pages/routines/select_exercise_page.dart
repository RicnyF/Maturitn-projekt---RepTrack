import 'package:flutter/material.dart';
import 'package:rep_track/services/exerciseList.dart';

class SelectExercisesPage extends StatefulWidget {
  const SelectExercisesPage({super.key});
  @override
State<SelectExercisesPage> createState() => _SelectExercisesPageState();}


class _SelectExercisesPageState extends State<SelectExercisesPage> {
  List<String> selectedExercises = [];

  void handleExerciseSelection(List<String> selected) {
    setState(() {
      selectedExercises = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Exercises"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
  
              Navigator.pop(context, selectedExercises);
            },
          )
        ],
      ),
      body: ExerciseList(
    
        isSelectionMode: true,
        onExerciseSelected: handleExerciseSelection,
      ),
    );
  }
}
