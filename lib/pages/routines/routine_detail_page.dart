import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/services/firestore.dart';

class RoutineDetailPage extends StatelessWidget {
  final String routineId;
  final Map<String, dynamic> routineData;
  const RoutineDetailPage({
    super.key,
    required this.routineId,
    required this.routineData,
  });
  
  @override
  Widget build(BuildContext context) {
   final firestore = FirestoreService();
   Map<String, dynamic> extendedData = {};
   
   
    

    return Scaffold(
        appBar: AppBar(
          title: Text(routineData['name']),
          centerTitle: true,
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
                      
                      itemCount: routineData["exercises"].length,
                      itemBuilder: (context, subIndex) {
                        String exerciseId =
                            routineData['exercises'][subIndex]["id"];
                        var exercise = routineData['exercises'][subIndex];
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
              ],
            )));
  }
}
