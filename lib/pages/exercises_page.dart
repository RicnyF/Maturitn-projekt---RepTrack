import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/add_exercises_page.dart';
import 'package:rep_track/pages/exercise_detail_page.dart';
import 'package:rep_track/services/firestore.dart';
class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}
 

class _ExercisesPageState extends State<ExercisesPage> {
 final FirestoreService firestoreService = FirestoreService();
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises"),
        centerTitle: true,
        leading: Builder(builder: (context){
          return IconButton(onPressed: ()=>Navigator.of(context).pushNamed('/home_page'), icon: Icon(Icons.arrow_back));
        }),
        actions: [
          IconButton(onPressed: () async =>
          {Navigator.of(context).pushReplacement(
   MaterialPageRoute<Future>(
    fullscreenDialog: true,
    builder: (context) {
      return AddExercisesPage();
    },
  ),
)
}, icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(  stream: firestoreService.getExercisesStream(), 
        builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
         if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.hasData){
          List exercisesList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: exercisesList.length,
            itemBuilder: (context, index){
            DocumentSnapshot document = exercisesList[index];
            String docID = document.id;
            Map <String, dynamic> data = document.data() as Map<String,dynamic>;
            String exerciseName = data['name'];
            return ListTile(title: Text(exerciseName),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailPage(exerciseId: docID, exerciseData: data))),
            leading: ClipOval(child:data['imageUrl'] == "" ?
            SizedBox(height: 50,width: 50 ,child:Icon(Icons.work,size: 50,))
            :Image.network(
                data['imageUrl'],
                fit: BoxFit.cover,
                height: 50,
                width: 50,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null){
                    return child;
                  }
                  else{ 
                  return SizedBox(height: 50,width: 50,
                    child:Center(child: CircularProgressIndicator()));}
                }),)); 
          });
        }
        else {
          return Text("No exercises");
        }
      }
      ));
  }
}