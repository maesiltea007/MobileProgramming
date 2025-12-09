import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFF3B2ECC);

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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

  Widget _buildMenuTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: _primaryColor),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FREQUENTLY ASKED QUESTIONS (FAQ)
            _buildSectionTitle('Frequently Asked Questions'),

            _buildMenuTile(
              context,
              Icons.format_paint_outlined,
              'How to Use the Color Snap?',
                  () {
                _showHelpDialog(
                  context,
                  'Color Snap Guide',
                  'Color Snap allows you to precisely select colors using a visual wheel, sliders, or by directly entering Hex/RGB/HSL values. Use the "Scan" feature to extract colors instantly from an image or camera.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.insights_outlined,
              'How does the AI Consulting work?',
                  () {
                _showHelpDialog(
                  context,
                  'AI Consulting',
                  'Chat with our AI assistant for real-time color theory advice, design suggestions, and instant feedback on your color palettes. This feature requires an active network connection.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.save_alt,
              'Saving and Managing My Designs',
                  () {
                _showHelpDialog(
                  context,
                  'My Designs Management',
                  'Save your custom color palettes and design mockups to the "Library" section. Saved designs can be edited, deleted, or published to the ranking. This feature requires you to be logged in.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.leaderboard_outlined,
              'About the Design Ranking Criteria',
                  () {
                _showHelpDialog(
                  context,
                  'Ranking Criteria',
                  'The design ranking is calculated based on metrics such as originality, adherence to color theory principles, and community feedback (likes and ratings).',
                );
              },
            ),

            // 2. ACCOUNT AND PRIVACY
            _buildSectionTitle('Account & Privacy'),

            _buildMenuTile(
              context,
              Icons.edit,
              'How to Change My Nickname?',
                  () {
                _showHelpDialog(
                  context,
                  'Nickname Change',
                  'You can update your nickname in the "App Settings" page. Please remember that all nicknames must be unique.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.lock_outline,
              'Resetting or Changing Password',
                  () {
                _showHelpDialog(
                  context,
                  'Password Management',
                  'You can update your password in the "App Settings" page.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.delete_forever_outlined,
              'Account Deletion / Withdrawal',
                  () {
                _showHelpDialog(
                  context,
                  'Account Deletion',
                  'To permanently delete your account and all associated data (designs, chats), please request deletion through the "App Settings" menu.',
                );
              },
            ),

            // 3. CONTACT AND FEEDBACK
            _buildSectionTitle('Contact & Feedback'),

            _buildMenuTile(
              context,
              Icons.bug_report_outlined,
              'Report a Bug or Technical Issue',
                  () {
                _showHelpDialog(
                  context,
                  'Bug Report',
                  'If you encounter a technical issue, please email us immediately at support@colorsnap.com with a description and a screenshot (if possible).',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.email_outlined,
              'Other Inquiries (Email Us)',
                  () {
                _showHelpDialog(
                  context,
                  'General Inquiry',
                  'For all non-technical inquiries or general questions, please email us at info@colorsnap.com.',
                );
              },
            ),
            _buildMenuTile(
              context,
              Icons.feedback_outlined,
              'Submit Feature Request or Feedback',
                  () {
                _showHelpDialog(
                  context,
                  'Feedback',
                  'We value your input! Share your ideas for new features or improvements by emailing us at feedback@colorsnap.com.',
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}