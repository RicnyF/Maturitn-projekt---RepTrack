import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/components/buttons/login_buttons.dart';
import 'package:rep_track/components/my_textfield.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:rep_track/pages/forgot_password_page.dart';
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
    /*logger*/
    AppLogger.logInfo("Attempting to login...");
    /*Načítací kolečko*/ 
    showDialog(context: context, builder: (context)=> const Center(
      child: CircularProgressIndicator(),
    )
    );
    // kontrola jestli jsou kontrolery prazdny
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      if(mounted){
      //konec načítání
      Navigator.pop(context);
      //napíše chybu uživateli
      displayMessageToUser("All fields must be filled", context);}
    }
    else{
    //zkusi se prihlasit
    try {
     // pokus o prihlaseni s emailem a heslem
     await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, 
     password: passwordController.text);
    // konec nacitani
      if (mounted) Navigator.pop(context);
      // oznameni loggerem do konzole
      AppLogger.logInfo("Logged in successfully.");

  }
  // reseni chyb
  on FirebaseAuthException catch (e, stackTrace){
    if (mounted) {
    //vypise danou chybu uzivateli a do loggeru
    displayMessageToUser(e.message.toString(), context);
        AppLogger.logError("Failed to login.", e, stackTrace);

    }
    } 
  }
  }
  @override
    void dispose() {
  

  emailController.dispose();

passwordController.dispose();

    super.dispose();
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
              
              Image.asset('images/RepTrack.png',scale: 2,),
              
              
              
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
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ForgotPasswordPage();
                      }));
                    },
                    child: Text("Forgot Password?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,)
                    ),
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
                      ),
            )));
  }
}
