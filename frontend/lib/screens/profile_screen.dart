import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _privateModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 28),

                    _buildProfileHeader(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'Account',
                      'Manage your personal information',
                    ),

                    const SizedBox(height: 12),

                    _buildAccountCard(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      'Wellbeing & Privacy',
                      'Control your MindMate experience',
                    ),

                    const SizedBox(height: 12),

                    _buildPreferencesCard(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      'Support & Safety',
                      'Help when you need it',
                    ),

                    const SizedBox(height: 12),

                    _buildSupportCard(),

                    const SizedBox(height: 26),

                    _buildLogoutButton(),

                    const SizedBox(height: 20),

                    _buildAppFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Image.asset(
            'assets/images/logo1.png',
            width: 115,
            height: 38,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
        ),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.navy,
            size: 23,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF294253),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.13),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.10),
              ),
            ),
          ),

          Positioned(
            right: 25,
            bottom: -55,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 16,
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Profile image
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightMint,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.mint,
                  size: 43,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Demo User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'demo@mindmate.com',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.mint.withValues(alpha: 0.20),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: AppColors.mint,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Taking care of your wellbeing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.50),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACCOUNT
  // ============================================================

  Widget _buildAccountCard() {
    return _buildSettingsCard(
      children: [
        _buildSettingsTile(
          icon: Icons.person_outline_rounded,
          iconBackground: AppColors.lightMint,
          iconColor: AppColors.mint,
          title: 'Personal Information',
          subtitle: 'Name, date of birth and gender',
          onTap: () {
            _showMessage(
              'Personal information will open here.',
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.email_outlined,
          iconBackground: const Color(0xFFF1F3FC),
          iconColor: const Color(0xFF6B7FD7),
          title: 'Email Address',
          subtitle: 'demo@mindmate.com',
          onTap: () {
            _showMessage(
              'Email settings will open here.',
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.lock_outline_rounded,
          iconBackground: const Color(0xFFFFF5E9),
          iconColor: const Color(0xFFE29A45),
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () {
            _showMessage(
              'Change password will open here.',
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // PREFERENCES
  // ============================================================

  Widget _buildPreferencesCard() {
    return _buildSettingsCard(
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_none_rounded,
          iconBackground: const Color(0xFFF1F3FC),
          iconColor: const Color(0xFF6B7FD7),
          title: 'Notifications',
          subtitle: 'Check-in reminders and wellbeing updates',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),

        _buildDivider(),

        _buildSwitchTile(
          icon: Icons.shield_outlined,
          iconBackground: AppColors.lightMint,
          iconColor: AppColors.mint,
          title: 'Private Mode',
          subtitle: 'Keep wellbeing information discreet',
          value: _privateModeEnabled,
          onChanged: (value) {
            setState(() {
              _privateModeEnabled = value;
            });
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.privacy_tip_outlined,
          iconBackground: const Color(0xFFF8EFF9),
          iconColor: const Color(0xFFAD76B5),
          title: 'Privacy & Data',
          subtitle: 'Manage your wellbeing data',
          onTap: () {
            _showMessage(
              'Privacy and data controls will open here.',
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // SUPPORT
  // ============================================================

  Widget _buildSupportCard() {
    return _buildSettingsCard(
      children: [
        _buildSettingsTile(
          icon: Icons.emergency_outlined,
          iconBackground: const Color(0xFFFFE9E3),
          iconColor: const Color(0xFFD67A65),
          title: 'Crisis & Emergency Support',
          subtitle: 'Get immediate support when needed',
          onTap: () {
            _showMessage(
              'Emergency support will open here.',
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.help_outline_rounded,
          iconBackground: const Color(0xFFEDF5F8),
          iconColor: const Color(0xFF5C8FA8),
          title: 'Help & Support',
          subtitle: 'FAQs and assistance',
          onTap: () {
            _showMessage(
              'Help and support will open here.',
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.info_outline_rounded,
          iconBackground: const Color(0xFFEEF7EF),
          iconColor: const Color(0xFF6D9A72),
          title: 'About MindMate',
          subtitle: 'Version and application information',
          onTap: () {
            _showAboutDialog();
          },
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.45),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.navy,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.45),
                    fontSize: 10.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.mint,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor:
            AppColors.navy.withValues(alpha: 0.15),
            materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 71,
        right: 15,
      ),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: AppColors.borderMint.withValues(alpha: 0.75),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
        ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD67A65),
          side: const BorderSide(
            color: Color(0xFFF0D5CD),
          ),
          backgroundColor: const Color(0xFFFFF9F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildAppFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
              size: 14,
            ),

            const SizedBox(width: 6),

            Text(
              'Your wellbeing data stays private',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.42),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          'MindMate • Your wellbeing companion',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.28),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of MindMate?',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.navy,
                ),
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mint,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MindMate',
      applicationVersion: '1.0.0',
      applicationLegalese:
      'Mental wellbeing support for students.',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}