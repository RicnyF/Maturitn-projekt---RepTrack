import 'package:flutter/material.dart';

class MyBoldText extends StatelessWidget {
  final String text;
  const MyBoldText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
  }
}