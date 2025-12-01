import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

class AppState extends ChangeNotifier {
  // 로그인 변수
  bool isLoggedIn = false;
  String? currentUserId;

  Color mainColor = Colors.blueAccent;
  double fontSize = 20;

  // 🔥 테스트용 임시 로그인 (Firebase Auth 붙어도 영향 없음)
  void devLogin() {
    isLoggedIn = true;
    currentUserId = "dev-test-user"; // Firebase의 uid 역활
    notifyListeners();
  }

  // 로그인 실행
  void login(String userId) {
    currentUserId = userId;
    isLoggedIn = true;
    notifyListeners();
  }

  // 로그아웃 실행
  void logout() {
    currentUserId = null;
    isLoggedIn = false;
    notifyListeners();
  }

  // ❤️ 디자인 좋아요 토글
  void toggleLike(String designId) {
    RankingService.toggleLike(designId);
    notifyListeners();
  }

  // ❤️‍🔥 더블탭 → 무조건 좋아요 ON
  void likeByDoubleTap(String designId) {
    final liked = RankingService.isLiked(designId);
    if (!liked) {
      RankingService.toggleLike(designId);
      notifyListeners();
    }
  }

  // 좋아요 여부 가져오기
  bool isLiked(String designId) {
    return RankingService.isLiked(designId);
  }

  // 점수 가져오기
  int getScore(String designId) {
    return RankingService.getScore(designId);
  }
}
