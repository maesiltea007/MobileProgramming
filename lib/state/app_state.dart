import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/ranking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppState extends ChangeNotifier {
  // 로그인 변수
  bool isLoggedIn = false;
  String? currentUserId;
  String? currentNickname;


  Color mainColor = Colors.blueAccent;
  double fontSize = 20;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // 로그인 실행
  void login(String userId, String nickname) {
    currentUserId = userId;
    currentNickname = nickname;
    isLoggedIn = true;
    notifyListeners();
  }

  // 로그아웃 실행
  void logout() async {
    // Firebase 로그아웃 호출
    await FirebaseAuth.instance.signOut();

    currentUserId = null;
    currentNickname = null;
    isLoggedIn = false;
    notifyListeners();

    final likesBox = Hive.box('likesbox');
    for (var key in likesBox.keys) {
      likesBox.put(key, false);
    }
  }

  // Firebase 인증 상태를 수신하여 AppState를 초기화하는 함수
  void initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        currentUserId = null;
        currentNickname = null;
        isLoggedIn = false;
      } else {
        currentUserId = user.uid;
        isLoggedIn = true;

        await _fetchUserProfile(user.uid);

        notifyListeners();
      }
    });
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

  // nickname 변경 함수
  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('nickname')) {
          currentNickname = data['nickname'];
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<bool> updateNickname(String newNickname) async {
    if (currentUserId == null) {
      return false;
    }

    if (newNickname == currentNickname) {
      return true;
    }

    final usersCollection = FirebaseFirestore.instance.collection('users');

    try {
      final querySnapshot = await usersCollection
          .where('nickname', isEqualTo: newNickname)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingDoc = querySnapshot.docs.first;

        if (existingDoc.id != currentUserId) {
          print("Nickname '$newNickname' is already taken by another user.");
          return false;
        }
      }

      await usersCollection.doc(currentUserId).set(
        {'nickname': newNickname},
        SetOptions(merge: true),
      );

      currentNickname = newNickname;
      notifyListeners();

      return true;

    } catch (e) {
      print("Failed to check or save nickname to Firestore: $e");
      return false;
    }
  }

  // 비밀번호 변경 함수
  Future<void> changePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw e;
        } else {
          print("Password change failed: ${e.message}");
          throw Exception(e.message);
        }
      }
    }
  }

  // 회원 탈퇴 함수
  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        await user.delete();

        currentUserId = null;
        currentNickname = null;
        isLoggedIn = false;
        notifyListeners();

      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw e;
        } else {
          print("Account deletion failed: ${e.message}");
          throw Exception(e.message);
        }
      } catch (e) {
        print("Error deleting account: $e");
        throw Exception("Failed to delete account");
      }
    }
  }
}
