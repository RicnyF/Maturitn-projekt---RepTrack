import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rep_track/components/buttons/login_buttons.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/services/firestore.dart';
import 'package:rep_track/utils/logger.dart';

class EditProfilePage extends StatefulWidget {
  
  EditProfilePage({super.key,

  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
final User ? currentUser = FirebaseAuth.instance.currentUser;

  final storageRef = FirebaseStorage.instance;
  final firestore = FirestoreService();
TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController birthdayController = TextEditingController();
 String imageUrl ="";


class _EditProfilePageState extends State<EditProfilePage> {
 
   Future<void> saveProfile() async {
  if (usernameController.text.isEmpty || emailController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Username and email cannot be empty!')),
    );
    return;
  }

  try {
    AppLogger.logInfo("Attempting to save profile...");
    
    if (currentUser != null && currentUser!.email != emailController.text) {
      await currentUser!.verifyBeforeUpdateEmail(emailController.text);
    }

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.uid)
        .update({
      'username': usernameController.text,
      'email': emailController.text,
      'birthDate': birthdayController.text,
      'updatedAt': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );

    AppLogger.logInfo("Profile saved successfully.");
  } catch (e, stackTrace) {
    AppLogger.logError("Failed to save profile.", e, stackTrace);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update profile. Please try again.')),
    );
  }
}


 Future<void> editPfp(user)async{
    AppLogger.logInfo("Attempting to edit profile picture...");
   final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 1000, maxWidth: 1000);
    if (image == null) return;
    final imageRef = storageRef.ref().child(user!['username']);
    try{
    final imageBytes= await image.readAsBytes();
    await imageRef.putData(imageBytes);
    final imageUrl = await imageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).set({
        'photoURL': imageUrl,
        'updatedAt': DateTime.now(),
      },SetOptions(merge: true));
    AppLogger.logInfo("Profile picture edited successfully.");
    }
    
    catch(e,stackTrace){
      AppLogger.logError("Failed to edit profile picture.", e, stackTrace);

    }
    getImageUrl();
   
  }

  void controllersFill(){
  }
 @override
 void initState(){
  super.initState;
  
  getImageUrl();
}
Future<void> getImageUrl()async{
    AppLogger.logInfo("Attempting to get image url...");

    final userDoc = await firestore.getUserDetails(currentUser);
     Map<String, dynamic>? userData = userDoc.data();
     final url= userData!['photoURL'];    
      usernameController.text= userData["username"];
      emailController.text = userData["email"];
      birthdayController.text = userData["birthDate"];
      
      if (url!="") {
      try {
        
        setState((){
          imageUrl = url;
        });
        AppLogger.logInfo("Image url taken successfully.");

      } catch (e,stackTrace) {
       AppLogger.logError("Failed to get image url.", e, stackTrace);

      }
     
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit profile"),
        centerTitle: true,
        actions: [ElevatedButton(
  onPressed: saveProfile,
  child: Icon(Icons.save),
),]

      ),
      body: FutureBuilder(
          future: 
          firestore.getUserDetails(currentUser),
          builder:(context, snapshot) {
           if(snapshot.connectionState== ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          } 
          if(snapshot.hasError){
            return Text("Error: ${snapshot.error}");

          }
          else{
            final user = snapshot.data;
            return   SingleChildScrollView(
              child: Padding(

                
                        padding: const EdgeInsets.all(25),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.topRight,
                children: 
                [
                  
                Photos(imageUrl: imageUrl,height: 150, width: 150,)
                ,
                
                Positioned (

                    right: 5,
                    top: 5,
                    child: GestureDetector(
                    onTap: ()=>editPfp(user),
                    child: Container( decoration: BoxDecoration(
                      
                  color: Theme.of(context).colorScheme.inversePrimary, // Button background color
                  shape: BoxShape.circle, // Circular button
                    
                ),
                padding: EdgeInsets.all(4), // Padding around the icon
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20, ),)
                  )
                  )
                ],),
              const SizedBox(
                height: 10,
              ),
              
              
                   MyTextfield(
                    labelText:"Username",

                    hintText: "Username",
                    obscureText: false,
                    controller: usernameController,
                                 ),
                 
               
              
              
              const SizedBox(
                height: 10,
              ),
              
              
              MyTextfield(
                labelText:"Email Address",

                hintText: "Email Address",
                obscureText: false,
                controller: emailController,
              ),
              
              
              const SizedBox(
                height: 10,
              ),
              
              
              
             

              
               TextField(
                decoration: InputDecoration(
                    labelText:'Date of birth',
                    filled: true,
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                readOnly: true,
                controller: birthdayController,
                onTap: () => selectDate(context,birthdayController),

              ),
              
              
            
           
             
             
                        ]),
                      ),
            );
          }  
          },
    ));
  }
}