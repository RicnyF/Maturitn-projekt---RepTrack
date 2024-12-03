import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:flutter/cupertino.dart';

class AddRoutinesPage extends StatefulWidget {
  const AddRoutinesPage({super.key});

  @override
  State<AddRoutinesPage> createState() => _AddRoutinesPageState();
}




class _AddRoutinesPageState extends State<AddRoutinesPage> {
  final nameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  List<String> selectedExercises = [];
  List<Map<String, dynamic>> exerciseDetails = [];
  Map<String, Duration> restTimers = {};
  Future<void> selectExercises()async{
    final result = await Navigator.pushNamed(context, '/select_exercises_page');
    if (result != null && result is List<String>) {
      setState(() {
        selectedExercises += result;
        print(selectedExercises);
      });
      fetchExerciseDetails();
    }
  }
 Future<void> fetchExerciseDetails() async {
  if (selectedExercises.isEmpty) return;

 
  final snapshot = await firestore
      .collection('Exercises')
      .where(FieldPath.documentId, whereIn: selectedExercises.toSet().toList())
      .get();

 
  final exerciseMap = {for (var doc in snapshot.docs) doc.id: doc.data()};

  setState(() {

    exerciseDetails = selectedExercises.map((id) {
      final exercise = exerciseMap[id];
      if (exercise != null) {
        return {
          'id': id,
          ...exercise,
        };
      }
      return null;
    }).whereType<Map<String, dynamic>>().toList();
  });
}

Future <void> removeExercise(exercise)async{
setState(() {
  selectedExercises.remove(exercise['id']);
  restTimers.remove(exercise['id']);
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
            mode: CupertinoTimerPickerMode.ms, // Minutes and seconds mode
            initialTimerDuration: restTimers[exerciseId] ?? Duration(minutes: 0, seconds: 0),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                restTimers[exerciseId] = newDuration; // Update timer for exercise
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
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.check))],
      ),
      body: SingleChildScrollView(child:Padding(padding: EdgeInsets.all(10),child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text("Routine Name",style: TextStyle(fontSize: 25),),
        SizedBox(height: 10,),
        MyTextfield(hintText: "Routine name", obscureText: false, controller: nameController),
        SizedBox(height: 20,),
        Text("Workout Content",style: TextStyle(fontSize: 25),),
SizedBox(height: 10,),
         Column(
                    children: 
                     selectedExercises.isNotEmpty?
                    exerciseDetails.map((exercise) {
                      final exerciseId = exercise['id'];
                     final timer = restTimers[exerciseId] ?? Duration(minutes: 0, seconds: 0);
                      final timerDisplay = "${timer.inMinutes}m ${timer.inSeconds % 60}s";
                      return ListTile(
                       
                        title: Row(children:[CircleAvatar(backgroundImage: exercise["imageUrl"]!=''?
                        NetworkImage(exercise['imageUrl'],): AssetImage('images/default_profile.png')),SizedBox(width: 10,),Expanded(child:Text(exercise['name'] ?? 'Unnamed Exercise')),IconButton(onPressed: ()=>removeExercise(exercise), icon: Icon(Icons.remove, color: Colors.red,))]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          TextField(
                            
                            decoration: InputDecoration(
                              
                              labelText: "Add routine notes here"
                            ),
                          ),
                          SizedBox(height: 5,),
                          GestureDetector(
                            onTap: ()=>showTimerPicker(exerciseId),
                            child: Row(

                            children:[Icon(Icons.timer),SizedBox(width: 5,),Text("Rest Timer : "), Text(timerDisplay)]
                          ),)
                        ],),
                       
                      );
                    }).toList(): [SizedBox()],
                  ),
                
                
                        Center(child: TextButton(onPressed: selectExercises, style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 4, 163, 255))),child: Padding(padding:EdgeInsets.symmetric(horizontal: 5),child:Row(mainAxisSize: MainAxisSize.min,children: [Icon(Icons.add,size: 23,),Text("Exercise",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)],)),)),

                ]))));
                
  }
}