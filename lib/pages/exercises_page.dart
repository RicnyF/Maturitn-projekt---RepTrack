import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/pages/add_exercises_page.dart';
import 'package:rep_track/pages/edit_exercises_page.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_page.dart';
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
          List letter =[];
          return ListView.builder(
            
            itemCount: exercisesList.length,
            itemBuilder: (context, index){
            
            DocumentSnapshot document = exercisesList[index];
            String docID = document.id;
            Map <String, dynamic> data = document.data() as Map<String,dynamic>;
            String exerciseName = data['name'];
            String firstLetter = exerciseName[0].toUpperCase();
            if(!letter.contains(firstLetter)){
              letter.add(firstLetter);
             return Column(children:[Padding(padding:EdgeInsets.symmetric(horizontal: 10), child:ListTile(
              tileColor: Theme.of(context).colorScheme.primary,
              title: Text(firstLetter),
            minTileHeight: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ))),
            ExerciseListTile(exerciseName: exerciseName, docID: docID, data: data)]);
            }

            
            return ExerciseListTile(exerciseName: exerciseName, docID: docID, data: data); 
          });
        }
        else {
          return Text("No exercises");
        }
      }
      ));
  }
}

class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({
    super.key,
    required this.exerciseName,
    required this.docID,
    required this.data,
  });

  final String exerciseName;
  final String docID;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      
      title: Text(exerciseName),
    minTileHeight: 85,
    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailPage(exerciseId: docID, exerciseData: data))),
    leading: Container(
      height: 50,
      width: 50,
      
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface, 
        border: Border.all(width: 2, color: Colors.blueAccent),
      ),
      clipBehavior: Clip.antiAlias,
      child:ClipOval(
        
        child:data['imageUrl'] == "" ?
    SizedBox(height: 50,width: 50 ,child:Icon(Icons.work,size: 40,))
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
        }),))
        ,
        trailing: TextButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => EditExercisesPage(exerciseId: docID, exerciseData: data))),style: ButtonStyle(maximumSize: WidgetStatePropertyAll(Size(80,40)),shape:WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),backgroundColor: WidgetStatePropertyAll(Colors.blue)), child: Text("Edit")),
        );
  }
}