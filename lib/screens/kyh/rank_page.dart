import 'package:flutter/material.dart';
import '../../services/design_repository.dart';
import '../../services/ranking_service.dart';
import '../../models/design.dart';
import '../../models/rank_item.dart';


class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  late Future<List<RankItem>> _rankFuture;

  @override
  void initState() {
    super.initState();
    _rankFuture = _loadRanking();
  }

  Future<List<RankItem>> _loadRanking() async {
    final ranking = RankingService.getRanking(); // designId + score
    List<RankItem> items = [];

    for (final entry in ranking) {
      final designId = entry.key;
      final score = entry.value;

      final design = DesignRepository.get(designId);
      if (design != null) {
        items.add(
          RankItem(
            id: designId,
            design: design,
            score: score,
            isLiked: RankingService.isLiked(designId),
          ),
        );
      }
    }

    return items;
  }

  void _toggleLike(String designId) {
    RankingService.toggleLike(designId);
    setState(() {
      _rankFuture = _loadRanking(); // UI 갱신
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("📊 이번 주 랭킹")),

      body: FutureBuilder(
        future: _rankFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data as List<RankItem>;

          if (list.isEmpty) {
            return const Center(child: Text("아직 저장된 디자인이 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, index) {
              final item = list[index];
              final d = item.design;

              return GestureDetector(
                onDoubleTap: () => _toggleLike(item.id),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black87,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    title: Text(
                      d.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      "좋아요: ${item.score}",
                      style: const TextStyle(fontSize: 14),
                    ),

                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: item.isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleLike(item.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


