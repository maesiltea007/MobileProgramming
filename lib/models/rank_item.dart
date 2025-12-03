import 'design.dart';

class RankItem {
  final String id;
  final Design design;
  final int score;
  final bool isLiked;
  final int? rank; // 🔥 전체 등수(optional)

  RankItem({
    required this.id,
    required this.design,
    required this.score,
    required this.isLiked,
    this.rank,
  });
}

