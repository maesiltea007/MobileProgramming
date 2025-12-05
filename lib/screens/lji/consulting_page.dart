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
          ownerId: 'new',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),

            // Design it 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => DesignPage(design: d),
                    transitionsBuilder: (_, animation, __, child) {
                      final tween = Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Design it',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // 홈 버튼
            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),

        // 아래 구분선
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    d.text,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${_colorToHex(d.backgroundColor)} · '
                  '${_colorToHex(d.fontColor)} · '
                  '${d.fontFamily}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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