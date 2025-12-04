import 'package:flutter/material.dart';
import '../../models/design.dart';
import '../../services/design_repository.dart';
import '../../services/ranking_service.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class DesignPage extends StatefulWidget {
  final Design design;
  const DesignPage({super.key, required this.design});

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  late TextEditingController _textController;

  late Color _backgroundColor;
  late Color _fontColor;
  late String _fontFamily;
  late String _text; // state 변수

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.design.text);
    _backgroundColor = widget.design.backgroundColor;
    _fontColor = widget.design.fontColor;
    _fontFamily = widget.design.fontFamily;
    _text = widget.design.text; // 디자인 복사
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Page'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
              onPressed: _showSaveOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(_backgroundColor, _fontColor, _fontFamily),
            const SizedBox(height: 32),
            _buildBackgroundColorRow(_backgroundColor),
            const SizedBox(height: 24),
            _buildFontColorRow(_fontColor),
            const SizedBox(height: 24),
            _buildFontRow(_fontFamily, _fontColor),
            const SizedBox(height: 24),
            _buildTextRow(),
          ],
        ),
      ),
    );
  }

  void _saveDesign() {
    // 0) 로그인 체크
    final app = Provider.of<AppState>(context, listen: false);
    if (!app.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    // 로그인된 상태라면 저장 로직 진행
    final id = generateDesignId();

    final updatedDesign = Design(
      text: _text,
      fontFamily: _fontFamily,
      fontColor: _fontColor,
      backgroundColor: _backgroundColor,
      ownerId: app.currentUserId!,
      createdAt: DateTime.now(),
    );

    DesignRepository.save(id, updatedDesign);
    RankingService.initializeDesign(id);

    Navigator.pop(context);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("로그인이 필요합니다"),
          content: const Text("디자인을 저장하려면 로그인해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 먼저 팝업 닫고
                Navigator.pushNamed(context, '/login'); // 로그인 페이지로 이동
              },
              child: const Text("로그인하기"),
            ),
          ],
        );
      },
    );
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
          _text,
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
                onChanged: (value) {
                  setState(() {
                    _text = value;
                  });
                },
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

  // 팝업창 "overwrite" or "save as new"
  void _showSaveOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Save Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveAsNew();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save as New",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _overwriteSave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Overwrite",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // 디자인 ID 생성 함수
  String generateDesignId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // save as new
  void _saveAsNew() {
    final app = Provider.of<AppState>(context, listen: false);
    if (!app.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    final id = generateDesignId();
    final updatedDesign = Design(
      id: id,
      text: _text,
      fontFamily: _fontFamily,
      fontColor: _fontColor,
      backgroundColor: _backgroundColor,
      ownerId: app.currentUserId!,
      createdAt: DateTime.now(),
    );
    DesignRepository.save(id, updatedDesign);
    Navigator.pop(context);
  }

// overwrite 덮어쓰기
  void _overwriteSave() {
    final app = Provider.of<AppState>(context, listen: false);
    if (!app.isLoggedIn) { // 로그인 체크
      _showLoginRequiredDialog();
      return;
    }

    final existingId = widget.design.id; // 기존 디자인 ID
    if (existingId == null) { // id가 없으면 그냥 새로 저장
      _saveAsNew();
      return;
    }

    final updatedDesign = Design(
      id: existingId,
      text: _text,
      fontFamily: _fontFamily,
      fontColor: _fontColor,
      backgroundColor: _backgroundColor,
      ownerId: widget.design.ownerId,        // 원래 주인 유지
      createdAt: widget.design.createdAt,    // 생성 시각 유지
    );

    DesignRepository.save(existingId, updatedDesign);
    Navigator.pop(context);
  }
}