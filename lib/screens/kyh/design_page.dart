import 'package:flutter/material.dart';
import '../../models/design.dart';
import '../../services/design_repository.dart';
import '../../services/ranking_service.dart';

// 디자인 ID 생성 함수
String generateDesignId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

class DesignPage extends StatefulWidget {
  final Design design;

  const DesignPage({super.key, required this.design});

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.design.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final v = color.value.toRadixString(16).padLeft(8, '0');
    return '#${v.substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.design.backgroundColor;
    final fontColor = widget.design.fontColor;
    final fontFamily = widget.design.fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Page'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _saveDesign,
        child: const Icon(Icons.save),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(bg, fontColor, fontFamily),
            const SizedBox(height: 32),
            _buildBackgroundColorRow(bg),
            const SizedBox(height: 24),
            _buildFontColorRow(fontColor),
            const SizedBox(height: 24),
            _buildFontRow(fontFamily, fontColor),
            const SizedBox(height: 24),
            _buildTextRow(),
          ],
        ),
      ),
    );
  }

  void _saveDesign() {
    final id = generateDesignId();

    // 수정된 텍스트 반영
    final updatedDesign = Design(
      text: _textController.text,
      fontFamily: widget.design.fontFamily,
      fontColor: widget.design.fontColor,
      backgroundColor: widget.design.backgroundColor,
    );

    // 1) 디자인 저장
    DesignRepository.save(id, updatedDesign);

    // 2) 랭킹/좋아요 초기값 Hive에 저장
    RankingService.initializeDesign(id);

    // 3) 페이지 종료 (필요하면 Snackbar 가능)
    Navigator.pop(context);
  }


  // 상단 프리뷰 위젯
  Widget _buildPreview(Color bg, Color fontColor, String fontFamily) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _textController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFamily,
            color: fontColor,
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  // 배경색 선택 위젯
  Widget _buildBackgroundColorRow(Color bg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'background color',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              _colorToHex(bg),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }


  // 폰트 컬러 선택 위젯
  Widget _buildFontColorRow(Color fontColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fontColor,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'font color',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              _colorToHex(fontColor),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //폰트 선택 위젯
  Widget _buildFontRow(String fontFamily, Color fontColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Az',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'font',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              fontFamily,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 텍스트 콘텐츠 위젯
  Widget _buildTextRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Az',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'text content',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}