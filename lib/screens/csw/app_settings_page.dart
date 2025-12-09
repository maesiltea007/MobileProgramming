import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

// 앱에서 일관되게 사용하는 기본 색상
const Color _primaryColor = Color(0xFF3B2ECC);

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  // --- 상태 변수 (State Variables) ---
  bool _isDarkModeEnabled = false;
  bool _rankNotificationEnabled = true;
  bool _aiNotificationEnabled = true;
  bool _promoNotificationEnabled = false;

  // --- 유틸리티 위젯 (Utility Widgets) ---

  // 섹션 제목을 빌드하는 함수
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 메뉴 항목 (클릭 시 액션 발생)을 빌드하는 함수
  Widget _buildMenuTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {String? subtitle, Widget? trailing}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: _primaryColor),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  // 스위치 토글 항목을 빌드하는 함수
  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          secondary: Icon(icon, color: _primaryColor),
          value: value,
          onChanged: onChanged,
          activeColor: _primaryColor,
        ),
        const Divider(height: 1),
      ],
    );
  }

  // --- 액션 핸들러 (Action Handlers) ---

  // 회원 탈퇴 확인 다이얼로그
  void _handleDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Text('Are you sure you want to permanently delete your account and all saved data? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // TODO: 실제 Firebase Auth 및 Firestore 삭제 로직 구현
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion process initiated.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditNicknameDialog(BuildContext context, AppState appState) {
    final TextEditingController controller = TextEditingController(
      text: appState.currentNickname ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Nickname'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'New Nickname',
              hintText: 'Enter your nickname',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  // [핵심] AppState 닉네임 업데이트 호출
                  appState.updateNickname(newName);
                  Navigator.pop(context);

                  // (선택) 변경 확인 스낵바
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nickname changed to $newName')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B2ECC)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================================
            // 1. ACCOUNT MANAGEMENT (계정 관리)
            // ===========================================
            _buildSectionTitle('Account Management'),

            _buildMenuTile(
              context,
              Icons.person_outline,
              'Edit Profile / Nickname',
                  () {
                _showEditNicknameDialog(context, appState);
              },
              subtitle: 'Current: ${appState.currentNickname ?? 'Guest'}',
            ),
            _buildMenuTile(
              context,
              Icons.lock_outline,
              'Change Password',
                  () {
                // TODO: 비밀번호 변경 페이지로 이동
              },
            ),
            _buildMenuTile(
              context,
              Icons.email_outlined,
              'Change Email Address',
                  () {
                // TODO: 이메일 주소 변경 페이지로 이동
              },
            ),
            _buildMenuTile(
              context,
              Icons.delete_forever_outlined,
              'Delete Account',
                  () => _handleDeleteAccount(context),
            ),

            const Divider(height: 1, thickness: 8, color: Colors.black12),

            // ===========================================
            // 2. APP PREFERENCES (앱 환경 설정)
            // ===========================================
            _buildSectionTitle('App Preferences'),

            // 테마 설정 토글
            _buildSwitchTile(
              Icons.brightness_6_outlined,
              'Dark Mode',
              _isDarkModeEnabled,
                  (bool value) {
                setState(() {
                  _isDarkModeEnabled = value;
                  // TODO: 실제 테마 변경 로직 (Provider/ThemeData 업데이트) 구현
                });
              },
            ),

            _buildMenuTile(
              context,
              Icons.palette_outlined,
              'Default Color Palette',
                  () {
                // TODO: 기본 팔레트 선택 페이지/모달로 이동
              },
              subtitle: 'Current: Monochromatic', // 현재 설정된 값 표시
            ),
            _buildMenuTile(
              context,
              Icons.font_download_outlined,
              'Default Design Font',
                  () {
                // TODO: 기본 폰트 선택 BottomSheet/페이지로 이동
              },
              subtitle: 'Current: Arial', // 현재 설정된 값 표시
            ),

            const Divider(height: 1, thickness: 8, color: Colors.black12),

            // ===========================================
            // 3. NOTIFICATION SETTINGS (알림 설정)
            // ===========================================
            _buildSectionTitle('Notification Settings'),

            _buildSwitchTile(
              Icons.leaderboard_outlined,
              'Ranking Updates',
              _rankNotificationEnabled,
                  (bool value) {
                setState(() {
                  _rankNotificationEnabled = value;
                  // TODO: 서버 또는 로컬 알림 설정 업데이트
                });
              },
            ),
            _buildSwitchTile(
              Icons.insights_outlined,
              'AI Consulting Responses',
              _aiNotificationEnabled,
                  (bool value) {
                setState(() {
                  _aiNotificationEnabled = value;
                  // TODO: 서버 또는 로컬 알림 설정 업데이트
                });
              },
            ),
            _buildSwitchTile(
              Icons.campaign_outlined,
              'Marketing & Promotions',
              _promoNotificationEnabled,
                  (bool value) {
                setState(() {
                  _promoNotificationEnabled = value;
                });
              },
            ),

            const Divider(height: 1, thickness: 8, color: Colors.black12),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}