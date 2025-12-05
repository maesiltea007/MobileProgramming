import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

import '../../services/ranking_service.dart';
import '../../services/design_repository.dart';
import 'design_preview_box.dart';
import '../../models/design.dart';


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
                    'Hall of Fame',
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
// 🔥 1~3등 상단 고정 박스 (높이 축소 버전)
// -------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12), // 16 → 12 (박스 여백 축소)
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDDDDDD),
                    width: 1.5, // 2 → 1.5
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
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // ---------------------------
                              // 🔥 등수 아이콘 + #순위
                              // ---------------------------
                              Image.asset(
                                trophyImage(rank),
                                width: 26,
                                height: 26,
                              ),
                              const SizedBox(width: 6),

                              Text(
                                "#$rank",
                                style: TextStyle(
                                  fontSize: app.fontSize + 2,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // ---------------------------
                              // 🔥 좋아요 수
                              // ---------------------------
                              const Icon(
                                  Icons.favorite, color: Colors.red, size: 20),
                              const SizedBox(width: 4),

                              Text(
                                "${RankingService.getScore(entry.key)}",
                                style: TextStyle(
                                  fontSize: app.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // ---------------------------
                              // 🔥 미리보기 박스 (한 줄 오른쪽 공간을 전부 차지)
                              // ---------------------------
                              Expanded(
                                child: Container(
                                  height: 48, // 🔥 높이를 확 줄임
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      // 🔥 글자/레이아웃이 안 잘리고 축소됨
                                      child: SizedBox(
                                        width: 300, // 가로 기준 크기
                                        child: MiniPreviewBox(design: design),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
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
                      side: BorderSide(width: 2, color: color),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // 🔥 등수 + 좋아요 나란히
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: color, size: 22),
                              const SizedBox(width: 4),
                              Text(
                                "#$rank",
                                style: TextStyle(
                                  fontSize: app.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Icon(
                                  Icons.favorite, color: Colors.red, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "$score",
                                style: TextStyle(
                                  fontSize: app.fontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          // 🔥 미니 프리뷰
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: 300,
                                    child: MiniPreviewBox(design: design),
                                  ),
                                ),
                              ),
                            ),
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

class MiniPreviewBox extends StatelessWidget {
  final Design design;

  const MiniPreviewBox({super.key, required this.design});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // 🔥 원하는 높이
      alignment: Alignment.center, // 텍스트 가운데
      decoration: BoxDecoration(
        color: design.backgroundColor, // 🔥 색이 꽉 차도록
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        design.text,
        style: TextStyle(
          color: design.fontColor,
          fontFamily: design.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
