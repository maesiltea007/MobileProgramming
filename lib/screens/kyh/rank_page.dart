import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class RankPage extends StatelessWidget {
  const RankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔥 페이지 타이틀 (디자인 설정 반영)
          Text(
            '📊 이번 주 랭킹',
            style: TextStyle(
              fontSize: app.fontSize + 2,
              fontWeight: FontWeight.bold,
              color: app.mainColor,
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 좋아요 버튼 + 현재 좋아요 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: app.toggleLike,
                icon: const Icon(Icons.favorite),
                label: const Text("좋아요"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: app.mainColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '좋아요 수: ${app.likeCount}',
                style: TextStyle(fontSize: app.fontSize),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🔥 랭킹 리스트 (전역 디자인 반영)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                final rank = index + 1;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: app.mainColor.withOpacity(0.9),
                      child: Text(
                        '$rank',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '사용자 $rank',
                      style: TextStyle(
                        fontSize: app.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '포인트: ${1000 - index * 20}',
                      style: TextStyle(
                        fontSize: app.fontSize * 0.8,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: app.mainColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
