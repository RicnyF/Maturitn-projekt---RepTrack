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
  //firestore
  final FirestoreService firestoreService = FirestoreService();
  //text controller
  final TextEditingController textController= TextEditingController();
 


  // open a dialog
  void openNoteBox({String? docID}){
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
      content: TextField(
        controller: textController,
        ),
        actions: [
         //save button
          ElevatedButton(
            onPressed: (){
              // add a new note
              if(docID== null){
                firestoreService.addNote(textController.text);
                }
              else{ 
                firestoreService.updateNote(docID,textController.text);
                }
                
              
              //clear the controller
              textController.clear();
              //close the box
              Navigator.pop(context);
            }, 
            child: const Text("Add")
          )
        ]
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout"),centerTitle: true,
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

