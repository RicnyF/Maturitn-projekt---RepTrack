import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/utils/logger.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
 final emailController = TextEditingController();
  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }
  Future passwordReset()async{
    //Píše mi do loggeru
    AppLogger.logInfo("Attempting to reset a password...");
    //kontrola jestli neni kontroler prázdný
    if(emailController.text.isEmpty){
      //napíše uživateli chybu a do loggeru
      displayMessageToUser("Email can´t be empty!", context);
      AppLogger.logError("Failed to reset password. Email is empty.");
      return;
    }
    //pokusi se poslat email s restartovaním hesla
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
    //napise uživateli hlášku
    if(mounted)displayMessageToUser('If the email is registered, a reset link has been sent.', context);}
    //kontrola chyb
    on FirebaseAuthException catch (e, stackTrace){
      //vypíše uživateli a mi do loggeru chyby
      if(mounted)displayMessageToUser(e.message.toString(), context);
      AppLogger.logError("Failed to reset password.", e, stackTrace);
    }
  }
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Reset"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('images/RepTrack.png',scale: 2,),
                
                
                
                const SizedBox(
                  height: 50,
                ),
                
              Text(
              "Enter your Email and we will send you a password reset link",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),),
                          SizedBox(height: 10,),
        
              MyTextfield(hintText: "Email", obscureText: false, controller: emailController),
              SizedBox(height: 10,),
           MaterialButton(onPressed: passwordReset,
          
        color: Theme.of(context).colorScheme.primary, child: Text("Reset Password"),)
            ],
          ),
        ),
      ),);
    }
}