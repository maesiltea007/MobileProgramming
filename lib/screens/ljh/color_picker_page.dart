import 'package:flutter/material.dart';

class ColorPickerPage extends StatelessWidget {
  const ColorPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎨 Color Picker')),
      body: const Center(
        child: Text(
          '색상 선택 페이지',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
