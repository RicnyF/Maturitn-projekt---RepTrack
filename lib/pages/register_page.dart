import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/my_button.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
   final void Function()? onTap;
  
  RegisterPage({super.key,
  required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPwController = TextEditingController();

  //register method
  void register() async{
    // show loading circle
    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    // check if fields are blank
    if(usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty ||confirmPwController.text.isEmpty ){
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("All fields must be filled", context);}
    }
    else{
    //passwords match
    if(passwordController.text != confirmPwController.text){
      Navigator.pop(context);
      displayMessageToUser("Passwords don´t match !", context);
    }
    else{
    try{
      UserCredential? userCredential=
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
         password: passwordController.text);
      
      createUserDocument(userCredential);

    } on FirebaseAuthException catch (e){
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser(e.code, context);}
    }
    if(mounted){
      Navigator.pop(context);
      }
    }
    }
    
  }

  // Create user document
  Future<void> createUserDocument(UserCredential? userCredential) async{
    if (userCredential != null && userCredential.user !=null){
      await FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
            child: SingleChildScrollView(
              child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              
              Icon(
                Icons.person,
                size: 80, 
                color: Theme.of(context).colorScheme.inversePrimary),
              
              const SizedBox(
                height: 25,
              ),
              
              const Text(
                "R E P T R A C K",
                style: TextStyle(fontSize: 20),
              ),
              
              const SizedBox(
                height: 50,
              ),
              
               MyTextfield(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
              ),
              
              
              const SizedBox(
                height: 10,
              ),
              
              
              MyTextfield(
                hintText: "Email Address",
                obscureText: false,
                controller: emailController,
              ),
              
              
              const SizedBox(
                height: 10,
              ),
              
              
              MyTextfield(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),
               const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              
              
              MyTextfield(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmPwController,
              ),
               const SizedBox(
                height: 10,
              ),
              
              
                         
              MyButton(
                text:"Register",
                onTap: register,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,)
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text("Login Here",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,)
                    ),
                  ),
                ],
              ),
                        ]),
                      ),
            )));
  }
}
