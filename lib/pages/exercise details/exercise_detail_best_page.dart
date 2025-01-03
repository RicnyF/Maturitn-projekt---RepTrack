import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/utils/logger.dart';

class ExerciseDetailBestPage extends StatefulWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const ExerciseDetailBestPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});

  @override
  State<ExerciseDetailBestPage> createState() => _ExerciseDetailBestPageState();
}
 Future<Map<String, dynamic>?> getHighestWeightRecord(String exerciseId) async {
  AppLogger.logInfo("Attempting to get personal best...");

  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      AppLogger.logError("No user logged in.", );
      return null;
    }


    final workoutsRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('Workouts');

    final workoutsSnapshot = await workoutsRef.get();

    Map<String, dynamic>? highestWeightRecord;
    double highestWeight = 0.0;

    for (var workoutDoc in workoutsSnapshot.docs) {
      final workoutData = workoutDoc.data();

      if (workoutData.containsKey('exercises')) {
        List<dynamic> exercises = workoutData['exercises'];

        for (var exercise in exercises) {
          if (exercise['id'] == exerciseId) {
           
            for (var set in exercise['sets']) {
              final double weight = double.tryParse(set['weight']) ?? 0.0;

              if (weight > highestWeight) {
                highestWeight = weight;
                highestWeightRecord = {
                  'workoutId': workoutDoc.id,
                  'workoutName': workoutData['workoutName'] ,
                  'createdAt': workoutData['createdAt'] ,
                  'exercise': exercise,
                  'bestSet': set,
                };
              }
            }
          }
        }
      }
    }
    AppLogger.logInfo("Personal best taken successfully.");

    return highestWeightRecord;
  } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.logError("Failed to get personal best.", e, stackTrace);
    return null;
  }
}

class _ExerciseDetailBestPageState extends State<ExerciseDetailBestPage> {
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String,dynamic>?>(
      future: getHighestWeightRecord(widget.exerciseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final workout = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
             
                  children: [
                    Center(child: Text("Personal Best",style: const TextStyle(fontSize: 25))),
                    Text(
                      workout["workoutName"],
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      workout["createdAt"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 10,),
                    Row(children: [Photos(imageUrl: workout["exercise"]["imageURL"], height: 50, width: 50),SizedBox(width: 10,),Text(workout["exercise"]["name"],style: TextStyle(fontSize: 18),)]),
                   SizedBox(height: 10,),
                   Row(
                     children: [
                       Column(
                         children: [
                           Text("Highest weight",style: TextStyle(fontSize: 16,color: Colors.grey)),
                           Text("${workout['bestSet']['weight']} kg",style: TextStyle(fontSize: 16),),
                         ],
                       ),
                       SizedBox(width: 16,),
                       Column(
                         children: [
                           Text("Reps",style: TextStyle(fontSize: 16,color: Colors.grey)),
                           Text(workout['bestSet']['reps'],style: TextStyle(fontSize: 16),),
                         ],
                       ),
                     ],
                   )
                  ],
              ),
          );
          
        } else {
          return const Center(child: Text("No records found for this exercise."));
        }
      },
    );
  }
}