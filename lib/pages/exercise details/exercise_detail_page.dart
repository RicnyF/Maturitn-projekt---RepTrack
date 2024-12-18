import 'package:flutter/material.dart';
import 'package:rep_track/pages/edit_exercises_page.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_about_page.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_best_page.dart';
import 'package:rep_track/pages/exercise%20details/exercise_detail_history_page.dart';

class ExerciseDetailPage extends StatefulWidget {
 
  final String exerciseId;
  final Map<String, dynamic> exerciseData; 
  const ExerciseDetailPage({super.key,
  required this.exerciseId,
    required this.exerciseData,});
 

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late final List <Widget> _pages;
  @override
  void initState(){
    super.initState();
_pages = <Widget>[
   Tab(child:ExerciseDetailAboutPage(
        exerciseId: widget.exerciseId,
        exerciseData: widget.exerciseData,
      )),
      Tab(child:ExerciseDetailHistoryPage(
        exerciseId: widget.exerciseId,
        exerciseData: widget.exerciseData,
      )),
      Tab(child:ExerciseDetailBestPage(
        exerciseId: widget.exerciseId,
        exerciseData: widget.exerciseData,
      )),
      
];
  }
  final _tabTitles = ["About", "History", "Records"];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length :_pages.length,
      child:Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        actions: [IconButton(onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditExercisesPage(
                    exerciseId: widget.exerciseId,
                    exerciseData: widget.exerciseData,
                  ),
                ),
              ), icon: Icon(Icons.edit))],
        title: Text(widget.exerciseData["name"], style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
        centerTitle: true,
        bottom: TabBar( tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        dividerColor: Theme.of(context).colorScheme.primary,
        
        labelColor: Theme.of(context).colorScheme.inverseSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.inversePrimary,),
          
      ),
       body:TabBarView(children: _pages)
          
    ));
  }
}