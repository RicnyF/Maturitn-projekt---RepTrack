
import 'package:flutter/material.dart';


class MyTextfield2 extends StatefulWidget {
  final String label;
 
  final TextEditingController controller;
  const MyTextfield2({
    super.key,
    required this.label,
    
    required this.controller,
    });

  @override
  State<MyTextfield2> createState() => _MyTextfield2State();
}

class _MyTextfield2State extends State<MyTextfield2> {
  late FocusNode _focusNode;
  bool isLabelVisible = true;
   @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Listen for focus changes
    _focusNode.addListener(() {
      setState(() {
        isLabelVisible = !_focusNode.hasFocus; // Hide label when focused
      });
    });
  }
   @override
  void dispose() {
    _focusNode.dispose(); // Clean up the focus node
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          focusNode: _focusNode, 

          textAlign: TextAlign.center,
          controller: widget.controller,
          decoration: InputDecoration(
            
            
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.secondary
            ),
             focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary, // Color when focused
            width: 2.0,
          ),
        ),
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.inversePrimary
            )
        ),
            hintText: widget.label,
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.secondary
            ),


    ));
  }
}