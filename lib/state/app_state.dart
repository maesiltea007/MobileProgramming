import 'package:flutter/material.dart';


class AppState extends ChangeNotifier {
  Color mainColor = Colors.blueAccent;
  double fontSize = 20;

  final List<bool> playerLiked = List.generate(10, (_) => false);
  final List<int> playerLikes = List.generate(10, (_) => 0);

  // ❤️ 하트 클릭 → 좋아요 토글 (ON/OFF)
  void toggleLike(int index) {
    if (playerLiked[index]) {
      // 좋아요 취소
      playerLiked[index] = false;
      playerLikes[index]--;
    } else {
      // 좋아요 활성화
      playerLiked[index] = true;
      playerLikes[index]++;
    }
    notifyListeners();
  }

  // ❤️‍🔥 더블탭 → 무조건 좋아요 ON
  void likeByDoubleTap(int index) {
    if (!playerLiked[index]) {
      playerLiked[index] = true;
      playerLikes[index]++;
      notifyListeners();
    }
  }

  int get totalLikes =>
      playerLikes.fold(0, (sum, n) => sum + n);
}

