import 'package:flutter/material.dart';

//유저의 디자인 데이터형식입니다.
class Design {
  final String text;
  final String fontFamily;
  final Color fontColor;
  final Color backgroundColor;

  const Design({
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'fontFamily': fontFamily,
      'fontColor': fontColor.value,
      'backgroundColor': backgroundColor.value,
    };
  }

  static Design fromMap(Map<String, dynamic> map) {
    return Design(
      text: map['text'],
      fontFamily: map['fontFamily'],
      fontColor: Color(map['fontColor']),
      backgroundColor: Color(map['backgroundColor']),
    );
  }
}
