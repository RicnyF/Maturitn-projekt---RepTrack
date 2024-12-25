import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rep_track/auth/auth.dart';
import 'package:rep_track/components/my_boldtext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:logger/logger.dart';
import 'package:rep_track/pages/workout_details_page.dart';
import 'package:rep_track/utils/logger.dart';
import 'package:table_calendar/table_calendar.dart';
class ProfilePage extends StatefulWidget {
  
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}




class _ProfilePageState extends State<ProfilePage> {
  final logger = Logger();
  bool isLoading = false;
  ValueNotifier<DateTime> _selectedDayNotifier = ValueNotifier(DateTime.now());
 
  var _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();
  final DateFormat _calendarFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final storageRef = FirebaseStorage.instance;
  Map<DateTime, List<Map<String, dynamic>>> events = {};
  // current logged in user
  final User ? currentUser = FirebaseAuth.instance.currentUser;
 void _showWorkoutChoiceDialog(BuildContext context, List<Map<String, dynamic>> workouts) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      print(workouts.length);
      return AlertDialog(
        title: Text("Select a Workout"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: (17+47.0*workouts.length), // Adjust height as needed
          child: ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text("${workout["workoutName"]} - ${workout["createdAt"]}"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailsPage(
                        workoutId: workout["workoutId"],
                        workoutData: workout,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}

  Future<DocumentSnapshot<Map<String,dynamic>>> getUserDetails() async{
    return await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).get();
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
Future<void> getUserWorkouts() async {
  final workoutsSnapshot = await FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.uid)
      .collection("Workouts")
      .orderBy("createdAt", descending: true)
      .get();

  Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

  for (var doc in workoutsSnapshot.docs) {
    final data = doc.data();
    DateTime date = DateTime.parse(data["createdAt"]);
    DateTime onlyDate = DateTime(date.year, date.month, date.day);

    if (!tempEvents.containsKey(onlyDate)) {
      tempEvents[onlyDate] = [];
    }
    print(data["workoutDuration"]);
    tempEvents[onlyDate]?.add({
      "workoutId": data["workoutId"],
      "workoutName": data["workoutName"],
      "createdAt": data["createdAt"],
      "workoutDuration": data["workoutDuration"],
      "exercises": data["exercises"],
    });
  }

  setState(() {
    events = tempEvents;
  });
}


  
  late String imageUrl;
  
 
  @override
  void initState(){
    super.initState();
    imageUrl='';
    getImageUrl();
    getUserWorkouts();
  }

 Future<void> getImageUrl()async{
    AppLogger.logInfo("Attempting to get image url...");

    final userDoc = await getUserDetails();
     Map<String, dynamic>? userData = userDoc.data();
     final url= userData!['photoURL'];    
     
      if (url!="") {
      try {
        
        setState((){
          imageUrl = url;
         isLoading = false;
        });
        AppLogger.logInfo("Image url taken successfully.");

      } catch (e,stackTrace) {
       AppLogger.logError("Failed to get image url.", e, stackTrace);

      }
     
  }
  }
  @override Widget  build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      
      appBar: AppBar( 
        automaticallyImplyLeading: false,

        centerTitle: true,
        title: Text("My Profile"),
  
        actions: [Builder(builder: (context){
          return IconButton(
 onPressed: () { Scaffold.of(context).openEndDrawer();},           
 icon: Icon(Icons.settings));
  })],
          
       
        
        backgroundColor: null,
          ),
        endDrawer: Drawer(
          key:scaffoldKey,
          child: ListView(
            children: [
              ListTile(
                title: const Text("Settings"),
                onTap: (){},
              ),
              ListTile(
                title: const Text("Log out",style: TextStyle(color:Colors.red)),
                onTap: () =>logout(context),
              )
            ],
          ),
          
        ),  
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: 
      FutureBuilder(
          future: Future.wait([
          getUserDetails(),
        ]),
 
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
           
            final user = snapshot.data![0] as DocumentSnapshot<Map<String, dynamic>>;

            
            return Center(
              child: Column(children: [
                
                Stack(alignment: Alignment.topRight,
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

                
                Text(capitalizeFirstLetter(user!['username']),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "User Email: "),
                    Text(user['email']),
                  ],
                  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Username:  "),
                    Text(user['username']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Date of birth:  "),
                    Text(user['birthDate']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Account created:  "),
                    Text(user['createdAt']),

                  ],
                ),
                SizedBox(
                  width: 350,
                  height: 400,
                  child: /*TableCalendar(
                    focusedDay: _selectedDay,
                     firstDay: DateTime.utc(2010, 10, 16),
                     lastDay: DateTime.now(),
                     selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader:(day){
                    return events[DateTime(day.year,day.month,day.day)]?? [];
                  },
                  calendarStyle: CalendarStyle(weekendTextStyle: TextStyle(color: Colors.white),disabledTextStyle: TextStyle(color: Colors.grey)),
                 onDaySelected: (selectedDay, focusedDay) {

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    /*final onlyDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    if (events.containsKey(onlyDate) && events[onlyDate]!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutDetailsPage(
            workoutId: events[onlyDate]![0]["workoutId"],
            workoutData: events[onlyDate]![0],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No workouts found for the selected day.")),
      );
    }
  */
},


                  headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) {
            
            return DateFormat('yyyy MMMM').format(date);
          },
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        calendarFormat: CalendarFormat.month,
                 
                  ),*/
                   ValueListenableBuilder<DateTime>(
    valueListenable: _selectedDayNotifier,
    builder: (context, selectedDay, child) {
      return TableCalendar(
  focusedDay: selectedDay,
  firstDay: DateTime(2000, 0, 0),
  lastDay: DateTime.now(),
  

  selectedDayPredicate: (day) => isSameDay(day, selectedDay),
  eventLoader:(day){
                    return events[DateTime(day.year,day.month,day.day)]?? [];
                  },
 onDaySelected: (selectedDay, focusedDay) {
             
                _selectedDayNotifier.value = selectedDay;
              

              final onlyDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              final workouts = events[onlyDate] ?? [];

             
              if (workouts.length == 1 ) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailsPage(
                      workoutId: workouts[0]["workoutId"],
                      workoutData: workouts[0],
                    ),
                  ),
                );
              } else if(workouts.isNotEmpty){
                _showWorkoutChoiceDialog(context, workouts);
              }
              _selectedDayNotifier.value = DateTime.now();
            },
  calendarStyle: CalendarStyle(
    
    markerDecoration: BoxDecoration(color: Color.fromARGB(255, 141, 141, 141), shape: BoxShape.circle),weekendTextStyle: TextStyle(color: Colors.white),disabledTextStyle: TextStyle(color: Colors.grey)),
  headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          
          titleTextFormatter: (date, locale) {
            
            return DateFormat('yyyy MMMM').format(date);
          },
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
)

;
             })   ),
                /*ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index].data();
                      return ListTile(
                        title: Text(workout["workoutName"] ?? "Unnamed Workout"),
                        subtitle: Text("Date: ${workout['createdAt'] ?? "Unknown"}"),
                        onTap: () {
                          // Navigate to workout details if needed
                        },
                      );
          })*/],
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

class Photos extends StatelessWidget {
  const Photos({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
  });
  final double height;
  final double width;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return imageUrl!=""? ClipOval(
                   
    child:Image.network(
    imageUrl,
    fit: BoxFit.cover,
    height: height,
    width: width,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null){
        return child;
      }
      else{ 
      return SizedBox(height: height,width: width,
        child:Center(child: CircularProgressIndicator()));}
    },
    errorBuilder: (context, error, stackTrace) {
      
        return Container( 
                height: height,
                width: width, 
                
                  
                  decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
                child: Icon(Icons.account_box,size: height, color: Theme.of(context).colorScheme.inversePrimary), 
    
              );
        }
        )
      ):Container( 
                height: height,
                width: width, 
                
                  
                  decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
                child: Icon(Icons.account_box,size: height, color: Theme.of(context).colorScheme.inversePrimary), 
    
              );
      
  }
}