import 'package:flutter/material.dart';

class DesignPreview extends StatelessWidget {
  final Color backgroundColor;
  final Color fontColor;
  final String fontFamily;
  final String text;

  const DesignPreview({
    super.key,
    required this.backgroundColor,
    required this.fontColor,
    required this.fontFamily,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              color: fontColor,
              fontSize: 48,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}