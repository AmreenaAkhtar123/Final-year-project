import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _analyticsEnabled = false;
  bool _cameraPermission = true;
  bool _microphonePermission = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.navy,
          ),
        ),
        title: const Text(
          'Privacy & Data',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          _buildPrivacyHeader(),

          const SizedBox(height: 24),

          _buildSectionTitle(
            'Data preferences',
            'Control optional data collection.',
          ),

          const SizedBox(height: 12),

          _buildCard(
            children: [
              _buildSwitchTile(
                title: 'Anonymous analytics',
                subtitle:
                'Help improve the app using non-personal usage data.',
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() {
                    _analyticsEnabled = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 26),

          _buildSectionTitle(
            'Device permissions',
            'Permissions used by MindMate features.',
          ),

          const SizedBox(height: 12),

          _buildCard(
            children: [
              _buildPermissionTile(
                icon: Icons.camera_alt_outlined,
                title: 'Camera',
                subtitle: 'Used for facial emotion features.',
                enabled: _cameraPermission,
                onTap: () {
                  setState(() {
                    _cameraPermission = !_cameraPermission;
                  });
                },
              ),
              _divider(),
              _buildPermissionTile(
                icon: Icons.mic_none_rounded,
                title: 'Microphone',
                subtitle: 'Used for voice mood features.',
                enabled: _microphonePermission,
                onTap: () {
                  setState(() {
                    _microphonePermission = !_microphonePermission;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 26),

          _buildSectionTitle(
            'Your data',
            'Manage information created inside MindMate.',
          ),

          const SizedBox(height: 12),

          _buildCard(
            children: [
              _buildActionTile(
                icon: Icons.download_outlined,
                title: 'Export My Data',
                subtitle: 'Prepare a copy of your MindMate information.',
                onTap: _exportData,
              ),
              _divider(),
              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Local Data',
                subtitle: 'Remove locally stored demo information.',
                destructive: true,
                onTap: _deleteData,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'MindMate is currently running with local/demo data. '
                'Permanent account data controls will be connected when the backend is implemented.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.40),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF294253),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.mint,
            size: 27,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Your wellbeing information should remain under your control.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.42),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.42),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.mint,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Icon(
        icon,
        color: AppColors.mint,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.navy.withValues(alpha: 0.42),
          fontSize: 10,
        ),
      ),
      trailing: Text(
        enabled ? 'Enabled' : 'Off',
        style: TextStyle(
          color: enabled
              ? AppColors.mint
              : AppColors.navy.withValues(alpha: 0.35),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Icon(
        icon,
        color: destructive
            ? const Color(0xFFC96F5C)
            : AppColors.mint,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: destructive
              ? const Color(0xFFC96F5C)
              : AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.navy.withValues(alpha: 0.42),
          fontSize: 10,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: AppColors.borderMint.withValues(alpha: 0.7),
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your demo wellbeing information is ready to be exported. '
              'Actual file export will be connected with the backend later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Local Data?'),
        content: const Text(
          'This will remove locally stored demo information from this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Local demo data cleared.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC96F5C),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}