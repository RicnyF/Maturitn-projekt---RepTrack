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
    AppLogger.logInfo("Attempting to reset a password...");
    if(emailController.text.isEmpty){
      displayMessageToUser("Email can´t be empty!", context);
      AppLogger.logError("Failed to reset password. Email is empty.");
      return;
    }
    try{await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
    
    if(mounted)displayMessageToUser('If the email is registered, a reset link has been sent.', context);}
    on FirebaseAuthException catch (e, stackTrace){
      if(mounted)displayMessageToUser(e.message.toString(), context);
      AppLogger.logError("Failed to reset password.", e, stackTrace);

    }
  }
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      ),);
    }
}