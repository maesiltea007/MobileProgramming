import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

import '../../services/ranking_service.dart';
import '../../services/design_repository.dart';
import 'design_preview_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Color rankColor(int r) {
    if (r == 1) return const Color(0xffFFD700); // 금
    if (r == 2) return const Color(0xffC0C0C0); // 은
    if (r == 3) return const Color(0xffCD7F32); // 동
    return Colors.blueAccent; // 4~10등 기본 색
  }

  String trophyImage(int rank) {
    switch (rank) {
      case 1:
        return 'assets/rank/img2.png';
      case 2:
        return 'assets/rank/img3.png';
      case 3:
        return 'assets/rank/img4.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final top10 = RankingService.getTop10(); // key=id, value=score

    // 🔥 1~3등 / 4~10등 분리
    final top3 = top10.take(3).toList();
    final rest = top10.length > 3 ? top10.sublist(3) : [];

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 왼쪽 월계수 아이콘
                  Image.asset(
                    'assets/rank/img1.png',
                    width: 26,
                    height: 26,
                    color: Colors.black, // 금색으로 통일
                  ),
                  const SizedBox(width: 8),

                  // 텍스트
                  Text(
                    '명예의 전당',
                    style: TextStyle(
                      fontSize: app.fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 금색 텍스트
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),


            // -------------------------
            // 🔥 1~3등 상단 고정 박스 (명예의 전당 스타일로 변경)
            // -------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC), // 밝은 회색
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDDDDDD),
                    width: 2,
                  ),
                ),

                child: Column(
                  children: List.generate(top3.length, (i) {
                    final entry = top3[i];
                    final design = DesignRepository.get(entry.key);
                    final rank = i + 1;
                    final color = rankColor(rank);

                    if (design == null) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔥 등수(좌) + 좋아요(우)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // ⭐ 기존 Icon(Icons.emoji_events) 삭제하고 이미지로 교체
                                Image.asset(
                                  trophyImage(rank),
                                  width: 32,
                                  height: 32,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "$rank위",
                                  style: TextStyle(
                                    fontSize: app.fontSize + 3,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),

                            // 🔥 오른쪽 좋아요 수
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.red,
                                    size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "${RankingService.getScore(entry.key)}",
                                  style: TextStyle(
                                    fontSize: app.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black, // ← 검정색으로 변경
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 🔥 미리보기 카드
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withOpacity(0.8),
                              width: 1.2,
                            ),
                          ),
                          child: DesignPreviewBox(design: design),
                        ),

                        if (i != top3.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              color: Colors.white.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),


            const SizedBox(height: 12),

            // -------------------------
            // 🔥 4~10등 스크롤 영역
            // -------------------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: rest.length,
                itemBuilder: (_, index) {
                  final entry = rest[index];
                  final design = DesignRepository.get(entry.key);
                  final score = entry.value;
                  final rank = index + 4; // 4위부터 시작
                  final color = rankColor(rank);

                  if (design == null) return const SizedBox.shrink();

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        width: 2,
                        color: color,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [

                          // 디자인 미리보기
                          DesignPreviewBox(design: design),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.emoji_events,
                                      color: color, size: 22),
                                  const SizedBox(width: 6),
                                  Text(
                                    "#$rank",
                                    style: TextStyle(
                                      fontSize: app.fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: const Color(0xFFE53935),
                                    // 좀 더 입체감 있는 진한 레드
                                    size: 22,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black38,
                                        blurRadius: 4,
                                        offset: Offset(1, 1),
                                      )
                                    ],
                                  ),

                                  const SizedBox(width: 4),
                                  Text(
                                    "${RankingService.getScore(entry.key)}",
                                    style: TextStyle(
                                      fontSize: app.fontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
