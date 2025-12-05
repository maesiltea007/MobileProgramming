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
    final createdAtStr = map["createdAt"] as String?;

    return Design(
      id: map["id"] as String?,
      text: (map["text"] as String?) ?? '',
      fontFamily: (map["fontFamily"] as String?) ?? 'Arial',
      fontColor: Color((map["fontColor"] as int?) ?? Colors.black.value),
      backgroundColor:
      Color((map["backgroundColor"] as int?) ?? Colors.white.value),
      ownerId: (map["ownerId"] as String?) ?? '',
      createdAt: createdAtStr != null
          ? DateTime.parse(createdAtStr)
          : DateTime.now(), // createdAt 없으면 현재 시간으로
    );
  }

}

