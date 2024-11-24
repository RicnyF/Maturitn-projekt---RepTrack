import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/components/buttons/login_buttons.dart';
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
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPwController = TextEditingController();

  TextEditingController birthdayController = TextEditingController();

  //register method
  void register() async{
    // show loading circle
    
    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    // check if fields are blank
    if(usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty ||confirmPwController.text.isEmpty || birthdayController.text.isEmpty ){
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("All fields must be filled", context);}
      return;
    }
    
    //passwords match
    if(passwordController.text != confirmPwController.text){
      Navigator.pop(context);
      displayMessageToUser("Passwords don´t match !", context);
      return;
    }
    if(birthdayController.text.isNotEmpty){
      
      DateTime birthday = DateTime.parse(birthdayController.text.substring(0, 10)); // yyyy-mm-dd format
        DateTime today = DateTime.now();

        int age = today.year - birthday.year;
        if (today.month < birthday.month || (today.month == birthday.month && today.day < birthday.day)) {
          age--;
        }

        if (age < 13) {
          Navigator.pop(context);
          displayMessageToUser("User has to be at least 13 years old", context);
          return;
        }
        }
    try{
      UserCredential? userCredential=
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
         password: passwordController.text);
      
      await createUserDocument(userCredential);
      if(mounted)Navigator.pop(context);

    } on FirebaseAuthException catch (e){
      if(mounted){
      Navigator.pop(context);
      // Display specific error messages
      
    if (e.code == 'email-already-in-use') {
      displayMessageToUser("This email is already in use. Try logging in.", context);
    } else if (e.code == 'invalid-email') {
      displayMessageToUser("The email format is invalid.", context);
    } else if (e.code == 'weak-password') {
      displayMessageToUser("The password is too weak. Use at least 6 characters, .", context);
    } else {
      displayMessageToUser("Registration error: ${e.message}", context);
    }
  }
      
      
    }
    
    
    
    
  }


  
  
  // Create user document
  Future<void> createUserDocument(UserCredential? userCredential) async{
    
    if (userCredential != null && userCredential.user !=null){
      final userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection("Users").doc(userId).set({
        'userId': userId,
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'photoURL': "",
        'birthDate': birthdayController.text,
        'createdAt': dateFormat.format(DateTime.now()),
        "updatedAt": dateFormat.format(DateTime.now()),
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

            
               const SizedBox(
                height: 10,
              ),
                         
              MyLoginButton(
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
