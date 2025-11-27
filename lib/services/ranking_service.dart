import 'package:hive_flutter/hive_flutter.dart';

class RankingService {
  static final rankingBox = Hive.box('rankingBox');
  static final likesBox = Hive.box('likesBox');

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

  static List<MapEntry<String, int>> getRanking() {
    final raw = rankingBox.toMap();

    final map = raw.map<String, int>(
          (key, value) => MapEntry(key.toString(), value as int),
    );

    final entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }


  static List<MapEntry<String, int>> getTop10() {
    return getRanking().take(10).toList();
  }

  static bool isLiked(String designId) {
    return likesBox.get(designId, defaultValue: false);
  }
}
