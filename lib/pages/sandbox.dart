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
 


 
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{},
        child: const Icon(Icons.add),
        ),
        body:Placeholder()
         
    );
  }
}

