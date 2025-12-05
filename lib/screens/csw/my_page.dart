import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../lji/library_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ My Page')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoggedIn) {
            // 🔥 닉네임이 null이면 기본값 'User'로 대체
            final nickname = appState.currentNickname ?? 'User';
            return _buildLoggedInPage(context, nickname);
          } else {
            return _buildLoggedOutPage(context);
          }
        },
      ),
    );
  }

  // 로그인하지 않았을 때
  Widget _buildLoggedOutPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            '로그인이 필요합니다',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '나만의 디자인 저장, 랭킹 참여 등의 기능을 이용하려면',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Text(
            '로그인 또는 회원가입을 해주세요.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF3B2ECC), // LoginPage에서 사용된 색상
                foregroundColor: Colors.white,
              ),
              child: const Text('로그인', style: TextStyle(fontSize: 18)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: const Text('회원가입', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // 로그인 했을 때
  Widget _buildLoggedInPage(BuildContext context, String nickname) {
    final appState = Provider.of<AppState>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보 섹션
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Welcome, '),
                      TextSpan(
                        text: nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '!'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 메뉴 리스트
          _buildMenuTile(context, Icons.design_services, 'My Designs', () {
            // TODO: 나의 디자인 페이지로 이동
          }),
          _buildMenuTile(context, Icons.settings, 'App settings', () {
            /*
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppSettingPage())
            );
            */
          }),
          _buildMenuTile(context, Icons.help_outline, 'Help/Contact', () {
            // TODO: 도움말 페이지로 이동
          }),

          const Divider(height: 40),

          // 로그아웃 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                appState.logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF3B2ECC)),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}