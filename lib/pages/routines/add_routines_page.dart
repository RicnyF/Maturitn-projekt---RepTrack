import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/my_textfield.dart';

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
  Future<void> selectExercises()async{
    final result = await Navigator.pushNamed(context, '/select_exercises_page');
    if (result != null && result is List<String>) {
      setState(() {
        selectedExercises = result;
      });
      fetchExerciseDetails();
    }
  }
 Future<void> fetchExerciseDetails() async {
    if (selectedExercises.isEmpty) return;

    final snapshot = await firestore
        .collection('Exercises')
        .where(FieldPath.documentId, whereIn: selectedExercises)
        .get();

    setState(() {
      exerciseDetails = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create New Routine"),
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.check))],
      ),
      body: Padding(padding: EdgeInsets.all(10),child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text("Routine Name",style: TextStyle(fontSize: 25),),
        SizedBox(height: 10,),
        MyTextfield(hintText: "Routine name", obscureText: false, controller: nameController),
        SizedBox(height: 20,),
        Text("Workout Content",style: TextStyle(fontSize: 25),),
SizedBox(height: 10,),
        Center(child: TextButton(onPressed: selectExercises, style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 4, 163, 255))),child: Padding(padding:EdgeInsets.symmetric(horizontal: 5),child:Row(mainAxisSize: MainAxisSize.min,children: [Icon(Icons.add,size: 23,),Text("Exercise",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)],)),)),
        exerciseDetails.isNotEmpty
                ? Column(
                    children: exerciseDetails.map((exercise) {
                      return ListTile(
                        title: Text(exercise['name'] ?? 'Unnamed Exercise'),
                        subtitle: Text(exercise['description'] ?? 'No description'),
                      );
                    }).toList(),
                  )
                : const Text("No exercises selected."),])));
  }
}