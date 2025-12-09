import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/design.dart';
import 'design_page.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../csw/login_page.dart';

//디자인카드 위젯
class DesignCard extends StatelessWidget {
  final Design design;
  const DesignCard({super.key, required this.design});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: design.backgroundColor,
        borderRadius: BorderRadius.circular(4),
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

// create new 카드 위젯
class CreateNewCard extends StatelessWidget {
  const CreateNewCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create New',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUserId = appState.currentUserId; // 로그인한 계정 정보
    final designsBox = Hive.box('designsbox');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder(
        valueListenable: designsBox.listenable(),   // hive 변경되면 페이지 새로고침
        builder: (context, Box box, _) {
          final List<Design> hiveDesigns = box.keys.map<Design>((key) {
            final raw = box.get(key);

            if (raw is Map) {
              final map = Map<String, dynamic>.from(raw as Map);
              return Design.fromMap(map);
            }
            return Design( // 이상한 상황에 보여줄 데이터
              id: null,
              text: '',
              fontFamily: 'Arial',
              fontColor: Colors.black,
              backgroundColor: Colors.white,
              ownerId: '',
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            );
          }).toList();

          final List<Design> designs = hiveDesigns
              .where((d) => d.ownerId == currentUserId) // ownerId 필터
              .toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: designs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    if (!appState.isLoggedIn) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Login Required'),
                            content: const Text(
                                'Please sign in to create a new design.'),
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
                      return; // 로그인이 안 되어 있으면 여기서 함수 종료
                    }
                    final newDesign = Design(
                      id: null,
                      text: 'hello',
                      fontFamily: 'Arial',
                      fontColor: Colors.white,
                      backgroundColor: Colors.black,
                      ownerId: 'new',
                      createdAt: DateTime.now(),
                    );
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => DesignPage(design: newDesign),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        transitionsBuilder: (_, __, ___, child) => child,
                      ),
                    );
                  },
                  child: const CreateNewCard(),
                );
              }

              final design = designs[index - 1];
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
          );
        },
      ),
    );
  }
}