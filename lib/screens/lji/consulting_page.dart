import 'package:flutter/material.dart';
import '../../models/design.dart';
import 'design_page.dart';

class ConsultingPage extends StatelessWidget {
  final Design? design;

  const ConsultingPage({super.key, this.design});

  String _colorToHex(Color color) {
    final v = color.value.toRadixString(16).padLeft(8, '0');
    return '#${v.substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final d = design ??
        Design(
          id: 'default-preview',
          text: 'hello',
          fontFamily: 'Roboto',
          fontColor: Colors.white,
          backgroundColor: Colors.black,
          ownerId: 'system',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('consulting page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔸 프리뷰 (항상 있음)
          Hero(
            tag: 'design-preview-${d.id ?? 'temp'}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                decoration: BoxDecoration(
                  color: d.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    d.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: d.fontFamily,
                      color: d.fontColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 🔸 색/폰트 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${_colorToHex(d.backgroundColor)} · ${_colorToHex(d.fontColor)} · ${d.fontFamily}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),

          // 🔸 go to design 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => DesignPage(design: d),
                      transitionsBuilder: (_, animation, __, child) {
                        // 🔥 왼쪽(-1)에서 가운데(0)로 → 왼쪽에서 오른쪽으로 들어오는 효과
                        final tween = Tween<Offset>(
                          begin: const Offset(-1.0, 0.0),
                          end: Offset.zero,
                        ).chain(
                          CurveTween(curve: Curves.easeInOut),
                        );
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Go to design',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'chating UI will be here.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}