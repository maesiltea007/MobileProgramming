import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.camera_alt),
        label: const Text('📷 카메라 찍기'),
        onPressed: () {
          Navigator.pushNamed(context, '/colorpicker');
        },
      ),
    );
  }
}
