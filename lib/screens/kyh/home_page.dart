import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 상단 타이틀
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '🏆 명예의 전당',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.refresh),
                ],
              ),
            ),

            // ✅ TOP 3 랭킹 영역
            Container(
              height: 140,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Text('Top 3 영역'),
            ),

            const SizedBox(height: 16),

            // ✅ 리스트 타이틀
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '이번 주 명예의 전당',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            // ✅ 랭킹 리스트 (스크롤 가능)
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('사용자 ${index + 1}'),
                    subtitle: const Text('활동 포인트: 000점'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  );
                },
              ),
            ),

            // ✅ 하단 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('전체 보기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
