import 'package:epic_design_helper/screens/lji/widgets/design_page_widgets/color_hex_row.dart';
import 'package:epic_design_helper/screens/lji/widgets/design_page_widgets/design_preview.dart';
import 'package:epic_design_helper/screens/lji/widgets/design_page_widgets/fonts_bottom_sheet.dart';
import 'package:epic_design_helper/screens/lji/widgets/design_page_widgets/palette_bottom_sheet.dart';
import 'package:epic_design_helper/screens/lji/widgets/design_page_widgets/save_options_popup.dart';
import 'package:epic_design_helper/screens/lji/widgets/design_page_widgets/text_content_row.dart';
import 'package:flutter/material.dart';
import '../../models/design.dart';
import '../../services/design_repository.dart';
import '../../services/ranking_service.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'consulting_page.dart';
import '../csw/login_page.dart';

class DesignPage extends StatefulWidget {
  final Design design;
  const DesignPage({super.key, required this.design});
  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  late Color _backgroundColor;
  late Color _fontColor;
  late String _fontFamily;
  late String _text; // state 변수
  late TextEditingController _bgHexController;
  late TextEditingController _fontHexController;
  late TextEditingController _textController; // 컨트롤러

  final List<String> _availableFonts = [
    'Typewriter',
    'BrushScript',
    'Georgia',
    'Impact',
    'Pretendard',
  ];

  @override
  void initState() {
    super.initState();
    _backgroundColor = widget.design.backgroundColor;
    _fontColor = widget.design.fontColor;
    _fontFamily = widget.design.fontFamily;
    _text = widget.design.text; // 디자인 복사
    _bgHexController = TextEditingController(
      text: _colorToHex(_backgroundColor),
    );
    _fontHexController = TextEditingController(text: _colorToHex(_fontColor));
    _textController = TextEditingController(text: widget.design.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    _bgHexController.dispose();
    _fontHexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final v = color.value.toRadixString(16).padLeft(8, '0');
    return '#${v.substring(2).toUpperCase()}';
  }

  Color? _hexToColor(String input) {
    String value = input.trim();
    if (value.startsWith('#')) {
      value = value.substring(1);
    }
    if (value.length != 6) return null;
    try {
      final intColor = int.parse(value, radix: 16);
      return Color(0xFF000000 | intColor); // 항상 불투명
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),

            // go to library 버튼
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Go to library',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),

            // consult it 버튼
            ElevatedButton(
              onPressed: () {
                final current = Design(
                  id: widget.design.id,
                  text: _text,
                  fontFamily: _fontFamily,
                  fontColor: _fontColor,
                  backgroundColor: _backgroundColor,
                  ownerId: widget.design.ownerId,
                  createdAt: widget.design.createdAt,
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConsultingPage(design: current),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Consult it',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 12),
          ],
        ),

        // divider
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: Colors.black.withOpacity(0.2)),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          children: [
            // 🔥 Publish (랭킹에 올리기) 버튼 - 왼쪽에 추가
            SizedBox(
              width: 54,
              height: 54,
              child: GestureDetector(
                onTap: _publishToRanking,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send, // ✈ 비행기 아이콘
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),
            // Save 버튼
            Expanded(
              child: SizedBox(
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // delete icon button
            SizedBox(
              width: 54,
              height: 54,
              child: GestureDetector(
                onTap: _showDeleteConfirmDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(_backgroundColor, _fontColor, _fontFamily, _text),
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

  void _publishToRanking() {
    final id = widget.design.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the design first.')),
      );
      return;
    }

    // 이미 등록되어 있으면 중복 방지
    if (RankingService.rankingBox.containsKey(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'This design is already published to the ranking.'
        )),
      );
      return;
    }

    // 🔥 기존 디자인 불러오기
    final design = DesignRepository.get(id)!;

    // 🔥 createdAt 을 지금 시간으로 설정한 새 디자인 객체 생성
    final updated = Design(
      id: design.id,
      text: design.text,
      fontFamily: design.fontFamily,
      fontColor: design.fontColor,
      backgroundColor: design.backgroundColor,
      ownerId: design.ownerId,
      createdAt: DateTime.now(), // ⭐ 랭킹 등록 시간
    );

    // 🔥 DB에 저장
    DesignRepository.save(id, updated);

    // 🔥 랭킹 점수 초기화
    RankingService.initializeDesign(id);

    // 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Your design has been published to the ranking!')),
    );
  }


  // 상단 프리뷰 위젯
  Widget _buildPreview(Color bg, Color fontColor, String fontFamily, String text) {
    return Hero(
      tag: 'design-preview-${widget.design.id ?? 'temp'}',
      child: Material(
        color: Colors.transparent,
        child: DesignPreview(
          backgroundColor: bg,
          fontColor: fontColor,
          fontFamily: fontFamily,
          text: text,
        ),
      ),
    );
  }

  // 배경색 선택 위젯
  Widget _buildBackgroundColorRow(Color bg) {
    return ColorHexRow(
      label: 'background color',
      color: bg,
      controller: _bgHexController,
      onSubmitted: (value) {
        final c = _hexToColor(value);
        if (c != null) {
          setState(() {
            _backgroundColor = c;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid color. Use a hex like #RRGGBB.')),
          );
        }
      },
      onCircleTap: () async {
        final picked = await showPaletteBottomSheet(
          context,
          initialColor: _backgroundColor,
        );
        if (picked != null) {
          setState(() {
            _backgroundColor = picked;
            _bgHexController.text = _colorToHex(picked);
          });
        }
      },
    );
  }

  // 폰트 컬러 선택 위젯
  Widget _buildFontColorRow(Color fontColor) {
    return ColorHexRow(
      label: 'font color',
      color: fontColor,
      controller: _fontHexController,
      onSubmitted: (value) {
        final c = _hexToColor(value);
        if (c != null) {
          setState(() {
            _fontColor = c;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid color. Use a hex like #RRGGBB.')),
          );
        }
      },
      onCircleTap: () async {
        final picked = await showPaletteBottomSheet(
          context,
          initialColor: _fontColor,
        );
        if (picked != null) {
          setState(() {
            _fontColor = picked;
            _fontHexController.text = _colorToHex(picked);
          });
        }
      },
    );
  }

  //폰트 선택 위젯
  Widget _buildFontRow(String fontFamily, Color fontColor) {
    return GestureDetector(
      onTap: () async {
        final selected = await showFontPickerBottomSheet(
          context,
          fonts: _availableFonts,
          currentFontFamily: _fontFamily,
          sampleText: _text,
        );
        if (selected != null) {
          setState(() {
            _fontFamily = selected;
          });
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Az',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              fontFamily: fontFamily,
              color: fontColor,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('font', style: TextStyle(fontSize: 16)),
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
      ),
    );
  }

  // 텍스트 콘텐츠 위젯
  Widget _buildTextRow() {
    return TextContentRow(
      controller: _textController,
      onChanged: (value) {
        setState(() {
          _text = value;
        });
      },
    );
  }

  // 팝업창 "overwrite" or "save as new"
  void _showSaveOptions() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    if (widget.design.ownerId == 'new') { // 새 디자인 생성인 경우에는 save as new
      _saveAsNew();
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return SaveOptionsPopup(
          onSaveAsNew: () {
            Navigator.pop(context);
            _saveAsNew();
          },
          onOverwrite: () {
            Navigator.pop(context);
            _overwriteSave();
          },
        );
      },
    );
  }

  // 디자인 ID 생성 함수
  String generateDesignId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Design _buildCurrentDesign({
    String? id,
    required String ownerId,
    DateTime? createdAt,
  }) {
    return Design(
      id: id,
      text: _text,
      fontFamily: _fontFamily,
      fontColor: _fontColor,
      backgroundColor: _backgroundColor,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }

  // save as new
  void _saveAsNew() {
    final app = Provider.of<AppState>(context, listen: false);
    final id = generateDesignId();
    final updatedDesign = _buildCurrentDesign(
      id: id,
      ownerId: app.currentUserId!,
      createdAt: DateTime.now(),
    );
    DesignRepository.save(id, updatedDesign);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // overwrite 덮어쓰기
  void _overwriteSave() {
    final app = Provider.of<AppState>(context, listen: false);
    final existingId = widget.design.id;
    if (existingId == null) {
      _saveAsNew();
      return;
    }
    final updatedDesign = _buildCurrentDesign(
      id: existingId,
      ownerId: widget.design.ownerId,
    );
    DesignRepository.save(existingId, updatedDesign);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // 정말 삭제하시겠습니까 팝업
  void _showDeleteConfirmDialog() {
    if (widget.design.ownerId == 'new') { // 새 디자인이면 팝업 안 띄움
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    };

    final id = widget.design.id;
    if (id == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete design'),
          content: const Text('sure you want to delete this design?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await _deleteDesign(id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDesign(String id) async {
    DesignRepository.delete(id);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
              'Please sign in to save your design.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
              child: const Text('Log In'),
            ),
          ],
        );
      },
    );
  }
}