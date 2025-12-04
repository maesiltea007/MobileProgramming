import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

void insertDummyData() {
  final designs = Hive.box('designsbox');
  final ranking = Hive.box('rankingbox');
  final likes = Hive.box('likesbox');

  // 이미 있으면 생성 X
  if (designs.isNotEmpty) {
    print("⚠️ Dummy data already exists. Skipped.");
    return;
  }

  print("🔥 Inserting dummy data...");

  final now = DateTime.now();

  // DESIGN 1
  designs.put("d1", {
    "text": "Hello World",
    "fontFamily": "Roboto",
    "fontColor": Colors.black.value,
    "backgroundColor": Colors.white.value,
    "ownerId": "user_dev_01",
    "createdAt": now.subtract(const Duration(minutes: 3)).toIso8601String(),
  });

  // DESIGN 2
  designs.put("d2", {
    "text": "Epic Design",
    "fontFamily": "GmarketSans",
    "fontColor": Colors.white.value,
    "backgroundColor": Colors.blue.value,
    "ownerId": "user_dev_02",
    "createdAt": now.subtract(const Duration(minutes: 2)).toIso8601String(),
  });

  // DESIGN 3
  designs.put("d3", {
    "text": "Color Font App",
    "fontFamily": "NanumSquare",
    "fontColor": Colors.black87.value,
    "backgroundColor": Colors.yellow.value,
    "ownerId": "user_dev_01",
    "createdAt": now.subtract(const Duration(minutes: 1)).toIso8601String(),
  });

  //현재 로그인한 계정 디자인들
  designs.put("d4", {
    "id": "d4",
    "text": "Color Font App",
    "fontFamily": "NanumSquare",
    "fontColor": Colors.black87.value,
    "backgroundColor": Colors.yellow.value,
    "ownerId": "user_dev_01",
    "createdAt": now.subtract(const Duration(minutes: 1)).toIso8601String(),
  });
  designs.put("d5", {
    "id": "d5",
    "text": "Color Font App",
    "fontFamily": "NanumSquare",
    "fontColor": Colors.white.value,
    "backgroundColor": Colors.blue.value,
    "ownerId": "user_dev_01",
    "createdAt": now.subtract(const Duration(minutes: 1)).toIso8601String(),
  });

  // RANKING
  ranking.put("d1", 12);
  ranking.put("d2", 7);
  ranking.put("d3", 4);

  // LIKES
  likes.put("d1", false);
  likes.put("d2", false);
  likes.put("d3", false);

  print("✅ Dummy data inserted successfully!");
}
