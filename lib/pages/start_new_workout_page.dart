import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:uuid/uuid.dart';
import 'package:rep_track/utils/logger.dart';
class StartNewWorkoutPage extends StatefulWidget {
  const StartNewWorkoutPage({super.key});

  @override
  State<StartNewWorkoutPage> createState() => _StartNewWorkoutPageState();
}

class _StartNewWorkoutPageState extends State<StartNewWorkoutPage> {
  var uuid = Uuid();
  late Timer timer; //
  String elapsedTime = "00:00:00"; 
  final stopwatch = Stopwatch();
  Map<String, Map<int, bool>> done = {};
  Map<String, List<Map<String, dynamic>>> setsPerExercise = {};
  Map<String, Map<String, dynamic>> selectedTypes = {};
  final workoutNotesController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  List<String> selectedExercises = [];
  List<Map<String, dynamic>> exerciseDetails = [];
  Map<String, Duration> restTimers = {};
  Map<String, TextEditingController> noteControllers = {};
  Map<String, Map<int, TextEditingController>> weightControllers = {};
  Map<String, Map<int, TextEditingController>> repControllers = {};

  final User? currentUser = FirebaseAuth.instance.currentUser;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  Future<void> selectExercises() async {
    final result = await Navigator.pushNamed(context, '/select_exercises_page');
    
    if (result != null && result is List<String>) {
      setState(() {
        selectedExercises += result;
      });
      
      fetchExerciseDetails();
    }
  }

  void checkKeys() {
    noteControllers.keys
        .where((key) => !exerciseDetails.any((exercise) => exercise['uuid'] == key))
        .toList()
        .forEach((key) {
      noteControllers[key]?.dispose();
      noteControllers.remove(key);
    });

    selectedTypes.keys
        .where((key) => !exerciseDetails.any((exercise) => exercise['uuid'] == key))
        .toList()
        .forEach((key) {
      selectedTypes.remove(key);
    });
  
     setsPerExercise.keys
        .where((key) => !exerciseDetails.any((exercise) => exercise['uuid'] == key))
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
      weightControllers.clear();
      repControllers.clear();
      noteControllers.clear();
    });
  }

  Future<void> fetchExerciseDetails() async {
    
    if (selectedExercises.isEmpty) {
      resetRoutine();
      print("Reset");
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
            final uniqueId = uuid.v1();
            final exercise = exerciseMap[id];
            selectedTypes.putIfAbsent(uniqueId, () => {"setType": "1", "setNumber": 1});
            if (!setsPerExercise.containsKey(uniqueId)) {
              setsPerExercise[uniqueId] = [
                {"setType": "1", "weight": "", "reps": ""}
              ];
            }
            noteControllers.putIfAbsent(uniqueId, () => TextEditingController());
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
  void saveWorkout()async{

  }
  void saveRoutine()async {
    final routineId = FirebaseFirestore.instance.collection('Routines').doc().id;
    AppLogger.logInfo("Attempting to save a routine...");

    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    
    if(workoutNotesController.text.isEmpty){
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
        final uuid = exercise['uuid']; 
        return {
          "uuid": uuid,
          "id": exercise['id'],
          "imageURL": exercise['imageUrl'],
          "name": exercise['name'],
          "restTimer": restTimers[uuid]?.inSeconds ?? 0,
          "notes": noteControllers[uuid]?.text ?? '',
          "sets": setsPerExercise[uuid] ?? [], 
        };
      }).toList();

        await FirebaseFirestore.instance.collection('Routines').doc(routineId).set({
          'routineId':routineId,
          'createdBy': currentUser?.uid,
          'name': workoutNotesController.text,
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
      catch(e, stackTrace){
      AppLogger.logError("Failed to save routine.", e, stackTrace);
      
    }
    
  }
  }
  Future<void> removeExercise(exercise) async {
    setState(() {
      selectedExercises.remove(exercise['id']);
      
    });

    fetchExerciseDetails();
    print(restTimers);
    print (noteControllers);
    print(selectedExercises);
    print(weightControllers);
    print(
      selectedTypes);
    print(exerciseDetails
    );
  }

  void showTimerPicker(String exerciseUuid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.ms,
            initialTimerDuration: restTimers[exerciseUuid] ?? Duration(minutes: 0, seconds: 0),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                restTimers[exerciseUuid] = newDuration;
              });
            },
          ),
        );
      },
    );
  }
  @override
  void initState(){
    super.initState();
    stopwatch.start();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        elapsedTime = _formatDuration(stopwatch.elapsed);
      });
  });}
   @override
  void dispose() {
    selectedExercises.clear();
    exerciseDetails.clear();
    selectedTypes.clear();
    restTimers.clear();
    weightControllers.clear();
    repControllers.clear();
    noteControllers.clear();
    stopwatch.stop(); 
    timer.cancel(); 
    super.dispose();
  }
   String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(elapsedTime),
        actions: [IconButton(onPressed: saveWorkout, icon: Icon(Icons.check))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Workout notes", style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              MyTextfield(
                hintText: "notes",
                obscureText: false,
                controller: workoutNotesController,
              ),
              SizedBox(height: 20),
              Text("Workout Content", style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              Column(
                children: selectedExercises.isNotEmpty
                    ? exerciseDetails.map((exercise) {
                        
                        final exerciseUuid = exercise['uuid'];
                        final timer = restTimers[exerciseUuid] ?? Duration(minutes: 0, seconds: 0);
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
                                
                                controller: noteControllers[exerciseUuid],
                                decoration: InputDecoration(labelText: "Add routine notes here"),
                              ),
                              SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => showTimerPicker(exerciseUuid),
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
                              set(exerciseUuid),
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

  Column set(String exerciseUuid) {
    if (!setsPerExercise.containsKey(exerciseUuid)) {
      setsPerExercise[exerciseUuid] = [];
    }
    done.putIfAbsent(exerciseUuid, () => {});
    weightControllers.putIfAbsent(exerciseUuid, () => {});
    repControllers.putIfAbsent(exerciseUuid, () => {});

    return Column(
      children: [
        ...setsPerExercise[exerciseUuid]!.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final last = setsPerExercise[exerciseUuid]!.length -1;
          weightControllers[exerciseUuid]!.putIfAbsent(index, ()=> TextEditingController());
          repControllers[exerciseUuid]!.putIfAbsent(index, ()=> TextEditingController());
          done[exerciseUuid]!.putIfAbsent(index, () => false);
          return Container(
            decoration: BoxDecoration(
              color: done[exerciseUuid]![index] == true? Theme.of(context).colorScheme.primary: Theme.of(context).colorScheme.surface
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Set"),
                    PopupMenuButton(
                      child: Text(set["setType"] ?? index+1),
                      onSelected: (value) {
                        setState(() {
                          setsPerExercise[exerciseUuid]![index]["setType"] = value;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "W", child: Text('Warm up set')),
                        PopupMenuItem(value: "${index+1}", child: Text('Normal set')),
                        const PopupMenuItem(value: "F", child: Text('Failure set')),
                        const PopupMenuItem(value: "D", child: Text('Drop set')),
                        if(index==last)PopupMenuItem(onTap: (){
                          weightControllers[exerciseUuid]![index]?.dispose();
                          weightControllers[exerciseUuid]?.remove(index);

                          repControllers[exerciseUuid]![index]?.dispose();
                          repControllers[exerciseUuid]?.remove(index);
                          done[exerciseUuid]!.remove(index);
                          setsPerExercise[exerciseUuid]!.removeAt(index);
                        }, child: Text('Delete Set',style: TextStyle(color: Colors.red),)),
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
                        controller: weightControllers[exerciseUuid]![index],

                        onChanged: (value) {
                          setsPerExercise[exerciseUuid]![index]["weight"] = value;
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
                        controller: repControllers[exerciseUuid]![index],
                        onChanged: (value) {
                          setsPerExercise[exerciseUuid]![index]["reps"] = value;
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
                IconButton(onPressed: (index==0&& !done[exerciseUuid]!.containsKey(index+1))||(index==0 &&done[exerciseUuid]![index + 1] == false )|| (index > 0 && (done[exerciseUuid]![index - 1] == true)&&done[exerciseUuid]![index+1]!= true) ?(){
                  setState((){
                    if(done[exerciseUuid]![index]!= true){
                      done[exerciseUuid]![index]= true;
                      
                    }
                    else{
                      done[exerciseUuid]![index]= false;
                    }
                    
                  });
                }:null
                
                
                , icon: Icon(Icons.done_rounded, color:done[exerciseUuid]![index] == false?  Theme.of(context).colorScheme.secondary:Colors.green))
                ,
                
              ],
            ),
          );
        }),
        SizedBox(height: 10,),
         Center(
                child: SizedBox(
                  width: 350,
                  child: TextButton(
                    onPressed: () {
                    setState(() {
                      final nextIndex = setsPerExercise[exerciseUuid]!.length + 1;

                      if (setsPerExercise[exerciseUuid] != null) {
                        setsPerExercise[exerciseUuid]!.add({
                          "setType": nextIndex.toString(),
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
