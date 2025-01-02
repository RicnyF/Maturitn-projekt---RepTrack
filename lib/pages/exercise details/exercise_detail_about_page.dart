import 'package:flutter/material.dart';

class ExerciseDetailAboutPage extends StatelessWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const ExerciseDetailAboutPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10),
      child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
          child:(Container(
          
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          image: exerciseData['imageUrl'] != ''? DecorationImage(image:NetworkImage(exerciseData['imageUrl']),fit: BoxFit.cover): null,
          color: Theme.of(context).colorScheme.primary,
          border: Border.all(width: 4,color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(12)
        
        ),
        child: exerciseData['imageUrl']==''? Center(child:Text("Image is not yet available",style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.6),fontSize: 17),)): null,
        ))),
        SizedBox(height: 20,),
        Text("About", style: TextStyle(fontSize: 20)),
        Divider(thickness: 1.5,color: Theme.of(context).colorScheme.secondary,),
        Row(children: [Text("Exercise type • ", style: TextStyle(fontSize: 18)),Text(exerciseData['trackingType'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))]),
        Row(children: [Text("Equipment • ", style: TextStyle(fontSize: 18)),Text(exerciseData['equipment'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))]),
      Row(children: [Text("Main muscle group • ", style: TextStyle(fontSize: 18)),Text(exerciseData['muscleGroup'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))]),
      Row(children: [Text("Muscles • ", style: TextStyle(fontSize: 18)),Text(exerciseData['muscles'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))]),
      ],
    ));
  }
}