import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../lji/library_page.dart';
import '../csw/help_page.dart';
import '../csw/app_settings_page.dart';
import '../kyh/rank_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ My Page')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoggedIn) {
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    Text(
                      'Account Required',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Log in or sign up to save your own designs and participate in rankings.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF3B2ECC),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Log in', style: TextStyle(fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Sign up', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ],
          ),
        ),
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
          _buildSectionTitle("My Activity"),
          _buildMenuTitle(context, Icons.design_services, 'My Library', () {
            // LibraryPage로 이동
            Navigator.of(context).pop(3);
          }),
          _buildMenuTitle(context, Icons.leaderboard_outlined, 'Rankings', () {
            Navigator.of(context).pop(1);
          }),
          /*
          _buildMenuTitle(context, Icons.favorite_border, 'Liked Designs', () {
            // TODO: 좋아요 한 디자인 목록 페이지로 이동
          }),
          */

          const SizedBox(height: 20),

          _buildSectionTitle("Settings & Support"),
          _buildMenuTitle(context, Icons.settings_outlined, 'App Settings', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsPage()));
          }),
          _buildMenuTitle(context, Icons.help_outline, 'Help & Contact', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpPage()));
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

  Widget _buildMenuTitle(BuildContext context, IconData icon, String title, VoidCallback onTap) {
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}