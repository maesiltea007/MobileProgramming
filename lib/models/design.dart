import 'package:flutter/material.dart';

//유저의 디자인 데이터형식입니다.
class Design {
  final String? id;
  final String text;
  final String fontFamily;
  final Color fontColor;
  final Color backgroundColor;
  final String ownerId;
  final DateTime createdAt;

  const Design({
    this.id,
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.backgroundColor,
    required this.ownerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() =>
      {
        "id": id,
        "text": text,
        "fontFamily": fontFamily,
        "fontColor": fontColor.value,
        "backgroundColor": backgroundColor.value,
        "ownerId": ownerId,
        "createdAt": createdAt.toIso8601String(),
      };

  factory Design.fromMap(Map<String, dynamic> map) {
    return Design(
      id: map["id"],
      text: map["text"],
      fontFamily: map["fontFamily"],
      fontColor: Color(map["fontColor"]),
      backgroundColor: Color(map["backgroundColor"]),
      ownerId: map["ownerId"],
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
}

