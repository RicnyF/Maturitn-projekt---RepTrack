import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/my_boldtext.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? pickedImage;
  bool isLoading = false; 
  final storageRef = FirebaseStorage.instance;
  // current logged in user
  final User ? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String,dynamic>>> getUserDetails() async{
    return await FirebaseFirestore.instance.collection("Users").doc(currentUser!.email).get();
  }

  Future<void> editProfile(String username)async{
    
   final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageRef = storageRef.ref().child('$username.jpg');
    try{
    final imageBytes= await image.readAsBytes();
    TaskSnapshot uploadTask =await imageRef.putData(imageBytes);
    
    }
    
    catch(e){
      print("Error uploading immage: $e");
    }
    await getImageUrl();
    setState(() {
      
        isLoading= true;
    });
  }

  void logout (BuildContext context){
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  late String imageUrl;
  
 
  @override
  void initState(){
    super.initState();
    imageUrl='';
    getImageUrl();
  }

  Future<void> getImageUrl()async{
    final userDoc = await getUserDetails();
     Map<String, dynamic>? userData = userDoc.data();
     final username= userData!['username'];    
      if (userData.isNotEmpty) {
      try {
        final ref = storageRef.ref().child('$username.jpg');
        final url = await ref.getDownloadURL();
        setState((){
          imageUrl = url;
           // Update loading state// Update loading state
        });
      } catch (e) {
        print("Could not fetch image URL: $e");
      }
     
  }
  }
  
  @override Widget  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: null,
        actions: [
          IconButton(onPressed: ()=>logout(context), icon: Icon(Icons.logout))
        ],
        backgroundColor: null,
          ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(
          future: getUserDetails(), 
        builder: (context,snapshot){
          
          //loading
          if(snapshot.connectionState== ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);

          }
          //error
          else if(snapshot.hasError){
            return Text("Error: ${snapshot.error}");
          }
          //data received
          else if (snapshot.hasData){
           
            Map<String, dynamic>? user = snapshot.data!.data();
            
            return Center(
              child: Column(children: [
                
                Stack(alignment: Alignment.topRight,
                children: 
                [
                  
                Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 150,
                width: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  
                  if (loadingProgress == null){
                   isLoading=false;
                    return child;
                  }
                  else{ 
                   
                    
                  return Center(child: CircularProgressIndicator());}
                },
                errorBuilder: (context, error, stackTrace) {
                  
                  return Text('Could not load image');})
                ,
                if(!isLoading)
                Positioned (

                    right: 5,
                    top: 5,
                    child: GestureDetector(
                    onTap: ()=>editProfile(user!["username"]),
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

                
                const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "User Email: "),
                    Text(user!['email']),
                  ],
                  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Username:  "),
                    Text(user['username']),
                  ],
                )
              ],
              ),
            );
            }else {
              return Text("No data");
            }

        }
        )
        );
      
  }
}