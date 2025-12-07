import 'package:flutter/material.dart';

Future<Color?> showPaletteBottomSheet(
    BuildContext context, {
      required Color initialColor,
    }) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaletteBottomSheet(initialColor: initialColor),
  );
}

class PaletteBottomSheet extends StatefulWidget {
  final Color initialColor;

  const PaletteBottomSheet({
    super.key,
    required this.initialColor,
  });

  @override
  State<PaletteBottomSheet> createState() => _PaletteBottomSheetState();
}

class _PaletteBottomSheetState extends State<PaletteBottomSheet> {
  late final List<Color> _paletteColors;
  late Color _selectedColor;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _paletteColors = _buildPaletteColors();
    _selectedColor = widget.initialColor;

    // 초기 색이 팔레트 안에 있으면 선택 인덱스 맞춰주기
    final idx = _paletteColors.indexOf(widget.initialColor);
    if (idx != -1) {
      _selectedIndex = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 cancel
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, null),
                  child: const Text(
                    'cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 선택 색 프리뷰 + choose this color 버튼
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedColor,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context, _selectedColor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'choose this color',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 팔레트 그리드
            SizedBox(
              height: 280,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 12, // 가로 셀 개수
                    ),
                    itemCount: _paletteColors.length,
                    itemBuilder: (context, index) {
                      final color = _paletteColors[index];
                      final isSelected = _selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                            _selectedColor = color;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(color: color),
                              ),
                              if (isSelected)
                                Positioned.fill(
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 4,
                                        ),
                                      ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HSL 기반으로 간단한 컬러 팔레트 생성
List<Color> _buildPaletteColors() {
  const rows = 10;
  const cols = 12;
  final List<Color> colors = [];

  for (int y = 0; y < rows; y++) {
    final double lightness = 0.9 - (y * 0.06); // 위→아래로 어두워짐
    final double saturation = y == rows - 1 ? 0.0 : 0.9; // 맨 아래는 거의 흰/회색 느낌

    for (int x = 0; x < cols; x++) {
      if (y == rows - 1) {
        final t = x / (cols - 1);          // 0 ~ 1
        final double lightness = 1.0 - t * 0.9; // 1.0 → 0.1
        final hsl = HSLColor.fromAHSL(1.0, 0, 0, lightness);
        colors.add(hsl.toColor());
        continue;
      }

      final double hue = (x / cols) * 360;
      final hsl =
      HSLColor.fromAHSL(1.0, hue, saturation.clamp(0.0, 1.0), lightness);
      colors.add(hsl.toColor());
    }
  }

  return colors;
}