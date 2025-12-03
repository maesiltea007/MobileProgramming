import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:hive/hive.dart';
import '../../models/design.dart';

class ColorPickerPage extends StatefulWidget {
  final String imagePath;

  const ColorPickerPage({super.key, required this.imagePath});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  ui.Image? _image;
  ByteData? _imageBytes;

  double _crossX = 200;
  double _crossY = 200;

  Color _selectedColor = Colors.white;
  int? _prevR, _prevG, _prevB; // 🔹 이전 RGB (±2 이내면 무시)

  @override
  void initState() {
    super.initState();
    _loadImage();
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
  String? _getCurrentUserId() {
    // TODO: 너네 로그인 시스템에 맞게 구현해야 되는 부분
    // 예: Hive.box('userbox').get('currentUserId') 등등
    // 지금은 테스트용으로 고정 ID를 반환해 두고, 나중에 실제 값으로 바꿔도 됨
    // return Hive.box('userbox').get('currentUserId') as String?;
    return 'dummy-user-1'; // 테스트용
  }

  Future<void> _loadImage() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    _image = frame.image;
    _imageBytes =
    await _image!.toByteData(format: ui.ImageByteFormat.rawRgba);

    setState(() {});
  }
  Future<void> _saveColorToHive(String userId) async {
    final designsBox = Hive.box('designsbox');
    final rankingBox = Hive.box('rankingbox');
    final likesBox = Hive.box('likesbox');

    // 🔑 고유 키 생성
    final String designId = 'd_${DateTime.now().millisecondsSinceEpoch}';

    // 🔥 Design 객체 하나 생성
    final design = Design(
      text: 'Picked Color',          // 필요하면 나중에 수정 가능
      fontFamily: 'Arial',           // 기본 폰트
      fontColor: Colors.black,       // 글자색
      backgroundColor: _selectedColor, // 🔥 컬러피커에서 고른 색
      ownerId: userId,
      createdAt: DateTime.now(),
    );

    // Hive에 Map 형태로 저장
    designsBox.put(designId, design.toMap());

    // 랭킹 / 좋아요 초기값
    rankingBox.put(designId, 0);
    likesBox.put(designId, false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('컬러가 저장되었습니다.')),
    );
  }


  void _updateColorFromPosition() {
    if (_image == null || _imageBytes == null) return;

    final int imgW = _image!.width;
    final int imgH = _image!.height;

    final int centerX = _crossX.toInt().clamp(0, imgW - 1);
    final int centerY = _crossY.toInt().clamp(0, imgH - 1);

    const int radius = 3; // 7x7
    int sumR = 0, sumG = 0, sumB = 0, sumA = 0, count = 0;

    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        final x = (centerX + dx).clamp(0, imgW - 1);
        final y = (centerY + dy).clamp(0, imgH - 1);

        final int byteOffset = (y * imgW + x) * 4;
        final r = _imageBytes!.getUint8(byteOffset);
        final g = _imageBytes!.getUint8(byteOffset + 1);
        final b = _imageBytes!.getUint8(byteOffset + 2);
        final a = _imageBytes!.getUint8(byteOffset + 3);

        sumR += r;
        sumG += g;
        sumB += b;
        sumA += a;
        count++;
      }
    }

    if (count == 0) return;

    int r = (sumR / count).round().clamp(0, 255);
    int g = (sumG / count).round().clamp(0, 255);
    int b = (sumB / count).round().clamp(0, 255);
    int a = (sumA / count).round().clamp(0, 255);

    // 🔹 변화가 거의 없으면(±2 이내) 업데이트 안 함
    if (_prevR != null &&
        (r - _prevR!).abs() <= 2 &&
        (g - _prevG!).abs() <= 2 &&
        (b - _prevB!).abs() <= 2) {
      return;
    }

    _prevR = r;
    _prevG = g;
    _prevB = b;

    final color = Color.fromARGB(a, r, g, b);

    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return Scaffold(
      appBar: AppBar(title: const Text('🎨 Color Picker')),
      body: image == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ── 위: 사진 영역 (크기 조금 줄이고, 아래에 공간 확보)
          Expanded(
            child: Center(
              // 이미지 비율 유지하면서 꽉 차게 보여주기
              child: AspectRatio(
                aspectRatio: image.width / image.height,
                child: Stack(
                  children: [
                    // 캡처 이미지
                    Positioned.fill(
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),

                    // 십자가 (드래그)
            // 십자가 (드래그)
            Positioned(
              left: _crossX - 20,
              top: _crossY - 20,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent, // 🔥 40x40 전체를 터치 영역으로
                onPanUpdate: (details) {
                  setState(() {
                    _crossX += details.delta.dx;
                    _crossY += details.delta.dy;

                    _crossX = _crossX.clamp(0, image.width.toDouble());
                    _crossY = _crossY.clamp(0, image.height.toDouble());
                  });

                  _updateColorFromPosition();
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      // 세로선
                      Positioned(
                        left: 19,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: Colors.white,
                        ),
                      ),
                      // 가로선
                      Positioned(
                        top: 19,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── 색 박스 + HEX 코드 + Save 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 색 미리보기 박스
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // HEX 코드 (가운데 / 왼쪽 정렬, 영역 꽉 쓰게)
                  Expanded(
                    child: Text(
                      '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Save 버튼 (우측 끝)
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1) 로그인된 유저 ID 가져오기
                        final userId = _getCurrentUserId();

                        // 2) 로그인 안 되어 있으면 팝업만 띄우고 리턴
                        if (userId == null) {
                          _showLoginRequiredDialog();
                          return;
                        }

                        // 3) 로그인 되어 있으면 Hive에 저장
                        await _saveColorToHive(userId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Colors.black26),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}