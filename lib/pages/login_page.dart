import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/buttons/login_buttons.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/utils/logger.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  
  const LoginPage({super.key,
  required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// text controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  //login method
  void login() async{
    // loading circle
    AppLogger.logInfo("Attempting to login...");

    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    // check if fields are blank
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      if(mounted){
      Navigator.pop(context);
      displayMessageToUser("All fields must be filled", context);}
    }
    else{
    //try sign in
    try {
     await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, 
     password: passwordController.text);
    // pop loading circle
      if (mounted) Navigator.pop(context);
      AppLogger.logInfo("Logged in successfully.");

  }
  on FirebaseAuthException catch (e, stackTrace){
    if (mounted) {
    
    displayMessageToUser(e.code, context);
        AppLogger.logError("Failed to login.", e, stackTrace);

    }
    } 
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Forgot Password?",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,)
                ),
              ],
            ),
             const SizedBox(
              height: 25,
            ),
            
            MyLoginButton(
              text:"Login",
              onTap: login,),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don´t have an account? ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,)
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text("Register Here",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,)
                  ),
                ),
              ],
            ),
          ]),
        )));
  }
}
