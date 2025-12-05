import 'package:flutter/material.dart';

class SaveOptionsPopup extends StatelessWidget {
  final VoidCallback onSaveAsNew;
  final VoidCallback onOverwrite;

  const SaveOptionsPopup({
    super.key,
    required this.onSaveAsNew,
    required this.onOverwrite,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save Options"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSaveAsNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save as New",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOverwrite,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF424242), // Colors.grey[800]
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Overwrite",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}