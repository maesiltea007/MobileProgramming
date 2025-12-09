import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 앱에서 일관되게 사용하는 기본 색상
const Color _primaryColor = Color(0xFF3B2ECC);

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  // --- 상태 변수 (State Variables) ---
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
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
  void _handleDeleteAccount(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Text('Are you sure you want to permanently delete your account and all saved data? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // 일단 다이얼로그 닫기

              try {
                // 탈퇴 함수 호출
                await appState.deleteAccount();

                // 성공 시 첫 화면(로그인/홈)으로 이동 및 메시지 표시
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully.')),
                  );
                }
              } on FirebaseAuthException catch (e) {
                // 재로그인 필요 시
                if (e.code == 'requires-recent-login') {
                  if (context.mounted) _showReLoginDialog(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.message}')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
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

  void _showChangePasswordDialog(BuildContext context, AppState appState) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true, // 비밀번호 가리기
            decoration: const InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter new password (min. 6 chars)',
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
              onPressed: () async {
                final newPass = passwordController.text.trim();
                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters long.')),
                  );
                  return;
                }

                try {
                  // 1. 비밀번호 변경 시도
                  await appState.changePassword(newPass);
                  Navigator.pop(context); // 성공 시 다이얼로그 닫기

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully!')),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context); // 에러 발생 시 일단 다이얼로그 닫기

                  // 2. 재로그인 필요 에러 처리
                  if (e.code == 'requires-recent-login') {
                    _showReLoginDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.message}')),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B2ECC)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showReLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Security Alert'),
        content: const Text('For your security, this operation requires a recent login. Please log out and log in again to change your password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // elevation: 0,
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
                // 로그인 여부 확인
                if (appState.isLoggedIn) {
                  _showChangePasswordDialog(context, appState);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in first.')),
                  );
                }
              },
            ),
            _buildMenuTile(
              context,
              Icons.delete_forever_outlined,
              'Delete Account',
                  () {
                // 로그인 상태일 때만 실행
                if (appState.isLoggedIn) {
                  // appState를 인자로 넘겨줍니다.
                  _handleDeleteAccount(context, appState);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in first.')),
                  );
                }
              },
            ),

            const Divider(height: 1, thickness: 8, color: Colors.black12),

            // 2. APP PREFERENCES
            _buildSectionTitle('App Preferences'),

            // 테마 설정 토글
            _buildSwitchTile(
              Icons.brightness_6_outlined,
              'Dark Mode',
              // [수정] AppState의 isDarkMode 사용
              appState.isDarkMode,
                  (bool value) {
                // [수정] AppState의 toggleDarkMode 함수 호출
                appState.toggleDarkMode();
              },
            ),

            _buildMenuTile(
              context,
              Icons.palette_outlined,
              'Default Color Palette',
                  () {},
              subtitle: ': Black',
              trailing: const SizedBox.shrink(),
            ),
            _buildMenuTile(
              context,
              Icons.font_download_outlined,
              'Default Design Font',
                  () {},
              subtitle: ': Arial',
              trailing: const SizedBox.shrink(),
            ),

            const Divider(height: 1, thickness: 8, color: Colors.black12),

            // 3. NOTIFICATION SETTINGS
            /*
            _buildSectionTitle('Notification Settings'),

            _buildSwitchTile(
              Icons.leaderboard_outlined,
              'Ranking Updates',
              _rankNotificationEnabled,
                  (bool value) {
                setState(() {
                  _rankNotificationEnabled = value;
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
          */

            // 4. INFORMATION & LEGAL
            _buildSectionTitle('Information & Legal'),

            _buildMenuTile(
              context,
              Icons.description_outlined,
              'Terms of Service',
                  () {
                _showHelpDialog(
                  context,
                  'Terms of Service',
                  'By using this application, you agree to our Terms of Service (TOS). Please visit our website [Website URL] to read the full document.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.security_outlined,
              'Privacy Policy',
                  () {
                _showHelpDialog(
                  context,
                  'Privacy Policy',
                  'We are committed to protecting your personal data. For details on how we collect and use your information, please visit our Privacy Policy [Website URL].',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.info_outline,
              'App Version: 1.0.0',
                  () {
                _showHelpDialog(
                  context,
                  'Application Information',
                  'Color Snap - Epic Design Helper\nVersion: 1.0.0',
                );
              },
            ),

            const Divider(height: 1, thickness: 8, color: Colors.black12),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryColor)),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}