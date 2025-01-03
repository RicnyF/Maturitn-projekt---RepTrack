import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_page.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/pages/routines/edit_routines_page.dart';
import 'package:rep_track/services/firestore.dart';
import 'package:rep_track/utils/logger.dart';

class RoutineDetailPage extends StatefulWidget {
  final String routineId;
  final Map<String, dynamic> routineData;
  const RoutineDetailPage({
    super.key,
    required this.routineId,
    required this.routineData,
  });

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}
enum SampleItem { itemOne, itemTwo}
final currentUser = FirebaseAuth.instance.currentUser;

  void routineEdit(BuildContext context, Map<String, dynamic> routineData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoutinesPage(
          routineId: routineData["routineId"],
          routineData: routineData,
        ),
      ),
    );
  }


  void delete(routine,context) async {
    AppLogger.logInfo("Attempting to delete a routine...");

    final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure ?"),
              content: Text(
                  "This action will permanently delete routine ${routine['name']}!"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ))
              ],
            ));
    if (result == null || !result) {
      return;
    }
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
    }
    try {
      await FirebaseFirestore.instance
          .collection("Routines")
          .doc(routine["routineId"])
          .delete();

      if (context.mounted) {
        Navigator.pop(context);

        displayMessageToUser(
          "Routine \"${routine['name']}\" deleted successfully.",
          context,
        );
      }
      AppLogger.logInfo("Routine deleted successfully.");
    }on FirebaseAuthException catch (e, stackTrace) {
      if (context.mounted) {
        Navigator.pop(context);
        displayMessageToUser(
          "An error occurred while deleting the routine: $e",
          context,
        );
      }
      AppLogger.logError("Failed to delete routine.", e, stackTrace);
    }
  }
class _RoutineDetailPageState extends State<RoutineDetailPage> {
  
  
  SampleItem? selectedItem;

  @override
  Widget build(BuildContext context) {
   final firestore = FirestoreService();
   final isAdmin = currentUser?.email == "admin@admin.cz";
    final isCreator = widget.routineData['createdBy'] == currentUser?.uid;
   
    

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.routineData['name']),
          centerTitle: true,
          actions: [(isAdmin||isCreator)?PopupMenuButton<SampleItem>(
  onSelected: (SampleItem item) {
    setState(() {
      selectedItem = item;
    });
    switch (item) {
      case SampleItem.itemOne:
        routineEdit(context, widget.routineData);
        break;
      case SampleItem.itemTwo:
        delete(widget.routineData,context);
        break;
     
    }
  },
  itemBuilder: (BuildContext context) {
    

    return <PopupMenuEntry<SampleItem>>[
      
        const PopupMenuItem<SampleItem>(
          value: SampleItem.itemOne,
          child: Text('Edit Routine'),
        ),
      
        const PopupMenuItem<SampleItem>(
          value: SampleItem.itemTwo,
          child: Text('Delete Routine'),
        ),
      
    ];
  },
  icon: const Icon(Icons.more_vert),
):SizedBox()],
        ),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  "Workout content",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10,),
                Expanded(child:ListView.builder(
                      
                      itemCount: widget.routineData["exercises"].length,
                      itemBuilder: (context, subIndex) {
                        String exerciseId =
                            widget.routineData['exercises'][subIndex]["id"];
                        var exercise = widget.routineData['exercises'][subIndex];
                        List sets = exercise['sets'] as List<dynamic>;
                        return FutureBuilder<DocumentSnapshot>(
                          future: firestore.getDocumentById(
                              'Exercises', exerciseId),
                          builder: (context, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return SizedBox(height:500 ,child: Center(child: CircularProgressIndicator(),));
                            }
                            if (snapshot.hasError){
                              return Center(child:Text("Error ${snapshot.error}"));
                            }
                            if (snapshot.hasData) {
                              Map<String, dynamic> exerciseData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                        return ListTile(
                        
                         onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailPage(
                    exerciseId: exercise["id"],
                    exerciseData: exerciseData,
                  ),
                ),
              ),
                            title:
                            Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child:Column(
                                  
                                  children: [
                                    Row(children:[Photos(
                                      imageUrl: exerciseData['imageUrl'],
                                      height: 40,
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                  
                                          Text(
                                            exerciseData["name"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),]),
                                          SizedBox(height: 10,),
                                          Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  
                                ),
                                child:
                                Column(children:[Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: const [
                          Text("Set", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: const [
                          Text("Prev", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: const [
                          Text("KG", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: const [
                          Text("Reps", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                ListView.builder(
                  itemCount: sets.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, setIndex) {
                    var set = sets[setIndex] as Map<String, dynamic>;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(set["setType"]?.toString() ??"1"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(set['prev']?.toString() ?? "-"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                              (set['weight'] != null && set['weight'] != "") ? set['weight'].toString() : "-",
                              ),

                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                              (set['reps'] != null && set['reps'] != "") ? set['reps'].toString() : "-",
                            ),

                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20), 
              ]))],
            )));
          }
          return const Text("No data available");
        },
                          
                        );
                      }),
                )
              ],
            )));
  }
}
