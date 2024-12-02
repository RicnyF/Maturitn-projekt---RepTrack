import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/buttons/login_buttons.dart';
import 'package:rep_track/components/my_boldtext.dart';
import 'package:rep_track/components/my_multiple_selection_field.dart';
import 'package:rep_track/components/my_selection_field.dart';

import 'package:rep_track/components/my_textfield2.dart';
import 'package:rep_track/helper/helper_functions.dart';




class EditExercisesPage extends StatefulWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const EditExercisesPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});
  @override
  State<EditExercisesPage> createState() => _EditExercisesPageState();
}

class _EditExercisesPageState extends State<EditExercisesPage> {
  final User ? currentUser = FirebaseAuth.instance.currentUser;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final TextEditingController typeController= TextEditingController();

  final TextEditingController muscleGroupController= TextEditingController();

  final TextEditingController equipmentController= TextEditingController();

  final TextEditingController muscleController= TextEditingController();

  final TextEditingController nameController= TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  
  File? _imageFile;
  late String imageUrl;
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
  

void delete() async{
  final result = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
    title: const Text("Are you sure ?"),
    content: Text ("This action will permanently delete exercise ${widget.exerciseData['name']}!"),
    actions: [
      TextButton(onPressed: ()=> Navigator.pop(context, false), child: const Text("Cancel")),
      TextButton(onPressed: ()=> Navigator.pop(context, true), child: const Text("Delete",style: TextStyle(color: Colors.red),))
    ],
  ));
  if(result== null || !result){
  return;
  }
  if(mounted){
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
    barrierDismissible: false,
  );
  }
    try {
    await FirebaseFirestore.instance.collection("Exercises").doc(widget.exerciseId).delete();

    
    if (mounted) {
      Navigator.pop(context); 
      Navigator.of(context).pop();
      displayMessageToUser(
        "Exercise \"${widget.exerciseData['name']}\" deleted successfully.",
        context,
      );
    }
  } catch (e) {
    if(mounted){
    Navigator.pop(context);
    displayMessageToUser(
      "An error occurred while deleting the exercise: $e",
      context,
    );
    }
  }
}
void edit() async{
    final exerciseId = FirebaseFirestore.instance.collection('exercises').doc().id;
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
        
        await FirebaseFirestore.instance.collection("Exercises").doc(widget.exerciseId).update({
        'exerciseId': exerciseId,
        'name':  nameController.text,
        'trackingType': typeController.text,
        'muscleGroup': muscleGroupController.text,
        'muscles' : muscleController.text,
        'type': "custom",
        'createdBy': user?.uid,
        'imageUrl': imageUrl,
        'equipment':equipmentController.text,
        'createdAt': dateFormat.format(DateTime.now()),
        "updatedAt": dateFormat.format(DateTime.now()),
      });
     if(mounted){
        Navigator.pop(context);
        displayMessageToUser("Exercise created for everyone", context);
      
      }}
      catch(e){
        
      }
      
     
      
    }
    @override
  void initState(){
    super.initState();
    imageUrl = widget.exerciseData['imageUrl'];
    typeController.text = widget.exerciseData['trackingType'];
    muscleGroupController.text = widget.exerciseData['muscleGroup'];

    equipmentController.text = widget.exerciseData['equipment'];

    muscleController.text = widget.exerciseData['muscles'];

    nameController.text = widget.exerciseData['name'];
    
  }

      

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.exerciseData['name']}"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(onPressed: delete, icon: Icon(Icons.delete)),
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
  child: Center(
    child: Stack(
      alignment: Alignment.topRight,
      children: [
        ClipOval(
          child: _imageFile != null
              ? Image.file(
                  _imageFile!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey,
                          child: Icon(Icons.broken_image, size: 50),
                        );
                      },
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.camera_alt, size: 50),
                    ),
        ),
        
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Icon(
              Icons.edit,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  ),
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
          MyLoginButton(text: "Edit", onTap: edit)           
        ],

     
      ),)
      ,
      resizeToAvoidBottomInset: true,
    );
  }
}