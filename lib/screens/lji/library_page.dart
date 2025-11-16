import 'package:flutter/material.dart';
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
    final designs = UserDesigns; // 더미데이터 가져오기

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: designs.length,   // 저장된 디자인 개수

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
