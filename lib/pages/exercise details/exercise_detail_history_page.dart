import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/profile_page.dart';

class ExerciseDetailHistoryPage extends StatefulWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData;
  const ExerciseDetailHistoryPage({
    super.key,
    required this.exerciseId,
    required this.exerciseData,
  });

  @override
  State<ExerciseDetailHistoryPage> createState() =>
      _ExerciseDetailHistoryPageState();
}

class _ExerciseDetailHistoryPageState extends State<ExerciseDetailHistoryPage> {
  Map<String, Map<String, dynamic>> fetchedWorkouts = {};
  Map<String, Map<String, dynamic>> fetchedExercises = {};

  Future<Map<String, Map<String, dynamic>>> getExercisesForUser(
      String exerciseId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("No user is logged in.");
        return {};
      }

      print(currentUser.uid);

      final workoutsRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Workouts');

      final workoutsSnapshot = await workoutsRef.get();

      for (var workoutDoc in workoutsSnapshot.docs) {
        final workoutData = workoutDoc.data();

        if (workoutData.containsKey('exercises')) {
          List<dynamic> exercises = workoutData['exercises'];

          for (var exercise in exercises) {
            if (exercise['id'] == exerciseId) {
              fetchedWorkouts[workoutDoc.id] = workoutData;
              fetchedExercises[workoutDoc.id] = exercise;
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching exercises for user: $e");
    }

    return fetchedExercises;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: getExercisesForUser(widget.exerciseId),
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
          final exercises = snapshot.data!;
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final workoutId = exercises.keys.elementAt(index);
              final exercise = exercises[workoutId]!;
              final workoutData = fetchedWorkouts[workoutId]!;

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutData["workoutName"] ?? "Unnamed Workout",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      workoutData["createdAt"] ?? "Unknown Date",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 10,)
                  ],
                ),
               subtitle: Column(
                 children: [
                   Row(children: [Photos(imageUrl: exercise["imageURL"], height: 50, width: 50),SizedBox(width: 10,),Text(exercise["name"],style: TextStyle(fontSize: 18),)]),
                   SizedBox(height: 10,),
                   
                   Row(
                     
                     children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Text("SET",style: TextStyle(fontSize: 16,color: Colors.grey)),
                           SizedBox(height: 5,),
                           for (var set in exercise["sets"])
                             Text(set["setType"],style: TextStyle(fontSize: 16),),
                         ],
                       ),
                       SizedBox(width: 20), 
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("WEIGHT & REPS",style: TextStyle(fontSize: 16,color: Colors.grey)),
                           SizedBox(height: 5,),
                           for (var set in exercise["sets"])
                             Text(" ${set["weight"]}kg x ${set["reps"]} reps",style: TextStyle(fontSize: 16)),
                         ],
                       ),
                       
                     ],
                   ),
                 ],
               ),

                 
);
            },
          );
        } else {
          return const Center(child: Text("No history found for this exercise."));
        }
      },
    );
  }
}
