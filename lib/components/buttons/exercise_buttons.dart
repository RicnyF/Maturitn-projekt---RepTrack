import 'package:flutter/material.dart';

class MyExerciseButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const MyExerciseButton({super.key,
  required this.text,
  required this.onTap,
  required this.icon});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: onTap,
    child:Container(
                  
                  padding: EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      width:2
                    ),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(text, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                      
                      Icon(icon, size: 50,)
                      ])),
        );
  }
}