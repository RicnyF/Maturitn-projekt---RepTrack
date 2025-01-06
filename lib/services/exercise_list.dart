import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_page.dart';
import 'package:rep_track/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({
    super.key,
    
    this.isSelectionMode = false,
    this.onExerciseSelected,
  });


  final bool isSelectionMode; 
  final Function(List<String>)? onExerciseSelected; 

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}


class _ExerciseListState extends State<ExerciseList> {
  final List<String> selectedExercises = [];
  final firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;

  void toggleSelection(String docID) {
    setState(() {
      if (selectedExercises.contains(docID)) {
        selectedExercises.remove(docID);
      } else {
        selectedExercises.add(docID);
      }
    });

    if (widget.onExerciseSelected != null) {
      widget.onExerciseSelected!(selectedExercises);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getStream("Exercises"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.hasData) {
          /*Dotaz na získání informacích o cviku*/
          final List<DocumentSnapshot> exercisesList = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final createdBy = data['createdBy'];
            final type = data['type'];

            // admin vidí všechny cviky
            if (currentUser?.email == "admin@admin.cz") {
              return true;
            }

            // Uživatelé vidí jen cviky, které vytvořili nebo pokud jsou před definované
            return createdBy == currentUser?.uid || type == "predefined";
          }).toList();

          List<String> letter = [];
          return ListView.builder(
            itemCount: exercisesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = exercisesList[index];
              String docID = document.id;
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String exerciseName = data['name'];
              String firstLetter = exerciseName[0].toUpperCase();

              if (!letter.contains(firstLetter)) {
                letter.add(firstLetter);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.primary,
                        title: Text(firstLetter),
                        minVerticalPadding: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ExerciseListTile(
                      exerciseName: exerciseName,
                      docID: docID,
                      data: data,
                      isSelected: selectedExercises.contains(docID),
                      isSelectionMode: widget.isSelectionMode,
                      onToggleSelection: toggleSelection,
                    )
                  ],
                );
              }

              return ExerciseListTile(
                exerciseName: exerciseName,
                docID: docID,
                data: data,
                isSelected: selectedExercises.contains(docID),
                isSelectionMode: widget.isSelectionMode,
                onToggleSelection: toggleSelection,
              );
            },
          );
        } else {
          return const Text("No exercises");
        }
      },
    );
  }
}



class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({
    super.key,
    required this.exerciseName,
    required this.docID,
    required this.data,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onToggleSelection,
  });

  final String exerciseName;
  final String docID;
  final Map<String, dynamic> data;
  final bool isSelected; 
  final bool isSelectionMode; 
  final Function(String)? onToggleSelection; 

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exerciseName),
      minVerticalPadding: 20,
      onTap: () {
        if (isSelectionMode && onToggleSelection != null) {
          onToggleSelection!(docID);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExerciseDetailPage(exerciseId: docID,exerciseData: data,),
            ),
          );
        }
      },
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(width: 2, color: Colors.blueAccent),
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipOval(
          child: data['imageUrl'] == ""
              ? Image.asset("images/no_img.jpg")
              : Image.network(
                  data['imageUrl'],
                  fit: BoxFit.cover,
                  height: 50,
                  width: 50,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
        ),
      ),
      trailing: isSelectionMode
          ? Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? Colors.blue : Colors.grey,
            )
          : null
    );
  }
}