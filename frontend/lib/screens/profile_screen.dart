import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/profile_image_service.dart';
import '../core/services/check_in_service.dart';
import '../core/constants/app_colors.dart';
import '../models/check_in.dart';

import 'settings/about_mindmate_screen.dart';
import 'settings/help_support_screen.dart';
import 'settings/password_security_screen.dart';
import 'settings/email_address_screen.dart';
import 'settings/personal_information_screen.dart';
import 'settings/privacy_data_screen.dart';
import 'settings/wellbeing_preferences_screen.dart';
import 'safety_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _privateModeEnabled = true;

  double _wellbeingScore = 0;
  int _currentStreak = 0;
  int _checkIns = 0;

  bool _isLoadingWellbeing = true;

  File? _profileImage;
  bool _isLoadingProfileImage = true;

  String _fullName = '';
  String _email = '';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();

    ProfileImageService.profileImageNotifier.addListener(
      _onProfileImageChanged,
    );

    _loadProfileImage();
    _loadProfile();
    _loadWellbeingSnapshot();
  }

  Future<void> _loadProfileImage() async {
    final image = await ProfileImageService.getProfileImage();

    if (!mounted) return;

    setState(() {
      _profileImage = image;
      _isLoadingProfileImage = false;
    });

    // Make sure the shared notifier also knows about the
    // currently saved image when ProfileScreen is opened.
    if (ProfileImageService.profileImageNotifier.value?.path !=
        image?.path) {
      ProfileImageService.profileImageNotifier.value = image;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final email = prefs.getString('logged_in_email');

      if (email == null || email.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoadingProfile = false;
        });

        return;
      }

      final baseUrl = dotenv.env['API_BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoadingProfile = false;
        });

        return;
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/auth/profile?email=${Uri.encodeComponent(email)}',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];

        setState(() {
          _fullName = user['fullName'] ?? '';
          _email = user['email'] ?? '';
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _onProfileImageChanged() {
    if (!mounted) return;

    final image = ProfileImageService.profileImageNotifier.value;

    setState(() {
      _profileImage = image;
      _isLoadingProfileImage = false;
    });
  }

  // ============================================================
// WELLBEING SNAPSHOT DATA
// ============================================================

  double _moodToValue(String mood) {
    switch (mood) {
      case 'Low':
        return 2.0;
      case 'Okay':
        return 4.0;
      case 'Neutral':
        return 5.0;
      case 'Good':
        return 7.0;
      case 'Great':
        return 9.0;
      default:
        return 5.0;
    }
  }

  double _checkInScore(CheckIn checkIn) {
    final moodValue = _moodToValue(checkIn.mood);

    return (
        moodValue +
            checkIn.energyLevel +
            checkIn.sleepQuality
    ) / 3;
  }

  DateTime _dateOnly(DateTime date) {
    final local = date.toLocal();

    return DateTime(
      local.year,
      local.month,
      local.day,
    );
  }

  DateTime _startOfCurrentWeek() {
    final today = _dateOnly(DateTime.now());

    return today.subtract(
      Duration(days: today.weekday - 1),
    );
  }

  Future<void> _loadWellbeingSnapshot() async {
    try {
      final checkIns = await CheckInService.getCheckIns();

      if (!mounted) return;

      final startOfWeek = _startOfCurrentWeek();

      final currentWeekCheckIns = checkIns.where((checkIn) {
        final date = _dateOnly(checkIn.createdAt);

        return !date.isBefore(startOfWeek) &&
            date.isBefore(
              startOfWeek.add(
                const Duration(days: 7),
              ),
            );
      }).toList();

      double wellbeingScore = 0;

      if (currentWeekCheckIns.isNotEmpty) {
        final total = currentWeekCheckIns.fold<double>(
          0,
              (sum, checkIn) => sum + _checkInScore(checkIn),
        );

        wellbeingScore =
            total / currentWeekCheckIns.length;
      }

      final currentStreak =
      _calculateCurrentStreak(checkIns);

      setState(() {
        _wellbeingScore = wellbeingScore;
        _checkIns = currentWeekCheckIns.length;
        _currentStreak = currentStreak;
        _isLoadingWellbeing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _wellbeingScore = 0;
        _checkIns = 0;
        _currentStreak = 0;
        _isLoadingWellbeing = false;
      });
    }
  }

  int _calculateCurrentStreak(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return 0;
    }

    final completedDates = <DateTime>{};

    for (final checkIn in checkIns) {
      completedDates.add(
        _dateOnly(checkIn.createdAt),
      );
    }

    final today = _dateOnly(DateTime.now());

    int streak = 0;
    DateTime currentDate = today;

    // If there is no check-in today, allow the streak
    // to continue from yesterday.
    if (!completedDates.contains(currentDate)) {
      currentDate = currentDate.subtract(
        const Duration(days: 1),
      );
    }

    while (completedDates.contains(currentDate)) {
      streak++;

      currentDate = currentDate.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }

  @override
  void dispose() {
    ProfileImageService.profileImageNotifier.removeListener(
      _onProfileImageChanged,
    );

    super.dispose();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 24),

                    _buildProfileHero(),

                    const SizedBox(height: 20),

                    _buildWellbeingSnapshot(),

                    const SizedBox(height: 30),

                    _buildSectionHeader(
                      'Account',
                      'Your personal MindMate information',
                    ),

                    const SizedBox(height: 12),

                    _buildAccountCard(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'Preferences',
                      'Customize how MindMate works for you',
                    ),

                    const SizedBox(height: 12),

                    _buildPreferencesCard(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'Privacy & Safety',
                      'Manage your information and support options',
                    ),

                    const SizedBox(height: 12),

                    _buildPrivacySafetyCard(),

                    const SizedBox(height: 30),

                    _buildLogoutButton(),

                    const SizedBox(height: 24),

                    _buildFooter(),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.navy,
                size: 18,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Header text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your account and wellbeing space',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.48),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Small decorative MindMate mark
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderMint,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo1.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE HERO
  // ============================================================

  Widget _buildProfileHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF243E4D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -35,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.10),
                  width: 25,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -45,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.06),
              ),
            ),
          ),

          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingProfile
                              ? 'Loading...'
                              : (_fullName.isEmpty ? 'Your Name' : _fullName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _isLoadingProfile ? 'Loading...' : _email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.60),
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 11),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mint.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.mint.withValues(
                                    alpha: 0.20,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'MEMBER',
                                style: TextStyle(
                                  color: AppColors.mint,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              'Since 2026',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.42),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalInformationScreen(),
                        ),
                      );
                      _loadProfile();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.mint,
                    size: 17,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Your wellbeing journey is private and personal.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightMint,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 2.5,
        ),
      ),
      child: _isLoadingProfileImage
          ? const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.mint,
        ),
      )
          : _profileImage != null
          ? ClipOval(
        child: Image.file(
          _profileImage!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      )
          : const Icon(
        Icons.person_rounded,
        color: AppColors.mint,
        size: 38,
      ),
    );
  }

  // ============================================================
  // WELLBEING SNAPSHOT
  // ============================================================

  Widget _buildWellbeingSnapshot() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Wellbeing Snapshot',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Text(
                'Current',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.38),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (_isLoadingWellbeing)
            const SizedBox(
              height: 70,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.mint,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildSnapshotMetric(
                    value: _wellbeingScore.toStringAsFixed(1),
                    label: 'Wellbeing',
                    suffix: '/10',
                    icon: Icons.insights_outlined,
                  ),
                ),

                _buildMetricDivider(),

                Expanded(
                  child: _buildSnapshotMetric(
                    value: '$_currentStreak',
                    label: 'Day streak',
                    suffix: ' days',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),

                _buildMetricDivider(),

                Expanded(
                  child: _buildSnapshotMetric(
                    value: '$_checkIns',
                    label: 'Check-ins',
                    suffix: '',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSnapshotMetric({
    required String value,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.mint,
          size: 19,
        ),

        const SizedBox(height: 8),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: suffix,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.42),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.45),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.borderMint,
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
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
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.25,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.43),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
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
          icon: Icons.email_outlined,
          title: 'Email Address',
          subtitle: _isLoadingProfile
              ? 'Loading...'
              : (_email.isEmpty
              ? 'No email available'
              : _email),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmailAddressScreen(),
              ),
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.lock_outline_rounded,
          title: 'Password & Security',
          subtitle: 'Change password and account security',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PasswordSecurityScreen(),
              ),
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
          icon: Icons.visibility_off_outlined,
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
          icon: Icons.tune_rounded,
          title: 'Wellbeing Preferences',
          subtitle: 'Personalize your MindMate experience',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WellbeingPreferencesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // PRIVACY & SAFETY
  // ============================================================

  Widget _buildPrivacySafetyCard() {
    return _buildSettingsCard(
      children: [
        _buildSettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy & Data',
          subtitle: 'Review how your wellbeing information is handled',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrivacyDataScreen(),
              ),
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.shield_outlined,
          title: 'Safety & Support',
          subtitle: 'Access support options when you need them',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SafetySupportScreen(),
              ),
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQs, guidance and assistance',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HelpSupportScreen(),
              ),
            );
          },
        ),

        _buildDivider(),

        _buildSettingsTile(
          icon: Icons.info_outline_rounded,
          title: 'About MindMate',
          subtitle: 'Version 1.0.0 and application information',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AboutMindMateScreen(),
              ),
            );
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.022),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.mint,
                  size: 20,
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.42),
                        fontSize: 10,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.navy.withValues(alpha: 0.28),
                size: 13,
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
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 20,
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.42),
                    fontSize: 10,
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
            inactiveTrackColor: AppColors.navy.withValues(
              alpha: 0.14,
            ),
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
        left: 69,
        right: 16,
      ),
      child: Divider(
        height: 1,
        thickness: 0.6,
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
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(
          Icons.logout_rounded,
          size: 18,
        ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFC96F5C),
          side: const BorderSide(
            color: Color(0xFFEED8D1),
          ),
          backgroundColor: const Color(0xFFFFFAF8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
              size: 13,
            ),
            const SizedBox(width: 6),
            Text(
              'Your wellbeing information is private',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.40),
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Text(
          'MindMate • Version 1.0.0',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.25),
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRIVACY DIALOG
  // ============================================================

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Privacy & Data',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'MindMate currently uses demo data for wellbeing features. '
                'Your information is not connected to a backend yet.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.60),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mint,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
              height: 1.4,
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
              onPressed: () async {
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();

                await prefs.remove('logged_in_email');

                if (!mounted) return;

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
  // TEMPORARY MESSAGE
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