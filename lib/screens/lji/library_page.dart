import 'package:flutter/material.dart';

//더미데이터형식
class SavedDesign {
  final String text;
  final String fontFamily;
  final Color fontColor;
  final Color backgroundColor;

  const SavedDesign({
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.backgroundColor,
  });
}

//더미데이터셋
//폰트는 야믈 파일에 다 지정해줘야 함!!
List<SavedDesign> get _designs => const [
  SavedDesign(
    text: 'hello',
    fontFamily: 'Arial',
    fontColor: Colors.white,
    backgroundColor: Color(0xFF5CA9FF),
  ),
  SavedDesign(
    text: 'world',
    fontFamily: 'Georgia',
    fontColor: Colors.white,
    backgroundColor: Color(0xFF2F9928),
  ),
  SavedDesign(
    text: 'Test',
    fontFamily: 'Courier New',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
  ),
  SavedDesign(
    text: 'Test',
    fontFamily: 'Arial',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
  ),
  SavedDesign(
    text: 'Test',
    fontFamily: 'Arial',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
  ),
  SavedDesign(
    text: 'Test',
    fontFamily: 'Arial',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
  ),
  SavedDesign(
    text: 'Test',
    fontFamily: 'Arial',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
  ),
];

//디자인카드 위젯
class DesignCard extends StatelessWidget {
  final SavedDesign design;
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
    final designs = _designs; // 더미데이터 가져오기

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
          return DesignCard(design: designs[index]);
        },
      ),
    );
  }
}
