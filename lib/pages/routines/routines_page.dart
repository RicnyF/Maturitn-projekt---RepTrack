import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/pages/routines/edit_routines_page.dart';
import 'package:rep_track/pages/routines/routine_detail_page.dart';
import 'package:rep_track/pages/start_new_workout_page.dart';
import 'package:rep_track/services/firestore.dart';
import 'package:rep_track/utils/logger.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

enum SampleItem { itemOne, itemTwo, itemThree }

class _RoutinesPageState extends State<RoutinesPage> {
  double calculateHeight(int length){
    if(length==1){
      return 50;
    }
    else if(length ==2){
      return 120;
    }
    else {
      return 180;
    }
  }
  
  @override
  SampleItem? selectedItem;

  void delete(routine) async {
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
    if (mounted) {
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

      if (mounted) {
        Navigator.pop(context);

        displayMessageToUser(
          "Routine \"${routine['name']}\" deleted successfully.",
          context,
        );
      }
      AppLogger.logInfo("Routine deleted successfully.");
    } catch (e, stackTrace) {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser(
          "An error occurred while deleting the routine: $e",
          context,
        );
      }
      AppLogger.logError("Failed to delete routine.", e, stackTrace);
    }
  }
  
  final firestoreService = FirestoreService();
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Routines"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add_routine_page'),
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getStream("Routines"),
            builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
      
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (snapshot.hasData && snapshot.data!= null) {
                List routinesList = snapshot.data!.docs;
                return ListView.builder(
                    itemCount: routinesList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot routine = routinesList[index];
                      
                      Map<String, dynamic> routineData =
                          routine.data() as Map<String, dynamic>;
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: GestureDetector(
                            onTap:()=> routineDetailView(context, routineData),
                            child: Card(
                                elevation: 4,
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(routineData['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                            PopupMenuButton<SampleItem>(
                                              onSelected: (SampleItem item) {
                                                setState(() {
                                                  selectedItem = item;
                                                });
                                                switch (item) {
                                                  case SampleItem.itemOne:
                                                    routineEdit(context, routineData);
                                                    break;
                                                  case SampleItem.itemTwo:
                                                    delete(routineData);
                                                    break;
                                                  case SampleItem.itemThree:
                                                    routineDetailView(context, routineData);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (BuildContext
                                                      context) =>
                                                  <PopupMenuEntry<SampleItem>>[
                                                const PopupMenuItem<SampleItem>(
                                                  value: SampleItem.itemOne,
                                                  child: Text('Edit Routine'),
                                                ),
                                                PopupMenuItem<SampleItem>(
                                                  value: SampleItem.itemTwo,
                                                  child: Text('Delete Routine'),
                                                 
                                                      
                                                ),
                                                const PopupMenuItem<SampleItem>(
                                                  value: SampleItem.itemThree,
                                                  child: Text('View Details'),
                                                ),
                                              ],
                                              icon: const Icon(Icons
                                                  .more_vert), // Menu icon for each card
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        SizedBox(
                                          height: calculateHeight(routineData["exercises"].length),
                                          child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: routineData["exercises"]
                                                          .length >
                                                      3
                                                  ? 3
                                                  : routineData["exercises"]
                                                      .length,
                                              itemBuilder: (context, subIndex) {
                                                String exerciseId =
                                                    routineData['exercises']
                                                        [subIndex]["id"];
                                                var exercise =
                                                    routineData['exercises']
                                                        [subIndex];
                                                int numberOfSets =
                                                    (exercise['sets']
                                                            as List<dynamic>)
                                                        .length;
                            
                                                return ListTile(
                                                    title: FutureBuilder<
                                                        DocumentSnapshot>(
                                                  future: firestoreService
                                                      .getDocumentById(
                                                          'Exercises',
                                                          exerciseId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      Map<String, dynamic>
                                                          exerciseData =
                                                          snapshot.data!.data()
                                                              as Map<String,
                                                                  dynamic>;
                                                      return Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Photos(
                                                              imageUrl:
                                                                  exerciseData[
                                                                      'imageUrl'],
                                                              height: 40,
                                                              width: 40,
                                                            ),
                                                            SizedBox(
                                                              width: 15,
                                                            ),
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    exerciseData[
                                                                        "name"],
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                  ),
                                                                  Text(numberOfSets ==
                                                                          1
                                                                      ? "$numberOfSets Set"
                                                                      : "$numberOfSets Sets")
                                                                ])
                                                          ]);
                                                    } else {
                                                      return Text("");
                                                    }
                                                  },
                                                ));
                                              }),
                                        ),
                                        
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(20, 5, 10,0),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [routineData['exercises'].length > 3?
                                                Center(child:Text("and ${routineData['exercises'].length - 3} more",style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),)
                                                ):SizedBox.shrink(),
                                            TextButton(onPressed: ()=>Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StartNewWorkoutPage(
                                            routineRestTimers: {
                                              for (var exercise in routineData['exercises'])
                                                exercise['id']: Duration(seconds: exercise['restTimer']),
                                            },
                                            routineSelectedTypes: {
                                              for (var exercise in routineData['exercises'])
                                                exercise['id']: {"setType": "1", "setNumber": 1},
                                            },
                                            routineSelectedExercises: routineData['exercises']
                                                .map<String>((exercise) => exercise['id'] as String)
                                                .toList(),
                                            routineNoteControllers: {
                                              for (var exercise in routineData['exercises'])
                                                exercise['id']: TextEditingController(text: exercise['notes'] ?? ""),
                                            },
                                            routineWeightControllers: {
                                              for (var exercise in routineData['exercises'])
                                                exercise['id']: {
                                                  for (var i = 0; i < exercise['sets'].length; i++)
                                                    i: TextEditingController(text: exercise['sets'][i]['weight'] ?? ""),
                                                },
                                            },
                                            routineRepControllers: {
                                              for (var exercise in routineData['exercises'])
                                                exercise['id']: {
                                                  for (var i = 0; i < exercise['sets'].length; i++)
                                                    i: TextEditingController(text: exercise['sets'][i]['reps'] ?? ""),
                                                },
                                            },
                                          ),
                                        ),
                                        )
                                          ,style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(100,25)),shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),backgroundColor: WidgetStatePropertyAll(Colors.cyan)), child: Text("Start"))
                                          ],),
                                        )      
                                
                                      ],
                                    ))),
                          ));
                    });
              } else {
                return Text("No routines created");
              }
            }));
  }

  void routineDetailView(BuildContext context, Map<String, dynamic> routineData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailPage(
          routineId: routineData["routineId"],
          routineData: routineData,
        ),
      ),
    );
  }
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
}
