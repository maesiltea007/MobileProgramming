import 'package:hive_flutter/hive_flutter.dart';
import 'design_repository.dart';

class RankingService {
  static final rankingBox = Hive.box('rankingbox');
  static final likesBox = Hive.box('likesbox');

  static void initializeDesign(String designId) {
    if (!rankingBox.containsKey(designId)) {
      rankingBox.put(designId, 0); // score = 0
    }
    if (!likesBox.containsKey(designId)) {
      likesBox.put(designId, false); // like = false
    }
  }

  static void toggleLike(String designId) {
    bool liked = likesBox.get(designId, defaultValue: false);

    if (liked) {
      likesBox.put(designId, false);
      _changeScore(designId, -1);
    } else {
      likesBox.put(designId, true);
      _changeScore(designId, 1);
    }
  }

  static void _changeScore(String designId, int delta) {
    final current = rankingBox.get(designId, defaultValue: 0);
    rankingBox.put(designId, current + delta);
  }

  static int getScore(String designId) {
    return rankingBox.get(designId, defaultValue: 0) as int;
  }

  static List<MapEntry<String, int>> getRanking() {
    final raw = rankingBox.toMap();

    // 1) Map<String, int> 형태로 강제 변환
    final map = raw.map<String, int>(
          (key, value) => MapEntry(key.toString(), value as int),
    );

    final entries = map.entries.toList();

    // 2) 🔥 삭제된 디자인 자동 정리
    entries.removeWhere((entry) {
      final exists = DesignRepository.get(entry.key);
      if (exists == null) {
        rankingBox.delete(entry.key); // Hive에서도 함께 삭제
        likesBox.delete(entry.key); // 좋아요도 정리 (안하면 쓰레기 데이터 남음)
        return true; // 리스트에서도 제거
      }
      return false;
    });

    // 3) 점수 내림차순 정렬
    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }


  static int getOverallRank(String designId) {
    final rankingList = getRanking(); // score 많은 순으로 정렬된 전체 목록
    for (int i = 0; i < rankingList.length; i++) {
      if (rankingList[i].key == designId) {
        return i + 1; // 등수는 1부터 시작
      }
    }
    return -1; // 없는 경우(정상적 상황에선 거의 없음)
  }

  static List<MapEntry<String, int>> getTop10() {
    return getRanking().take(10).toList();
  }

  static bool isLiked(String designId) {
    return likesBox.get(designId, defaultValue: false);
  }
}
