import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:rep_track/components/my_bottom_bar.dart';
import 'package:rep_track/pages/profile_page.dart';

import 'package:rep_track/services/firestore.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();
  //text controller
  final TextEditingController textController= TextEditingController();
 


  // open a dialog
  void openNoteBox({String? docID}){
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
      content: TextField(
        controller: textController,
        ),
        actions: [
         //save button
          ElevatedButton(
            onPressed: (){
              // add a new note
              if(docID== null){
                firestoreService.addNote(textController.text);
                }
              else{ 
                firestoreService.updateNote(docID,textController.text);
                }
                
              
              //clear the controller
              textController.clear();
              //close the box
              Navigator.pop(context);
            }, 
            child: const Text("Add")
          )
        ]
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        ),
        body:
         StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNoteStream(),
          builder: (context, snapshot){
            if (snapshot.hasData){
              List notesList = snapshot.data!.docs;
              
              
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context,index){
                  //get each doc
                  DocumentSnapshot document = notesList[index];
                  String docID= document.id;
                  
                  // get note from doc
                  Map<String, dynamic> data= document.data() as Map<String, dynamic>;
                  String noteText= data['note'];

                  //display
                  return  ListTile(
                    title:Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       IconButton(
                        onPressed: ()=>openNoteBox(docID: docID), 
                        icon: const Icon(Icons.settings)),
                      IconButton(
                        onPressed: ()=>firestoreService.deleteNote(docID), 
                        icon: const Icon(Icons.delete)),
                      ]
                    
                    ),
                    );
                }
                );
            }
            else{
              return const Text("No notes");
            }
          })
    );
  }
}

