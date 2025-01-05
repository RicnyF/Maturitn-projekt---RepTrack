
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rep_track/auth/auth.dart';
import 'package:rep_track/firebase_options.dart';
import 'package:rep_track/pages/add_exercises_page.dart';
import 'package:rep_track/pages/routines/add_routines_page.dart';
import 'package:rep_track/pages/exercises_page.dart';
import 'package:rep_track/pages/home_page.dart';
import 'package:rep_track/pages/profile_page.dart';
import 'package:rep_track/pages/routines/routines_page.dart';
import 'package:rep_track/pages/routines/select_exercise_page.dart';
import 'package:rep_track/pages/start_new_workout_page.dart';
import 'package:rep_track/theme/dark_mode.dart';
import 'package:rep_track/theme/light_mode.dart';
import 'package:rep_track/theme/theme_provider.dart';
import 'package:rep_track/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.logInfo("Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  AppLogger.logInfo("Firebase initialized successfully.");
  runApp( ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),);
 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return  MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      themeMode: themeProvider.themeMode,

      theme: lightMode,
      darkTheme: darkMode,
      routes:{
        '/new_workout_page':(context)=> StartNewWorkoutPage(),
        '/profile_page':(context)=> ProfilePage(),
        '/exercises_page':(context)=> ExercisesPage(),
        '/routines_page':(context)=> RoutinesPage(),
        '/add_exercises_page':(context)=> AddExercisesPage(),
        '/home_page':(context)=>HomePage(),
        '/add_routine_page':(context)=>AddRoutinesPage(),
        '/select_exercises_page':(context)=>SelectExercisesPage(),
        '/start_new_workout_page':(context)=> StartNewWorkoutPage()
        
      }
    );
  }
}