import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:flutter/cupertino.dart';

import 'package:uuid/uuid.dart';

class AddRoutinesPage extends StatefulWidget {
  const AddRoutinesPage({super.key});

  @override
  State<AddRoutinesPage> createState() => _AddRoutinesPageState();
}

class _AddRoutinesPageState extends State<AddRoutinesPage> {
  var uuid = Uuid();
  Map<String,String> selectedTypes ={};
  final nameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  List<String> selectedExercises = [];
  List<Map<String, dynamic>> exerciseDetails = [];
  Map<String, Duration> restTimers = {};
  Map<String,TextEditingController> weightControllers= {};
  Map<String,TextEditingController> repControllers= {};

  Map<String, TextEditingController> noteControllers = {};
  Future<void> selectExercises() async {
    final result = await Navigator.pushNamed(context, '/select_exercises_page');
    if (result != null && result is List<String>) {
      setState(() {
        selectedExercises += result;
        
      });
      fetchExerciseDetails();
    }
  }
void checkKeys(){
 noteControllers.keys
        .where((key) =>
            !exerciseDetails.any((exercise) => exercise['uuid'] == key))
        .toList()
        .forEach((key) {
      noteControllers[key]?.dispose();
      noteControllers.remove(key);
    });
    weightControllers.keys
        .where((key) =>
            !exerciseDetails.any((exercise) => exercise['uuid'] == key))
        .toList()
        .forEach((key) {
      weightControllers[key]?.dispose();
      weightControllers.remove(key);
    });
    repControllers.keys
        .where((key) =>
            !exerciseDetails.any((exercise) => exercise['uuid'] == key))
        .toList()
        .forEach((key) {
      repControllers[key]?.dispose();
      repControllers.remove(key);
    });
    selectedTypes.keys
        .where((key) =>
            !exerciseDetails.any((exercise) => exercise['uuid'] == key))
        .toList()
        .forEach((key) {
      
      selectedTypes.remove(key);
    });
}  

void resetRoutine() {
  setState(() {
    selectedExercises.clear();
    exerciseDetails.clear();
    selectedTypes.clear();
    restTimers.clear();
    for (var controller in noteControllers.values) {
      controller.dispose();
    }
    noteControllers.clear();
    for (var controller in weightControllers.values) {
      controller.dispose();
    }
    weightControllers.clear();
    for (var controller in repControllers.values) {
      controller.dispose();
    }
    repControllers.clear();
    
  });
 
}
  Future<void> fetchExerciseDetails() async {
    
    if (selectedExercises.isEmpty) {
      resetRoutine();
      return;
    }

    final snapshot = await firestore
        .collection('Exercises')
        .where(FieldPath.documentId,
            whereIn: selectedExercises.toSet().toList())
        .get();

    final exerciseMap = {for (var doc in snapshot.docs) doc.id: doc.data()};

    setState(() {
      exerciseDetails = selectedExercises
          .map((id) {
            final uniqueId = uuid.v1(); 
            final exercise = exerciseMap[id];
             selectedTypes.putIfAbsent(uniqueId, () => "1");
              noteControllers.putIfAbsent(uniqueId, () => TextEditingController());
              weightControllers.putIfAbsent(uniqueId, () => TextEditingController());
              repControllers.putIfAbsent(uniqueId, () => TextEditingController());
            if (exercise != null) {
              return {
                'id': id,
                "uuid": uniqueId,
                ...exercise,
              };
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    });
   checkKeys();
  }

  void saveRoutine() {
    print("Current noteControllers:");
  noteControllers.forEach((key, controller) {
    print("Exercise ID: $key, Note: ${controller.text}");
  });
  
    print("Current setTypes:");
  selectedTypes.forEach((key, value) {
    print("Exercise ID: $key, Selected Type: $value");
  });
    
  }

  Future<void> removeExercise(exercise) async {
    setState(() {
      selectedExercises.remove(exercise['id']);
      restTimers.remove(exercise['uuid']);
    });

    fetchExerciseDetails();
  }

  void showTimerPicker(String exerciseId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.ms,
            initialTimerDuration:
                restTimers[exerciseId] ?? Duration(minutes: 0, seconds: 0),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                restTimers[exerciseId] = newDuration;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Create New Routine"),
          actions: [
            IconButton(onPressed: saveRoutine, icon: Icon(Icons.check))
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Routine Name",
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MyTextfield(
                          hintText: "Routine name",
                          obscureText: false,
                          controller: nameController),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Workout Content",
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: selectedExercises.isNotEmpty
                            ? exerciseDetails.map((exercise) {
                                final exerciseId = exercise['uuid'];
                                final timer = restTimers[exerciseId] ??
                                    Duration(minutes: 0, seconds: 0);
                                final timerDisplay =
                                    "${timer.inMinutes}m ${timer.inSeconds % 60}s";
                                noteControllers.putIfAbsent(
                                    exerciseId, () => TextEditingController());
                                weightControllers.putIfAbsent(
                                    exerciseId, () => TextEditingController());
                                 repControllers.putIfAbsent(
                                    exerciseId, () => TextEditingController());            
                                if (!selectedTypes.containsKey(exerciseId)) {
                                  selectedTypes.putIfAbsent(exerciseId, () => "1");
                                  print("Initialized set type for $exerciseId");
                                }
                                return ListTile(
                                  title: Row(children: [
                                    CircleAvatar(
                                        backgroundImage: exercise["imageUrl"] !=
                                                ''
                                            ? NetworkImage(
                                                exercise['imageUrl'],
                                              )
                                            : AssetImage(
                                                'images/default_profile.png')),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: Text(exercise['name'] ??
                                            'Unnamed Exercise')),
                                    IconButton(
                                        onPressed: () =>
                                            removeExercise(exercise),
                                        icon: Icon(
                                          Icons.remove,
                                          color: Colors.red,
                                        ))
                                  ]),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: noteControllers[exerciseId],
                                        decoration: InputDecoration(
                                            labelText:
                                                "Add routine notes here"),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            showTimerPicker(exerciseId),
                                        child: Row(children: [
                                          Icon(Icons.timer),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Rest Timer : "),
                                          Text(timerDisplay)
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [Text("Sets"), 
                                            PopupMenuButton(
                                              child: Text(selectedTypes[exerciseId]?? "1"),
                                              onSelected: (value) {
                                        
                                                setState(() {
                                                selectedTypes[exerciseId]= value;});
                                               
                                              },
                                              itemBuilder: (context)=> [
                                              const PopupMenuItem(value: "W",child: Text('Warm up set')),
                                              const PopupMenuItem(value: "1",child: Text('Normal set')),
                                              const PopupMenuItem(value: "F",child: Text('Failure set')),
                                              const PopupMenuItem(value: "D",child: Text('Drop set')),
                                            ])]
                                          ),
                                          Column(
                                          children: [
                                            Text("Kg"),
                                            SizedBox(
                                              width: 60,
                                              height: 20, 
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                controller: weightControllers[exerciseId],
                                                keyboardType: TextInputType.number,
                                                
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "-",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                          Column(
                                          children: [
                                            Text("Reps"),
                                            SizedBox(
                                              width: 60,
                                              height: 20, 
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                controller: repControllers[exerciseId],
                                                keyboardType: TextInputType.number,
                                                
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "-",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }).toList()
                            : [SizedBox()],
                      ),
                      Center(
                          child: TextButton(
                        onPressed: selectExercises,
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 4, 163, 255))),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 23,
                                ),
                                Text(
                                  "Exercise",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            )),
                      )),
                    ]))));
  }
}
