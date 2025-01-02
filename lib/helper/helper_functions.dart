import 'package:flutter/material.dart';

void displayMessageToUser(String message, BuildContext context){
  showDialog(context: context, builder: (context)=> AlertDialog(
    title: Center(child:Text(message)),
    
    )
  );
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
Future<void> selectDate(BuildContext context, TextEditingController dateController) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (pickedDate != null) {
    dateController.text = pickedDate.toString().split(" ")[0];
    }
  
}  