import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/buttons/login_buttons.dart';
import 'package:rep_track/components/my_bold_text.dart';
import 'package:rep_track/components/my_multiple_selection_field.dart';
import 'package:rep_track/components/my_selection_field.dart';
import 'package:rep_track/components/my_textfield2.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/utils/logger.dart';




class AddExercisesPage extends StatefulWidget {
  const AddExercisesPage({super.key});

  @override
  State<AddExercisesPage> createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  final User ? currentUser = FirebaseAuth.instance.currentUser;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final TextEditingController typeController= TextEditingController();

  final TextEditingController muscleGroupController= TextEditingController();

  final TextEditingController equipmentController= TextEditingController();

  final TextEditingController muscleController= TextEditingController();

  final TextEditingController nameController= TextEditingController();
  String imageUrl = "";
  File? _imageFile; 
  final ImagePicker picker = ImagePicker(); 
final storageRef = FirebaseStorage.instance;

  // Image picker method
  Future<void> _pickImage() async {
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 1000, maxWidth: 1000);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }
  

void submit() async{
    final exerciseId = FirebaseFirestore.instance.collection('exercises').doc().id;
      AppLogger.logInfo("Attempting to save a exercise...");

    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    
    if(typeController.text.isEmpty || muscleGroupController.text.isEmpty || muscleController.text.isEmpty ||nameController.text.isEmpty || equipmentController.text.isEmpty ){
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("All fields must be filled ", context);}
      return;
    }
    final imageRef = storageRef.ref().child('exercises').child("${currentUser?.email}-${nameController.text}");
    if(_imageFile!=null){
    final imageBytes= await _imageFile!.readAsBytes();
    await imageRef.putData(imageBytes);
    imageUrl = await imageRef.getDownloadURL();
    }
      if(mounted)Navigator.pop(context);
      try{
        
        await FirebaseFirestore.instance.collection("Exercises").doc(exerciseId).set({
        'exerciseId': exerciseId,
        'name':  nameController.text,
        'trackingType': typeController.text,
        'muscleGroup': muscleGroupController.text,
        'muscles' : muscleController.text,
        'type': currentUser?.email =="admin@admin.cz" ?"predefined":"custom",
        'createdBy': currentUser?.uid,
        'imageUrl': imageUrl,
        'equipment':equipmentController.text,
        'createdAt': dateFormat.format(DateTime.now()),
        "updatedAt": dateFormat.format(DateTime.now()),
      });
     if(mounted){
        Navigator.pop(context);
        displayMessageToUser(currentUser?.email =="admin@admin.cz" ?"Exercise created for everyone":"Exercise created", context);
        AppLogger.logInfo("Exercise saved successfully.");

      }}
     on FirebaseAuthException catch (e, stackTrace) {
    AppLogger.logError("Failed to save exercise.", e, stackTrace);
  }
      
    }
    
      

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Exercise"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.cancel), color: Theme.of(context).colorScheme.inversePrimary,)
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: 
      SingleChildScrollView(padding: const EdgeInsets.all(16.0),
      
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: _pickImage,
              child: _imageFile != null
                  ? Center(
                      child:Stack(
                      
                      alignment: Alignment.topRight,
                      children: [
                    ClipOval(child:Image.file(
                      _imageFile!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )),
                    Positioned(
                      top: 5,
                      right: 5,
                      child:Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue
                        ),
                        child:Icon(
                        Icons.edit,
                        size: 30,
                        color: Colors.white,
                      ))),
                    
                    ]))
                  :Center( child:
                  Container(
                      
                      height: 150,
                      width:150,                      
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      
                      
                      child: const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )),
            ),
        SizedBox(height: 10,),
         const Row(
            children:[ 
          Icon(Icons.history, size: 25,),
          SizedBox(width: 5,),
          MyBoldText(text: "Exercise Name")]),
         const SizedBox(height: 5,),
        MyTextfield2(label: "Exercise name", controller: nameController),
          const SizedBox(height: 10,),  
         const Row(
            children:[ 
          Icon(Icons.history, size: 25,),
          SizedBox(width: 5,),
          MyBoldText(text: "Tracking type")]),
         const SizedBox(height: 5,),
        SelectionField(
              label: "Select type",
              items: ["Weight & Reps", "Bodyweight Reps", "Weighted Bodyweight", "Assisted Bodyweight", "Duration", "Distance & Duration", "Weight & Distance"],
              explanations: ["Bench press, Dumbbell Curls", "Pull Ups, Sit ups, Burpees", "Pull Ups, Sit ups, Burpees", "Assisted Pull Ups, Assisted Dips", "Planks, Yoga, Stretching", "Running, Cycling, Rowing", "Farmer Walk, Suitcase Carry"],
              controller: typeController,
            ),
          const SizedBox(height: 10,),  

          const Row(
            children:[ 
          Icon(Icons.safety_check, size: 25,),
          SizedBox(width: 5,),
          MyBoldText(text: "Target Muscles")]),
         const SizedBox(height: 5,),  
        MultipleSelectionField(
              label: "Select Muscles",
              items: ["Abdominals ", "Abductors", "Adductors", "Biceps", "Calves", "Cardio", "Forearms","Front Delt","Glutes","Hamstrings","Lats","Lower Back","Lower Chest","Middle Delt","Neck","Obliques","Quadriceps","Rear Delt","Rotator Cuff","Traps","Triceps","Upper Back","Upper Chest","Other"],

              controller: muscleController,
            ), 
            const SizedBox(height: 10,),  
          const Row(
            children:[ 
          Icon(Icons.safety_check, size: 25,),
          SizedBox(width: 5,),
          MyBoldText(text: "Muscle group")]),
         const SizedBox(height: 5,),  
        SelectionField(
              label: "Select Muscle Group",
              items: ["None", "Core", "Arms", "Back", "Chest", "Legs", "Shoulders","Neck","Cardio","Other"],

              controller: muscleGroupController,
            ),
           const SizedBox(height: 10,),  

          const Row(
            children:[ 
          Icon(Icons.safety_check, size: 25,),
          SizedBox(width: 5,),
          MyBoldText(text: "Exercise equipment")]),
         const SizedBox(height: 5,),  
        SelectionField(
              label: "Select Equipment",
              items: ["None", "Dumbbell", "Barbell", "Machine", "Plate", "Medicine Ball", "Cable Machine","Bodyweight","Other"],

              controller: equipmentController,
            ),
          MyLoginButton(text: "Submit", onTap: submit)           
        ],

     
      ),)
      ,
      resizeToAvoidBottomInset: true,
    );
  }
}