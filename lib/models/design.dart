import 'package:flutter/material.dart';

class Design {
  final String? id;
  final String text;
  final String fontFamily;
  final Color fontColor;
  final Color backgroundColor;
  final String ownerId;
  final DateTime? createdAt; // 🔥 nullable

  const Design({
    this.id,
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.backgroundColor,
    required this.ownerId,
    this.createdAt, // 🔥 nullable
  });

  Map<String, dynamic> toMap() =>
      {
        "id": id,
        "text": text,
        "fontFamily": fontFamily,
        "fontColor": fontColor.value,
        "backgroundColor": backgroundColor.value,
        "ownerId": ownerId,
        // 🔥 createdAt이 있을 때만 map에 저장
        if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
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
      createdAt:
      createdAtStr != null ? DateTime.parse(createdAtStr) : null, // 🔥 null 유지
    );
  }
}


