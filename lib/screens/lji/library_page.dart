import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/design.dart';
import '../../data/saved_designs.dart';
import 'design_page.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

//디자인카드 위젯
class DesignCard extends StatelessWidget {
  final Design design;
  const DesignCard({super.key, required this.design});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: design.backgroundColor,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Center(
        child: Text(
          design.text,
          style: TextStyle(
            fontFamily: design.fontFamily,
            color: design.fontColor,
            fontWeight: FontWeight.w500,
            fontSize: 30
          ),
        ),

      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUserId = appState.currentUserId; // 로그인한 계정 정보
    final designsBox = Hive.box('designsbox');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder(
        valueListenable: designsBox.listenable(),   // hive 변경되면 페이지 새로고침
        builder: (context, Box box, _) {
          // 1) Hive → Design 리스트 변환
          final List<Design> hiveDesigns = box.keys.map<Design>((key) {
            final raw = box.get(key);

            if (raw is Map) {
              final map = Map<String, dynamic>.from(raw as Map);
              return Design.fromMap(map);
            }

            // 혹시 데이터가 이상하면 기본값 하나
            return Design(
              id: null,
              text: '',
              fontFamily: 'Arial',
              fontColor: Colors.black,
              backgroundColor: Colors.white,
              ownerId: '',
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            );
          }).toList();

          // 2) Hive에 아무것도 없으면 기존 더미데이터 사용
          final List<Design> designs = (hiveDesigns.isNotEmpty ? hiveDesigns : UserDesigns)
              .where((d) => d.ownerId == currentUserId) // ownerId 필터
              .toList();

          print('currentUserId = $currentUserId');
          print('hiveDesigns length = ${hiveDesigns.length}');
          print('filtered designs length = ${designs.length}');

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: designs.length,
            itemBuilder: (context, index) {
              final design = designs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => DesignPage(design: design),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      transitionsBuilder: (_, __, ___, child) => child,
                    ),
                  );
                },
                child: DesignCard(design: design),
              );
            },
          );
        },
      ),
    );
  }
}