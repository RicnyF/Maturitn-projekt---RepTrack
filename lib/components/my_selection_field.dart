import 'package:flutter/material.dart';
import 'package:rep_track/components/my_boldtext.dart';

class SelectionField extends StatefulWidget {
  final String label;
  final List<String> items;
  final TextEditingController controller;
  final List<String>? explanations;
  const SelectionField({
    super.key,
    required this.label,
    required this.items,
    required this.controller,
    this.explanations
  });

  @override
  State<SelectionField> createState() => _SelectionFieldState();
}

class _SelectionFieldState extends State<SelectionField> {
  // Open the bottom sheet for selection
  void _openSelectionDialog() async {
    String? selectedValue = await showModalBottomSheet<String>(
      context: context,
      
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(padding:EdgeInsets.fromLTRB(16,58,16,16),child:ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: MyBoldText(text:widget.items[index]),
              subtitle: widget.explanations != null && widget.explanations!.isNotEmpty
                    ? Text("Example: ${widget.explanations![index]}")
                    : null,
              onTap: () {
                Navigator.pop(context, widget.items[index]); // Return the selected value
              },
            );
          },
        ));
      },
    );

    if (selectedValue != null) {
      setState(() {
        widget.controller.text = selectedValue; // Update the controller
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openSelectionDialog,
      child: AbsorbPointer(
        child: TextField(
          
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
          controller: widget.controller,
          decoration: InputDecoration(
            
            
          
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
        ),
 focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 3.0, // Slightly thicker border when focused
              ),
            ),
            hintText: widget.label,
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.secondary
            ),

          ),
        ),
      ),
    );
  }
}
