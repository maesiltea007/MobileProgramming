import 'package:flutter/material.dart';

//유저의 디자인 데이터형식입니다.
class Design {
  final String text;
  final String fontFamily;
  final Color fontColor;
  final Color backgroundColor;
  final String ownerId;

  const Design({
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.backgroundColor,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() =>
      {
        "text": text,
        "fontFamily": fontFamily,
        "fontColor": fontColor.value,
        "backgroundColor": backgroundColor.value,
        "ownerId": ownerId,
      };

  factory Design.fromMap(Map<String, dynamic> map) {
    return Design(
      text: map["text"],
      fontFamily: map["fontFamily"],
      fontColor: Color(map["fontColor"]),
      backgroundColor: Color(map["backgroundColor"]),
      ownerId: map["ownerId"],
    );
  }
}

