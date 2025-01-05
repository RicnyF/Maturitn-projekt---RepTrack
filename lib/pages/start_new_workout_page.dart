import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:timer_count_down/timer_controller.dart';

import 'package:rep_track/utils/logger.dart';
import 'package:timer_count_down/timer_count_down.dart';
class StartNewWorkoutPage extends StatefulWidget {
  final Map<String, Duration> routineRestTimers;
  final Map<String, List<Map<String, dynamic>>> routineSetsPerExercise;

  final List<String> routineSelectedExercises;
  final Map<String, TextEditingController> routineNoteControllers;
  final Map<String, Map<int, TextEditingController>> routineWeightControllers;
  final Map<String, Map<int, TextEditingController>> routineRepControllers;
  final String routineName;
  const StartNewWorkoutPage({super.key,
  this.routineRestTimers = const{},
  this.routineSetsPerExercise = const {},
  this.routineSelectedExercises = const [],
  this.routineNoteControllers = const {},
  this.routineWeightControllers = const{},
  this.routineRepControllers = const {},
  this.routineName = "",
  });

  @override
  State<StartNewWorkoutPage> createState() => _StartNewWorkoutPageState();
}

class _StartNewWorkoutPageState extends State<StartNewWorkoutPage> {
  
  late Timer timer;
  Map<String,CountdownController> countdownControllers={};
  DateFormat format = DateFormat.ms();
  String elapsedTime = "00:00:00"; 
  final stopwatch = Stopwatch();
  Map<String, bool> countdownState = {};
  Map<String, Map<int, bool>> done = {};
  Map<String, List<Map<String, dynamic>>> setsPerExercise = {};
  final workoutNameController = TextEditingController();
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
        selectedExercises.addAll(result.where((id)=> !selectedExercises.contains(id)));
      });
      
      fetchExerciseDetails();
    }
  }
void showCountdownOverlay(String id) {
  double deficit = 0;
  double totalDuration = restTimers[id]!.inSeconds.toDouble();
  double remainingTime = totalDuration;
  bool paused= false;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.25, // Increased height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 
                      Text("Rest timer",style: TextStyle(fontSize: 28),),
                      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (remainingTime - 15 > 0) {
                              deficit -= 15;
                            }
                          });
                        },
                        child: Text("-15", style: TextStyle(color: Colors.red)),
                      ),
                      Countdown(
                        seconds: totalDuration.toInt(),
                        controller: countdownControllers[id],
                        build: (_, double time) {
                          remainingTime = time + deficit;
                          final progress = (remainingTime / totalDuration).clamp(0.0, 1.0);

                          return Column(
                            children: [
                              Text(
                                remainingTime.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4, 
                                height: 10, 
                                child: LinearProgressIndicator(
                                  value: progress,
                                  color: Colors.blue,
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                            ],
                          );
                        },
                        onFinished: () {
                          Navigator.pop(context);
                          countdownControllers[id]!.restart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Rest time completed!')),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            deficit += 15;
                          });
                        },
                        child: Text("+15", style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if(!paused){
                            setState((){paused= true;});
                          countdownControllers[id]!.pause();
                          }
                          else{
                            setState((){paused= false;});
                            
                            countdownControllers[id]!.start();

                          }
                        },
                        child: Text(!paused?'Pause':"Resume",style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          countdownControllers[id]!.restart();
                          setState((){
                            deficit=0;
                          });
                        },
                        child: Text('Restart',style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          countdownControllers[id]!.restart();
                        },
                        child: Text('Skip',style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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
      weightControllers.clear();
      repControllers.clear();
      noteControllers.clear();
      setsPerExercise.clear();
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

  void saveWorkout()async{
    
    final workoutId = FirebaseFirestore.instance.collection('Routines').doc().id;
    AppLogger.logInfo("Attempting to save a workout...");
showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    if(selectedExercises.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("At least one exercise must be selected", context);
      AppLogger.logError("No exercise selected.", );
      return;
    }
    if(done.values.any((exercise)=> exercise.containsValue(false))){
      Navigator.pop(context);
      displayMessageToUser("All exercises must be done", context);
      AppLogger.logError("Some exercises are not done.", );
      return;
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
      await FirebaseFirestore.instance
    .collection('Users') 
    .doc(currentUser?.uid)
    .collection('Workouts') 
    .doc(workoutId)
    .set({
          "workoutName":workoutNameController.text,
          'workoutId':workoutId,
          'exercises': exerciseData,
          "workoutDuration" : elapsedTime,
          'createdAt': dateFormat.format(DateTime.now()),
          "updatedAt": dateFormat.format(DateTime.now()),

        });
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("Workout saved successfully!", context);
      }
      AppLogger.logInfo("Workout saved successfully.");

      resetRoutine();
      }
      on FirebaseAuthException catch(e,stackTrace){
      AppLogger.logError("Failed to save routine.", e, stackTrace);
      }
      
    }
  }
 
  Future<void> removeExercise(exercise) async {
    setState(() {
      selectedExercises.remove(exercise['id']);
      restTimers.remove(exercise['id']);
      done.remove(exercise["id"]);
      weightControllers.remove(exercise["id"]);
      repControllers.remove(exercise["id"]);
      noteControllers.remove(exercise["id"]);
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
void initState() {
  super.initState();
  workoutNameController.text = widget.routineName;
  setsPerExercise= widget.routineSetsPerExercise.isNotEmpty ? widget.routineSetsPerExercise: setsPerExercise;
  restTimers = widget.routineRestTimers.isNotEmpty ? widget.routineRestTimers : restTimers;
  selectedExercises = widget.routineSelectedExercises.isNotEmpty ? widget.routineSelectedExercises : selectedExercises;
  noteControllers = widget.routineNoteControllers.isNotEmpty ? widget.routineNoteControllers : noteControllers;
  weightControllers = widget.routineWeightControllers.isNotEmpty ? widget.routineWeightControllers : weightControllers;
  repControllers = widget.routineRepControllers.isNotEmpty ? widget.routineRepControllers : repControllers;

 
  stopwatch.start();
  timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
    setState(() {
      elapsedTime = _formatDuration(stopwatch.elapsed);
    });
  });
  fetchExerciseDetails();
}

   @override
  void dispose() {
    selectedExercises.clear();
    exerciseDetails.clear();
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
              Text("Workout name", style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              MyTextfield(
                hintText: "name",
                obscureText: false,
                controller: workoutNameController,
              ),
              SizedBox(height: 20),
              Text("Workout Content", style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              Column(
                children: selectedExercises.isNotEmpty
                    ? exerciseDetails.map((exercise) {
                        
                        final id = exercise['id'];
                        final restTimer = restTimers[id] ?? Duration(minutes: 3, seconds: 0);
                        
                        final timerDisplay = "${restTimer.inMinutes}m ${restTimer.inSeconds % 60}s";
                        restTimers.putIfAbsent(id,()=> Duration(minutes: 3, seconds: 0));
                        countdownControllers.putIfAbsent(id,()=> CountdownController());
                        countdownState.putIfAbsent(id,()=> false);
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
                                
                                controller: noteControllers["id"],
                                decoration: InputDecoration(labelText: "Add exercise notes here"),
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
      setsPerExercise["id"] = [];
    }
    done.putIfAbsent(id, () => {});
    weightControllers.putIfAbsent(id, () => {});
    repControllers.putIfAbsent(id, () => {});

    return Column(
      
      
      children: [
        ...setsPerExercise[id]!.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final last = setsPerExercise[id]!.length -1;
          weightControllers[id]!.putIfAbsent(index, ()=> TextEditingController());
          repControllers[id]!.putIfAbsent(index, ()=> TextEditingController());
          done[id]!.putIfAbsent(index, () => false);
          return Container(
            decoration: BoxDecoration(
              color: done[id]![index] == true? Theme.of(context).colorScheme.primary: Theme.of(context).colorScheme.surface
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
                          setsPerExercise[id]![index]["setType"] = value;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "W", child: Text('Warm up set')),
                        PopupMenuItem(value: "${index+1}", child: Text('Normal set')),
                        const PopupMenuItem(value: "F", child: Text('Failure set')),
                        const PopupMenuItem(value: "D", child: Text('Drop set')),
                        if(index==last)PopupMenuItem(onTap: (){
                          weightControllers[id]![index]?.dispose();
                          weightControllers[id]?.remove(index);

                          repControllers[id]![index]?.dispose();
                          repControllers[id]?.remove(index);
                          done[id]!.remove(index);
                          setsPerExercise[id]!.removeAt(index);
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
                        controller: weightControllers[id]![index],

                        onChanged: (value) {
                          setsPerExercise[id]![index]["weight"] = value;
                          
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
                        textAlign: TextAlign.center,
                        controller: repControllers[id]![index],
                        onChanged: (value) {
                          setsPerExercise[id]![index]["reps"] = value;
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
                IconButton(onPressed: (index==0&& !done[id]!.containsKey(index+1))||(index==0 &&done[id]![index + 1] == false )|| (index > 0 && (done[id]![index - 1] == true)&&done[id]![index+1]!= true) ?(){
                  setState((){
                    
                    if(done[id]![index]!= true){
                      if(weightControllers[id]![index]!.text ==""||repControllers[id]![index]!.text ==""){
                        displayMessageToUser("Please set all weights and reps to proceed.", context);
                        
                      }
                      else if(restTimers[id]!.inSeconds== 0){
                        displayMessageToUser("Please set a rest timer greater than 0 seconds to proceed.", context);
                      }
                      else{
                      done[id]![index]= true;
                      countdownState[id]= true;
                      showCountdownOverlay(id);

                      Future.delayed(Duration(milliseconds: 500),(){
                          countdownControllers[id]!.start();
                      });
                      }
                    }
                    else{
                      done[id]![index]= false;
                      

                    }
                    
                  });
                }:null
                
                
                , icon: Icon(Icons.done_rounded, color:done[id]![index] == false?  Theme.of(context).colorScheme.secondary:Colors.green))
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
