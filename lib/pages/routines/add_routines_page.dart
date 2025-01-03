import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';

import 'package:rep_track/utils/logger.dart';
class AddRoutinesPage extends StatefulWidget {
  const AddRoutinesPage({super.key});

  @override
  State<AddRoutinesPage> createState() => _AddRoutinesPageState();
}

class _AddRoutinesPageState extends State<AddRoutinesPage> {

  Map<String, List<Map<String, dynamic>>> setsPerExercise = {};
  final nameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  List<String> selectedExercises = [];
  List<Map<String, dynamic>> exerciseDetails = [];
  Map<String, Duration> restTimers = {};
  Map<String, Map<int, TextEditingController>> weightControllers = {};
  Map<String, Map<int, TextEditingController>> repControllers = {};
  Map<String, TextEditingController> noteControllers = {};
  final User? currentUser = FirebaseAuth.instance.currentUser;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  Future<void> selectExercises() async {
    final result = await Navigator.pushNamed(context, '/select_exercises_page');
    
    if (result != null && result is List<String>) {
      setState(() {
        selectedExercises.addAll(result.where((id)=> !selectedExercises.contains(id)));

      });
      
      fetchExerciseDetails();
    }
  }

  void checkKeys() {
    noteControllers.keys
        .where((key) => !exerciseDetails.any((exercise) => exercise['id'] == key))
        .toList()
        .forEach((key) {
      noteControllers[key]?.dispose();
      noteControllers.remove(key);
    });

    
  
     setsPerExercise.keys
        .where((key) => !exerciseDetails.any((exercise) => exercise['id'] == key))
        .toList()
        .forEach((key) {
      setsPerExercise.remove(key);
    });
  }

  void resetRoutine() {
    setState(() {
      selectedExercises.clear();
      exerciseDetails.clear();
      restTimers.clear();
      setsPerExercise.clear();
      for (var controller in noteControllers.values) {
        controller.dispose();
      }
      noteControllers.clear();
      weightControllers.clear();
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
        .where(FieldPath.documentId, whereIn: selectedExercises.toSet().toList())
        .get();

    final exerciseMap = {for (var doc in snapshot.docs) doc.id: doc.data()};

    setState(() {
      exerciseDetails = selectedExercises
          .map((id) {
            
            final exercise = exerciseMap[id];
            if (!setsPerExercise.containsKey(id)) {
              setsPerExercise[id] = [
                {"setType": "1", "weight": "", "reps": ""}
              ];
            }
            noteControllers.putIfAbsent(id, () => TextEditingController());
            if (exercise != null) {
              return {
                'id': id,
                
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

  void saveRoutine()async {
    final routineId = FirebaseFirestore.instance.collection('Routines').doc().id;
    AppLogger.logInfo("Attempting to save a routine...");

    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    if((weightControllers.values.any((exercise)=> exercise.values.any((exercise)=> exercise.text=="")))||(repControllers.values.any((exercise)=> exercise.values.any((exercise)=> exercise.text=="")))){
      Navigator.pop(context);
      displayMessageToUser("All weights and reps must be set", context);
      AppLogger.logError("Some weights or reps are not set", );

    }
    else if(nameController.text.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("Routine name can´t be empty", context);
      AppLogger.logError("Routine name is empty.", );

    }
    else if(selectedExercises.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("No exercise is selected", context);
      AppLogger.logError("No exercises selected.", );
    }
    else{
      
      
      Navigator.pop(context);
      try{
        List<Map<String, dynamic>> exerciseData = exerciseDetails.map((exercise) {
        final id = exercise['id']; 
        return {
          
          "id": id,
          "imageURL": exercise['imageUrl'],
          "name": exercise['name'],
          "restTimer": restTimers[id]?.inSeconds ?? 0,
          "notes": noteControllers[id]?.text ?? '',
          "sets": setsPerExercise[id] ?? [], 
        };
      }).toList();

        await FirebaseFirestore.instance.collection('Routines').doc(routineId).set({
          'routineId':routineId,
          'createdBy': currentUser?.uid,
          'name': nameController.text,
          'exercises': exerciseData,
          'createdAt': dateFormat.format(DateTime.now()),
        "updatedAt": dateFormat.format(DateTime.now()),
          'type': currentUser?.email =="admin@admin.cz" ?"predefined":"custom",
        });
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("Routine saved successfully!", context);
      }
      AppLogger.logInfo("Routine saved successfully.");

      resetRoutine();
      }
       on FirebaseAuthException catch(e, stackTrace){
      AppLogger.logError("Failed to save routine.", e, stackTrace);
      
    }
    
  }
  }
  Future<void> removeExercise(exercise) async {
    setState(() {
      selectedExercises.remove(exercise['id']);
      restTimers.remove(exercise['id']);
      setsPerExercise.remove(exercise["id"]);
      noteControllers.remove(exercise["id"]);
      weightControllers.clear();
      repControllers.clear();
    });

    fetchExerciseDetails();
  }

  void showTimerPicker(String id) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.ms,
            initialTimerDuration: restTimers[id] ?? Duration(minutes: 3, seconds: 0),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                restTimers[id] = newDuration;
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
        actions: [IconButton(onPressed: saveRoutine, icon: Icon(Icons.check))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Routine Name", style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              MyTextfield(
                hintText: "Routine name",
                obscureText: false,
                controller: nameController,
              ),
              SizedBox(height: 20),
              Text("Workout Content", style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              Column(
                children: selectedExercises.isNotEmpty
                    ? exerciseDetails.map((exercise) {
                        
                        final id = exercise['id'];
                        restTimers[id]= Duration(minutes: 3, seconds: 0);
                        final timer = Duration(minutes: 3, seconds: 0);
                        final timerDisplay = "${timer.inMinutes}m ${timer.inSeconds % 60}s";

                        return ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: exercise["imageUrl"] != ''
                                    ? NetworkImage(exercise['imageUrl'])
                                    : AssetImage('images/default_profile.png'),
                              ),
                              SizedBox(width: 10),
                              Expanded(child: Text(exercise['name'] ?? 'Unnamed Exercise')),
                              IconButton(
                                onPressed: () => removeExercise(exercise),
                                icon: Icon(Icons.remove, color: Colors.red),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: noteControllers[id],
                                decoration: InputDecoration(labelText: "Add routine notes here"),
                              ),
                              SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => showTimerPicker(id),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer),
                                    SizedBox(width: 5),
                                    Text("Rest Timer : "),
                                    Text(timerDisplay),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              set(id),
                              SizedBox(height: 5),
                            ],
                          ),
                        );
                      }).toList()
                    : [SizedBox()],
              ),
              Center(
                child: SizedBox(
                  width: 350,
                  child: TextButton(
                    onPressed: selectExercises,
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Theme.of(context).colorScheme.inverseSurface, size: 23),
                          SizedBox(width: 5),
                          Text(
                            "Add exercise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.inverseSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column set(String id) {
    if (!setsPerExercise.containsKey(id)) {
      setsPerExercise[id] = [];
    }
weightControllers.putIfAbsent(id, () => {});
    repControllers.putIfAbsent(id, () => {});
    return Column(
      children: [
        ...setsPerExercise[id]!.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          weightControllers[id]!.putIfAbsent(index, ()=> TextEditingController());
          repControllers[id]!.putIfAbsent(index, ()=> TextEditingController());
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text("Set"),
                  PopupMenuButton(
                    child: Text(set["setType"] ?? index+1),
                    onSelected: (value) {
                      setState(() {
                        setsPerExercise[id]![index]["setType"] = value;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "W", child: Text('Warm up set')),
                      PopupMenuItem(value: "${index+1}", child: Text('Normal set')),
                      const PopupMenuItem(value: "F", child: Text('Failure set')),
                      const PopupMenuItem(value: "D", child: Text('Drop set')),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Kg"),
                  SizedBox(
                    width: 60,
                    height: 20,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: weightControllers[id]![index],
                      onChanged: (value) {
                        setsPerExercise[id]![index]["weight"] = value;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
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
                      controller: repControllers[id]![index],
                      onChanged: (value) {
                        setsPerExercise[id]![index]["reps"] = value;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "-",
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(onPressed: (){
                setState((){
                  if(setsPerExercise[id]!= null){
                    setsPerExercise[id]!.removeAt(index);
                    weightControllers[id]![index]?.dispose();
                    weightControllers[id]?.remove(index);
                    repControllers[id]![index]?.dispose();
                    repControllers[id]?.remove(index);
                  }
                });
              }, icon: Icon(Icons.remove, color: Colors.red,))
            ],
          );
        }),
        
         Center(
                child: SizedBox(
                  width: 350,
                  child: TextButton(
                    onPressed: () {
                    
                    setState(() {
                      final nextIndex = setsPerExercise[id]!.length + 1;

                      if (setsPerExercise[id] != null) {
                        
                          
                        
                        setsPerExercise[id]!.add({
                          "setType": nextIndex.toString(),
                          "weight": weightControllers[id]![nextIndex-2]!.text,
                          "reps": repControllers[id]![nextIndex-2]!.text,
                        });
                        
                       weightControllers[id]![nextIndex-1] = TextEditingController();
                      weightControllers[id]![nextIndex-1]!.text =  weightControllers[id]![nextIndex-2]!.text;
                      repControllers[id]![nextIndex-1] = TextEditingController();
                      repControllers[id]![nextIndex-1]!.text =  repControllers[id]![nextIndex-2]!.text;
                      }
                     
                    });

                    },
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Theme.of(context).colorScheme.inverseSurface, size: 23),
                          SizedBox(width: 5),
                          Text(
                            "Add Set",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.inverseSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        
      ],
    );
  }
}
