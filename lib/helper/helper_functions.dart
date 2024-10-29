import 'package:flutter/material.dart';

void displayMessageToUser(String message, BuildContext context){
  showDialog(context: context, builder: (context)=> AlertDialog(
    title: Text(message),
    )
  );
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}