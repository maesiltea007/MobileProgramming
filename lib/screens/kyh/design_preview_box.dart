import 'package:flutter/material.dart';
import '../../models/design.dart';

class DesignPreviewBox extends StatelessWidget {
  final Design design;

  const DesignPreviewBox({super.key, required this.design});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: design.backgroundColor, // 배경색 반영
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          design.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontFamily: design.fontFamily, // 폰트 반영
            color: design.fontColor, // 텍스트 색 반영
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
