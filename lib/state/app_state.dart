import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // 디자인 설정 값
  Color mainColor = Colors.blueAccent;
  double fontSize = 20;
  String fontFamily = 'Roboto';

  // 좋아요 카운트
  int likeCount = 0;

  // 디자인 변경
  void updateDesign({Color? color, double? size, String? font}) {
    if (color != null) mainColor = color;
    if (size != null) fontSize = size;
    if (font != null) fontFamily = font;
    notifyListeners();
  }

  // 좋아요 기능
  void toggleLike() {
    likeCount++;
    notifyListeners();
  }
}
