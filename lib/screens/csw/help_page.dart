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
            // ===========================================
            // 1. FREQUENTLY ASKED QUESTIONS (FAQ)
            // ===========================================
            _buildSectionTitle('Frequently Asked Questions'),

            _buildMenuTile(
              context,
              Icons.format_paint_outlined,
              'How to Use the Color Snap?',
                  () {
                _showHelpDialog(
                  context,
                  'Color Snap Guide',
                  'The Color Snap allows you to select precise colors using a visual wheel, sliders, or by entering Hex/RGB/HSL values. Use the "Scan" feature to extract colors directly from an image or camera view.',
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
                  'Our AI Consulting feature allows you to chat with an AI assistant for real-time color theory advice, design suggestions, and feedback on your color palettes. This feature requires an active network connection.',
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
                  'You can save your custom color palettes and design mockups to the "My Designs" section. Designs can be edited or deleted later. This feature requires you to be logged in.',
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
                  'The design ranking is based on various metrics, including originality, adherence to color theory principles, and community feedback (likes/ratings). Rankings are updated daily.',
                );
              },
            ),

            // ===========================================
            // 2. ACCOUNT AND PRIVACY
            // ===========================================
            _buildSectionTitle('Account & Privacy'),

            _buildMenuTile(
              context,
              Icons.edit,
              'How to Change My Nickname?',
                  () {
                _showHelpDialog(
                  context,
                  'Nickname Change',
                  'You can change your nickname by navigating to the "App Settings" page. Please note that nicknames must be unique and adhere to our policy guidelines.',
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
                  'To change your password, go to "App Settings". If you forgot your password, please use the "Forgot Password" link on the login screen to receive a reset link via email.',
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
                  'If you wish to delete your account, please send a request to [Your Support Email] from your registered email address. All saved data (designs, chats) will be permanently removed.',
                );
              },
            ),

            // ===========================================
            // 3. CONTACT AND FEEDBACK
            // ===========================================
            _buildSectionTitle('Contact & Feedback'),

            _buildMenuTile(
              context,
              Icons.bug_report_outlined,
              'Report a Bug or Technical Issue',
                  () {
                _showHelpDialog(
                  context,
                  'Bug Report',
                  'Please contact us immediately via email at support@colorsnap.com with a description of the issue and a screenshot (if possible).',
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
                  'For all other non-technical questions, please email us at info@colorsnap.com.',
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
                  'We value your feedback! Send us your ideas for new features or improvements to feedback@colorsnap.com.',
                );
              },
            ),

            // ===========================================
            // 4. LEGAL AND APP INFO
            // ===========================================
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}