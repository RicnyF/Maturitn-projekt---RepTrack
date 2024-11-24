import 'package:flutter/material.dart';
import 'package:rep_track/components/my_boldtext.dart';

class MultipleSelectionField extends StatefulWidget {
  final String label;
  final List<String> items;
  final TextEditingController controller;
  final List<String>? explanations;

  const MultipleSelectionField({
    super.key,
    required this.label,
    required this.items,
    required this.controller,
    this.explanations,
  });

  @override
  State<MultipleSelectionField> createState() => _MultipleSelectionFieldState();
}

class _MultipleSelectionFieldState extends State<MultipleSelectionField> {
  final Set<String> _selectedItems = {}; // Tracks selected items

  // Open the bottom sheet for selection
  void _openSelectionDialog() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder( // Add StatefulBuilder to manage state inside modal
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 58, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modal title
                  Text(
                    "Select Options",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          title: MyBoldText(text: item),
                          subtitle: widget.explanations != null &&
                                  widget.explanations!.isNotEmpty
                              ? Text("Example: ${widget.explanations![index]}")
                              : null,
                          trailing: Checkbox(
                            value: _selectedItems.contains(item),
                            onChanged: (isSelected) {
                              setModalState(() {
                                if (isSelected == true) {
                                  _selectedItems.add(item);
                                } else {
                                  _selectedItems.remove(item);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            // Toggle selection on tap
                            setModalState(() {
                              if (_selectedItems.contains(item)) {
                                _selectedItems.remove(item);
                              } else {
                                _selectedItems.add(item);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  // Done button
                  ElevatedButton(
                    onPressed: () {
                      // Update the controller with the selected items
                      widget.controller.text = _selectedItems.join(", ");
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Done"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // After the modal is closed, update the field to show the selected items
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openSelectionDialog,
      child: AbsorbPointer(
        child: TextField(
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          textAlign: TextAlign.center,
          controller: widget.controller,
          decoration: InputDecoration(
            
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
