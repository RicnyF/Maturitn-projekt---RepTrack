import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:rep_track/components/buttons/exercise_buttons.dart';



import 'package:rep_track/services/firestore.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
 
  final FirestoreService firestoreService = FirestoreService();
  
  final TextEditingController textController= TextEditingController();
 
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Workout"),centerTitle: true,
    backgroundColor: null,
    )
      ,
      body:Padding(
        padding: EdgeInsets.all(16), 
        child: Column(
        
         crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
            Text("Your Workout",style: TextStyle( fontSize: 30)),
            SizedBox(height: 20,),
            MyExerciseButton(text: "Start Empty workout", onTap: ()=>{Navigator.pushNamed(context, '/new_workout_page')
            },icon: Icons.fitness_center),
            SizedBox(height: 20,),
              Text("Your Collections",style: TextStyle( fontSize: 30)),
              SizedBox(height: 20,),
              MyExerciseButton(text: "Routines", onTap: ()=>{Navigator.pushNamed(context, '/routines_page')
            },icon: Icons.loop,),
             SizedBox(height: 5,),
              MyExerciseButton(text: "Exercises", onTap: ()=>{Navigator.pushNamed(context, '/exercises_page')
            }, icon:Icons.health_and_safety),
          ]
      
          ,)
          ,)
      
    );
  }
}

