import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/utils/logger.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback onSave;
  const EditProfilePage({super.key,required this.onSave});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User? currentUser;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    loadUserData();

   
  
  }

  @override
  void dispose() {
    usernameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      AppLogger.logInfo("Loading user data...");
      final userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.uid)
          .get();

      final userData = userDoc.data();
      if (userData != null) {
        setState(() {
          usernameController.text = userData["username"] ?? "";
          birthdayController.text = userData["birthDate"] ?? "";
          imageUrl = userData["photoURL"] ?? "";
        });
        AppLogger.logInfo("User data loaded successfully.");
      }
    } catch (e, stackTrace) {
      AppLogger.logError("Failed to load user data.", e, stackTrace);
    }
  }

  Future<String?> promptForPassword(BuildContext context) async {
    String? password;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Please enter your password',style: TextStyle(fontSize: 22),),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(hintText: "Password",
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey)),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text('Submit'),
            onPressed: () => Navigator.of(context).pop(password),
          ),
        ],
      ),
    );
  }

  Future<void> reauthenticate(String email, String password) async {
  try {
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
    AppLogger.logInfo("Reauthentication successful.");
  } catch (e, stackTrace) {
    AppLogger.logError("Reauthentication failed.", e, stackTrace);
    throw FirebaseAuthException(
      code: 'reauthentication-failed',
      message: 'Reauthentication failed. Please try again.',
    );
  }
}


  Future<void> saveProfile() async {
  if (usernameController.text.isEmpty || birthdayController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username and birthday cannot be empty!')),
    );
    return;
  }

  try {
    
    AppLogger.logInfo("Attempting to save profile...");

    // Prompt for password and reauthenticate the user
    final password = await promptForPassword(context);
    if (password == null || password.isEmpty) {
      if(context.mounted){ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required to update profile.')),
      );
      return;
      }
    }

    await reauthenticate(currentUser!.email!, password!);

  
   

    if(context.mounted){
    await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).update({
      'username': usernameController.text,
      'birthDate': birthdayController.text,
      'photoURL': imageUrl,
      'updatedAt': DateTime.now(),
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    AppLogger.logInfo("Profile saved successfully.");}
        widget.onSave();

    Navigator.pop(context);
  } catch (e, stackTrace) {
    AppLogger.logError("Failed to save profile.", e, stackTrace);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update profile. Please try again.')),
    );
    Navigator.pop(context);
  }
}


 
  Future<void> editPfp() async {
    try {
      AppLogger.logInfo("Attempting to edit profile picture...");
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (image == null) return;

      final ref = storage.ref().child('${currentUser!.uid}_profile.jpg');
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).update({
        'photoURL': downloadUrl,
        'updatedAt': DateTime.now(),
      });

      setState(() {
        imageUrl = downloadUrl;
      });

     
    } catch (e, stackTrace) {
      AppLogger.logError("Failed to update profile picture.", e, stackTrace);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: saveProfile,
            child: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty ? const Icon(Icons.person, size: 75) : null,
                ),
                IconButton(
                  onPressed: editPfp,
                  icon: const Icon(Icons.edit, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MyTextfield(
              labelText: "Username",
              hintText: "Enter your username",
              obscureText: false,
              controller: usernameController,
            ),
            const SizedBox(height: 20),
           
            TextField(
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                filled: true,
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: birthdayController,
              onTap: () => selectDate(context, birthdayController),
            ),
          ],
        ),
      ),
    );
  }
}
