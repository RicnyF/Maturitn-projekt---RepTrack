import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/services/firestore.dart';


class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
 @override
  final firestoreService = FirestoreService();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routines"),
        centerTitle: true,
        actions:[IconButton(onPressed: ()=>Navigator.pushNamed(context, '/add_routine_page'),icon: Icon(Icons.add),)],
      
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:  firestoreService.getStream("Routines"),
         builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.hasData) {
          List routinesList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: routinesList.length,
            itemBuilder: (context,index){
             DocumentSnapshot routine = routinesList[index];
            String routineID = routine.id;
            Map <String,dynamic> routineData= routine.data() as Map<String,dynamic>;
          List exercises = routineData['exercises'] ?? [];

              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child:Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            
                            Text(routineData['name']),
                            
                            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert))
                          ],),
                          const SizedBox(height: 6,),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                            itemCount: routineData["exercises"].length >3 ? 3:routineData["exercises"].length,
                              itemBuilder: 
                            (context,subIndex){
                              String exerciseId = routineData['exercises'][subIndex]["id"];
                              var exercise = routineData['exercises'][subIndex];
                              int numberOfSets = (exercise['sets'] as List<dynamic>).length; 
      
                              
                              return ListTile(
                               title: FutureBuilder<DocumentSnapshot>(
  future: firestoreService.getDocumentById('Exercises', exerciseId),
  builder: (context, snapshot) {
    if (snapshot.hasData){
      Map<String, dynamic> exerciseData =
              snapshot.data!.data() as Map<String, dynamic>;
      return Row(
        mainAxisSize: MainAxisSize.max,
        children:[
        Photos(imageUrl: exerciseData['imageUrl'],height: 40,width: 40,),SizedBox(width: 15,),Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[Text(exerciseData["name"],style: TextStyle(fontWeight: FontWeight.bold),),
        Text(numberOfSets==1?"$numberOfSets Set":"$numberOfSets Sets")])]);
    }
    else{
      return Text("No");
    }

  },)
                                
                              );
                            }),
                          )

                        ],
                      )
                    )
                  )
                  
                  );

          });
        }
        else{
          return Text("yes");
        }
        
  })
    );
  }
}