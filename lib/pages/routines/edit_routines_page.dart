import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/utils/logger.dart';


class EditRoutinesPage extends StatefulWidget {
  final String routineId;
  final Map<String, dynamic> routineData;
  const EditRoutinesPage({
    super.key,
    required this.routineId,
    required this.routineData,
  });

  @override
  State<EditRoutinesPage> createState() => _EditRoutinesPageState();
}

class _EditRoutinesPageState extends State<EditRoutinesPage> {
  
  
  Map<String, List<Map<String, dynamic>>> setsPerExercise = {};
  Map<String, Map<String, dynamic>> selectedTypes = {};
  final nameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  List<Map<String, String>> selectedExercises = []; 

  List<Map<String, dynamic>> exerciseDetails = [];
  Map<String, Duration> restTimers = {};
  Map<String, TextEditingController> noteControllers = {};
  final User? currentUser = FirebaseAuth.instance.currentUser;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  
 @protected
@mustCallSuper
@override
void initState() {
  super.initState();
  
  nameController.text = widget.routineData["name"]; 
  
  if (widget.routineData["exercises"] != null) {
    for (var exercise in widget.routineData["exercises"]) {
      final String exerciseId = exercise["id"];
     
      
    selectedExercises.add({"id": exerciseId});
      setsPerExercise[widget.routineId] = (exercise["sets"] as List<dynamic>?)
              ?.map((set) => Map<String, dynamic>.from(set))
              .toList() ??
          [
            {"setType": "1", "weight": "", "reps": ""}
          ];

      
      restTimers[widget.routineId] = Duration(seconds: exercise["restTimer"] ?? 0);

      
      noteControllers[widget.routineId] = TextEditingController(text: exercise["notes"] ?? "");

      
      selectedTypes.putIfAbsent(widget.routineId, () => {"setType": "1", "setNumber": 1});
    }
  }

  fetchExerciseDetails();
}
  Future<void> selectExercises() async {
  final result = await Navigator.pushNamed(context, '/select_exercises_page');

  if (result != null && result is List<String>) {
    setState(() {
      
      for (var id in result) {
        if(!selectedExercises.any((exercise)=>exercise["id"]==id)){
        selectedExercises.add({
          
          "id": id,
        });
        
        
        setsPerExercise[id] = [
          {"setType": "1", "weight": "", "reps": ""}
        ];
        restTimers[id] = Duration(seconds: 0);
        noteControllers[id] = TextEditingController();
        }
  }});
  
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

    selectedTypes.keys
        .where((key) => !exerciseDetails.any((exercise) => exercise['id'] == key))
        .toList()
        .forEach((key) {
      selectedTypes.remove(key);
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
      selectedTypes.clear();
      restTimers.clear();
      for (var controller in noteControllers.values) {
        controller.dispose();
      }
      noteControllers.clear();
    });
  }

  Future<void> fetchExerciseDetails() async {
    
    if (selectedExercises.isEmpty) {
      resetRoutine();
      return;
    }

    final List<String> exerciseIds = selectedExercises
    .map((exercise) => exercise["id"] as String)
    .toList();

final snapshot = await firestore
    .collection('Exercises')
    .where(FieldPath.documentId, whereIn: exerciseIds)
    .get();


    final exerciseMap = {for (var doc in snapshot.docs) doc.id: doc.data()};

    setState(() {
  exerciseDetails = selectedExercises.map((exerciseData) {
    final String? id = exerciseData["id"];
    final String? exerciseId = exerciseData["id"];

    final existingExercise = widget.routineData["exercises"]?.firstWhere(
      (exercise) => exercise["id"] == id,
      orElse: () => null,
    );

    final exercise = exerciseMap[exerciseId];

    selectedTypes.putIfAbsent(id!, () => {"setType": "1", "setNumber": 1});
    if (!setsPerExercise.containsKey(id)) {
      setsPerExercise[id] = (existingExercise?["sets"] as List<dynamic>?)
              ?.map((set) => Map<String, dynamic>.from(set))
              .toList() ??
          [
            {"setType": "1", "weight": "", "reps": ""}
          ];
    }

    noteControllers.putIfAbsent(
        id,
        () => TextEditingController(text: existingExercise?["notes"] ?? ""));

    if (exercise != null) {
      return {
        "id": exerciseId,
        ...exercise, 
      };
    }
    return null;
  }).whereType<Map<String, dynamic>>().toList();
});
checkKeys();
  }

  void editRoutine()async {
    final routineId = widget.routineId;
    AppLogger.logInfo("Attempting to edit a routine...");

    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    
    if(nameController.text.isEmpty){
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

        await FirebaseFirestore.instance.collection('Routines').doc(routineId).update({
          'routineId':routineId,
          'createdBy': currentUser?.uid,
          'name': nameController.text,
          'exercises': exerciseData,
        "updatedAt": dateFormat.format(DateTime.now()),
          'type': currentUser?.email =="admin@admin.cz" ?"predefined":"custom",
        });
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("Routine edited successfully!", context);
      }
      AppLogger.logInfo("Routine edited successfully.");

      resetRoutine();
      }
       on FirebaseAuthException catch(e, stackTrace){
      AppLogger.logError("Failed to edit routine.", e, stackTrace);
      
    }
    
  }
  }
  Future<void> removeExercise(exercise) async {
    setState(() {
      selectedExercises.remove(exercise['id']);
      restTimers.remove(exercise['id']);
      selectedTypes.remove(exercise["id"]);
      noteControllers.remove(exercise["id"]);
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
            initialTimerDuration: restTimers[exerciseId] ?? Duration(minutes: 0, seconds: 0),
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
        title: Text("Edit routine - ${widget.routineData["name"]}"),
        actions: [IconButton(onPressed: editRoutine, icon: Icon(Icons.check))],
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
                        
                        final exerciseId = exercise['id'];
                        final timer = restTimers[exerciseId] ?? Duration(minutes: 0, seconds: 0);
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
                                controller: noteControllers[exerciseId],
                                decoration: InputDecoration(labelText: "Add routine notes here"),
                              ),
                              SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => showTimerPicker(exerciseId),
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
                              set(exerciseId),
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

  Column set(String exerciseId) {
    if (!setsPerExercise.containsKey(exerciseId)) {
      setsPerExercise[exerciseId] = [];
    }
 
    return Column(
      children: [
        ...setsPerExercise[exerciseId]!.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          TextEditingController weightController = TextEditingController(
          text: set["weight"] == "-" ? "" : set["weight"],
        );
        TextEditingController repController = TextEditingController(
          text: set["reps"] == "-" ? "" : set["reps"],
        );
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text("Set ${index + 1}"),
                  PopupMenuButton(
                    initialValue: setsPerExercise[exerciseId]![index]["setType"],
                    child: Text(set["setType"] ?? "1"),
                    onSelected: (value) {
                      
                     
                      setState(() {
                        setsPerExercise[exerciseId]![index]["setType"] = value;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "W", child: Text('Warm up set')),
                      const PopupMenuItem(value: "1", child: Text('Normal set')),
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
                      controller: weightController,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setsPerExercise[exerciseId]![index]["weight"] = value;
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      controller: repController,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setsPerExercise[exerciseId]![index]["reps"] = value;
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  if(setsPerExercise[exerciseId]!= null){
                    setsPerExercise[exerciseId]!.removeAt(index);
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
                      if (setsPerExercise[exerciseId] != null) {
                        setsPerExercise[exerciseId]!.add({
                          "setType": "1",
                          "weight": "",
                          "reps": "",
                        });
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
