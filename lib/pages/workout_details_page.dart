import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/pages/start_new_workout_page.dart';
import 'package:rep_track/services/firestore.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final Map<String, dynamic> workoutData; 
  final String workoutId;
  const WorkoutDetailsPage({super.key,
  required this.workoutData,
  required this.workoutId
  });

  @override
  State<WorkoutDetailsPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<WorkoutDetailsPage> {
  String totalWeight ="";
   final firestore = FirestoreService();

void getWorkoutWeight(){
  int weight=0;
  for (var exercise in widget.workoutData["exercises"]){
    for (var set in exercise["sets"]){
      weight+= int.parse(set["weight"]);
        
    }
  }
  print(widget.workoutData);
  setState(() {
    totalWeight= weight.toString();
  });
}
  @override
  void initState(){
    super.initState();
    getWorkoutWeight();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("${widget.workoutData["workoutName"]}"),
            Text("${widget.workoutData["createdAt"]}",style: TextStyle(fontSize: 15),)
            ,
          ],
        ),
        centerTitle: true
      ),
      body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Overview",
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),

                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 20, 20, 20), border: Border.all(width: 4, color: const Color.fromARGB(255, 51, 51, 51)),
                  borderRadius: BorderRadius.circular(8)),
                  
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Stack(
  children: [
    Container(
      width: 160,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 51, 51, 51),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "Total weight",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            "$totalWeight kg",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    Positioned(
      top: 8,
      left: 8,
      child: Icon(
        Icons.fitness_center, // Example icon
        color: Colors.white,
        size: 20,
      ),
    ),
  ],
),
SizedBox(width: 20,),
                    Stack(
  children: [
    Container(
      width: 160,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 51, 51, 51),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "Duration",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            widget.workoutData["workoutDuration"].toString(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    Positioned(
      top: 8,
      left: 8,
      child: Icon(
        Icons.access_time, // Example icon
        color: Colors.white,
        size: 20,
      ),
    ),
  ],
)

                  ],),
                ),
                const SizedBox(height: 10,),
                

                Center(
                  child: TextButton(onPressed: ()=>Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => StartNewWorkoutPage(
                                              routineRestTimers: {
                                                for (var exercise in widget.workoutData['exercises'])
                                                  exercise['id']: Duration(seconds: exercise['restTimer']),
                                              },
                                              routineSetsPerExercise: {
                                              for (var exercise in widget.workoutData['exercises'])
                                                exercise['id']: [
                                                  for (var set in exercise['sets'])
                                                    {
                                                      "setType": set['setType'] ?? "1",
                                                      "weight": set['weight'] ?? "",
                                                      "reps": set['reps'] ?? "",
                                                    },
                                                ],
                                            },
                                              routineName: widget.workoutData["workoutName"],
                                              routineSelectedExercises: widget.workoutData['exercises']
                                                  .map<String>((exercise) => exercise['id'] as String)
                                                  .toList(),
                                              routineNoteControllers: {
                                                for (var exercise in widget.workoutData['exercises'])
                                                  exercise['id']: TextEditingController(text: exercise['notes'] ?? ""),
                                              },
                                              routineWeightControllers: {
                                                for (var exercise in widget.workoutData['exercises'])
                                                  exercise['id']: {
                                                    for (var i = 0; i < exercise['sets'].length; i++)
                                                      i: TextEditingController(text: exercise['sets'][i]['weight'] ?? ""),
                                                  },
                                              },
                                              routineRepControllers: {
                                                for (var exercise in widget.workoutData['exercises'])
                                                  exercise['id']: {
                                                    for (var i = 0; i < exercise['sets'].length; i++)
                                                      i: TextEditingController(text: exercise['sets'][i]['reps'] ?? ""),
                                                  },
                                              },
                                            ),
                                          ),
                                          )
                                            ,style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(200,25)),shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),backgroundColor: WidgetStatePropertyAll(Colors.cyan)), child: Text("Start workout")),
                ),
                Text(
                  "Workout content",
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),

                ),
                const SizedBox(height: 10,),Expanded(child:ListView.builder(
                      
                      itemCount: widget.workoutData["exercises"].length,
                      itemBuilder: (context, subIndex) {
                        String exerciseId =
                            widget.workoutData['exercises'][subIndex]["id"];
                        var exercise = widget.workoutData['exercises'][subIndex];
                        List sets = exercise['sets'] as List<dynamic>;
                        
                        
                        return ListTile(
                          /* NEED TO FIX THIS !! */
                /*            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailPage(
                    exerciseId: exercise["id"],
                    exerciseData: extendedData,
                  ),
                ),
              ),*/
                            title: FutureBuilder<DocumentSnapshot>(
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
                              return Container(
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
            ));
          }
          return const Text("No data available");
        },
                          
                        ));
                      }),
                )
        
      ],),
    ));
  }
}