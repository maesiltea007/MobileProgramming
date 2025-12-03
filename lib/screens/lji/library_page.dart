import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/design.dart';
import '../../data/saved_designs.dart';
import 'design_page.dart';

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
    final designsBox = Hive.box('designsbox');

    // 1) Hive에 있는 디자인들 전부 꺼내서 Design 리스트로 변환
    final List<Design> hiveDesigns = designsBox.keys.map<Design>((key) {
      final raw = designsBox.get(key);

      if (raw is Map) {
        // Map<dynamic, dynamic> → Map<String, dynamic> 캐스팅
        final map = Map<String, dynamic>.from(raw as Map);
        return Design.fromMap(map);
      }

      // 혹시 데이터가 이상하면 기본값 하나
      return Design(
        text: '',
        fontFamily: 'Arial',
        fontColor: Colors.black,
        backgroundColor: Colors.white,
        ownerId: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }).toList();

    // 2) Hive에 아무것도 없으면 → 기존 더미데이터 사용
    final List<Design> designs =
    hiveDesigns.isNotEmpty ? hiveDesigns : UserDesigns;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
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
      ),
    );
  }
}

