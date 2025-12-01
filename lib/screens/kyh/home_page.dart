import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

import '../../services/ranking_service.dart';
import '../../services/design_repository.dart';
import '../../models/design.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    // 🔥 Hive에서 상위 10위 가져오기
    final top10 = RankingService.getTop10();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏆 명예의 전당',
                    style: TextStyle(
                      fontSize: app.fontSize + 4,
                      color: app.mainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.refresh, color: app.mainColor),
                ],
              ),
            ),

            // TOP 3 영역 (디자인 반영 가능)
            Container(
              height: 140,
              color: app.mainColor.withOpacity(0.1),
              alignment: Alignment.center,
              child: Text(
                'Top 3 영역',
                style: TextStyle(
                  fontSize: app.fontSize,
                  color: app.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 리스트 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '이번 주 명예의 전당',
                style: TextStyle(
                  fontSize: app.fontSize,
                  fontWeight: FontWeight.bold,
                  color: app.mainColor,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🔥 Hive 데이터 기반 리스트
            Expanded(
              child: ListView.builder(
                itemCount: top10.length,
                itemBuilder: (context, index) {
                  final entry = top10[index]; // MapEntry<String, int>
                  final designId = entry.key;
                  final score = entry.value;

                  final design = DesignRepository.get(designId);

                  if (design == null) {
                    return ListTile(
                      title: Text("삭제된 디자인 ($designId)"),
                      subtitle: Text("점수: $score"),
                    );
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: app.mainColor.withOpacity(0.8),
                      child: Text(
                        '${index + 1}', // 순위
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    title: Text(
                      design.text,
                      style: TextStyle(
                        fontSize: app.fontSize,
                        color: Colors.black,
                      ),
                    ),

                    subtitle: Text(
                      '점수: $score',
                      style: TextStyle(fontSize: app.fontSize * 0.8),
                    ),

                    trailing: Icon(Icons.chevron_right, color: app.mainColor),
                    onTap: () {},
                  );
                },
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app.mainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    '전체 보기',
                    style: TextStyle(fontSize: app.fontSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
