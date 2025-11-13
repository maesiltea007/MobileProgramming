import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 상단 타이틀 + 전역 디자인 적용
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏆 명예의 전당',
                    style: TextStyle(
                      fontSize: app.fontSize + 4,     // 🔥 전역 폰트 크기 적용
                      color: app.mainColor,           // 🔥 전역 컬러 적용
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.refresh, color: app.mainColor), // 🔥 전역 컬러 반영
                ],
              ),
            ),

            // ✅ TOP 3 랭킹 영역
            Container(
              height: 140,
              color: app.mainColor.withOpacity(0.1),  // 🔥 전역 색감 기반 배경 톤
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

            // ✅ 리스트 타이틀
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

            // ✅ 랭킹 리스트 (전역 디자인 적용)
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: app.mainColor.withOpacity(0.8),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '사용자 ${index + 1}',
                      style: TextStyle(
                        fontSize: app.fontSize,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '활동 포인트: ${1000 - index * 20}점',
                      style: TextStyle(fontSize: app.fontSize * 0.8),
                    ),
                    trailing: Icon(Icons.chevron_right, color: app.mainColor),
                    onTap: () {},
                  );
                },
              ),
            ),

            // ✅ 하단 버튼 (전역 색상 반영)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app.mainColor,      // 🔥 전역 색상
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
