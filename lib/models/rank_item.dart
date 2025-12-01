import 'design.dart';

class RankItem {
  final String id; // designId
  final Design design; // 실제 디자인 데이터
  final int score; // 좋아요 수
  final bool isLiked; // 좋아요 여부

  RankItem({
    required this.id,
    required this.design,
    required this.score,
    required this.isLiked,
  });
}
