import 'dart:io';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/services/profile_image_service.dart';
import '../core/services/check_in_service.dart';
import '../models/check_in.dart';
import '../core/widgets/responsive.dart';
import 'ai_chat_screen.dart';
import 'assessments/assessments_screen.dart';
import 'check_in_screen.dart';
import 'emotion_screen.dart';
import 'exercise/calm_grounding_screen.dart';
import 'insights_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'voice_screen.dart';
import 'student_wellbeing_screen.dart';
import 'text_emotion_screen.dart';
import 'exercise/body_scan_screen.dart';
import 'exercise/thought_reset_screen.dart';
import 'exercise/exam_pressure_reset_screen.dart';
import 'exercise/sleep_wind_down_screen.dart';
import 'exercise/stress_release_screen.dart';
import 'exercise/self_compassion_pause_screen.dart';
import 'exercise/quick_reflection_screen.dart';
import 'exercise/focus_reset_screen.dart';
import 'exercise/mood_lift_screen.dart';
import 'exercise/grounding_screen.dart';
import 'exercise/box_breathing_screen.dart';
import 'exercise/digital_detox_screen.dart';
import '../core/services/student_mode_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _studentModeEnabled = true;


  @override
  void initState() {
    super.initState();

    StudentModeService.isEnabled.addListener(_onStudentModeChanged);

    ProfileImageService.initialize();

    _loadStudentMode();
  }

  Future<void> _loadStudentMode() async {
    await StudentModeService.load();

    if (!mounted) return;

    setState(() {
      _studentModeEnabled = StudentModeService.isEnabled.value;
    });
  }

  void _onStudentModeChanged() {
    if (!mounted) return;

    final enabled = StudentModeService.isEnabled.value;

    setState(() {
      if (_studentModeEnabled && !enabled) {
        if (_selectedIndex == 2) {
          _selectedIndex = 0;
        } else if (_selectedIndex > 2) {
          _selectedIndex--;
        }
      } else if (!_studentModeEnabled && enabled) {
        if (_selectedIndex >= 2) {
          _selectedIndex++;
        }
      }

      _studentModeEnabled = enabled;
    });
  }

  @override
  void dispose() {
    StudentModeService.isEnabled.removeListener(_onStudentModeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeFeed(),

            CheckInScreen(
              onBackToHome: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),

            if (_studentModeEnabled)
              StudentWellbeingScreen(
                onBackToHome: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),

            InsightsScreen(
              onBackToHome: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),

            ProfileScreen(
              onBackToHome: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.lightMint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          const NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Check-in',
          ),

          if (_studentModeEnabled)
            const NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded),
              label: 'Student',
            ),

          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),

          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME FEED
// ============================================================

class _HomeFeed extends StatefulWidget {
  const _HomeFeed();

  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  File? _profileImage;

  CheckIn? _latestCheckIn;
  List<CheckIn> _checkIns = [];
  bool _isLoadingCheckIn = true;

  @override
  void initState() {
    super.initState();

    _profileImage =
        ProfileImageService.profileImageNotifier.value;

    ProfileImageService.profileImageNotifier.addListener(
      _onProfileImageChanged,
    );

    _loadLatestCheckIn();
  }

  Future<void> _loadLatestCheckIn() async {
    try {
      final checkIns = await CheckInService.getCheckIns();

      if (!mounted) return;

      setState(() {
        _checkIns = checkIns;
        _latestCheckIn =
        checkIns.isNotEmpty ? checkIns.first : null;
        _isLoadingCheckIn = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _checkIns = [];
        _latestCheckIn = null;
        _isLoadingCheckIn = false;
      });
    }
  }

  int _calculateStreak() {
    if (_checkIns.isEmpty) {
      return 0;
    }

    final dates = _checkIns
        .map(
          (checkIn) => DateTime(
        checkIn.createdAt.year,
        checkIn.createdAt.month,
        checkIn.createdAt.day,
      ),
    )
        .toSet();

    final today = DateTime.now();
    final todayDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    DateTime startDate = todayDate;

    // If there is no check-in today, allow the streak
    // to continue from yesterday.
    if (!dates.contains(todayDate)) {
      final yesterday = todayDate.subtract(
        const Duration(days: 1),
      );

      if (!dates.contains(yesterday)) {
        return 0;
      }

      startDate = yesterday;
    }

    int streak = 0;

    for (int i = 0; ; i++) {
      final day = startDate.subtract(
        Duration(days: i),
      );

      if (dates.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  double _latestPulseScore() {
    final checkIn = _latestCheckIn;

    if (checkIn == null) {
      return 0;
    }

    final moodValue = {
      'Low': 2,
      'Okay': 4,
      'Neutral': 5,
      'Good': 7,
      'Great': 9,
    }[checkIn.mood] ?? 5;

    final average =
        (moodValue + checkIn.energyLevel + checkIn.sleepQuality) / 3;

    return average.clamp(0.0, 10.0);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _onProfileImageChanged() {
    if (!mounted) return;

    setState(() {
      _profileImage =
          ProfileImageService.profileImageNotifier.value;
    });
  }

  @override
  void dispose() {
    ProfileImageService.profileImageNotifier.removeListener(
      _onProfileImageChanged,
    );

    super.dispose();
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: Responsive.contentMaxWidth(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context),

                  const SizedBox(height: 25),

                  _buildGreeting(),

                  const SizedBox(height: 20),

                  _buildDailyPulse(context),

                  const SizedBox(height: 27),

                  _buildQuickOrbit(context),

                  const SizedBox(height: 30),

                  _buildExerciseSection(context),

                  const SizedBox(height: 30),

                  _buildPrivacyNote(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Image.asset(
            'assets/images/logo1.png',
            width: 52,
            height: 42,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
        ),

        _profileButton(
          onTap: () {
            _open(
              context,
              const ProfileScreen(),
            );
          },
        ),
      ],
    );
  }



  Widget _profileButton({
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: AppColors.lightMint,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderMint,
          ),
        ),
        child: _profileImage != null
            ? ClipOval(
          child: Image.file(
            _profileImage!,
            width: 43,
            height: 43,
            fit: BoxFit.cover,
          ),
        )
            : const Icon(
          Icons.person_outline_rounded,
          color: AppColors.navy,
          size: 22,
        ),
      ),
    );
  }

  // ==========================================================
  // GREETING
  // ==========================================================

  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good evening, 👋',
          style: TextStyle(
            color: Color(0x991D2B3A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 5),

        Text(
          'Your mind deserves a moment.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.12,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DAILY PULSE
  // ==========================================================

  Widget _buildDailyPulse(BuildContext context) {
    final checkIn = _latestCheckIn;

    final pulseScore = _latestPulseScore();
    final pulseValue = (pulseScore / 10).clamp(0.0, 1.0);
    final pulseNumber = pulseScore.round();

    final energy = checkIn != null
        ? '${checkIn.energyLevel}/10'
        : '--';

    final streak = _calculateStreak();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF29495A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -55,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.13),
                  width: 24,
                ),
              ),
            ),
          ),

          Positioned(
            left: -35,
            bottom: -55,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.035),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.mint,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'DAILY PULSE',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    checkIn == null
                        ? 'NO DATA'
                        : _isToday(checkIn.createdAt)
                        ? 'TODAY'
                        : 'LATEST',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: _isLoadingCheckIn ? 0 : pulseValue,
                            strokeWidth: 7,
                            backgroundColor:
                            Colors.white.withValues(alpha: 0.1),
                            valueColor:
                            const AlwaysStoppedAnimation<Color>(
                              AppColors.mint,
                            ),
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isLoadingCheckIn
                                  ? '--'
                                  : _latestCheckIn == null
                                  ? '--'
                                  : '$pulseNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'pulse',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkIn == null
                              ? 'Your wellbeing snapshot starts with a check-in.'
                              : 'Your latest wellbeing snapshot is ready.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 7),

                        Text(
                          checkIn == null
                              ? 'Complete your first check-in to start tracking your wellbeing.'
                              : 'Keep checking in gently to build a clearer picture over time.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 10.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 19),

              Row(
                children: [
                  Expanded(
                    child: _darkMetric(
                      'MOOD',
                      checkIn?.mood ?? '--',
                      Icons.mood_rounded,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _darkMetric(
                      'ENERGY',
                      energy,
                      Icons.bolt_rounded,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _darkMetric(
                      'STREAK',
                      streak == 0
                          ? '--'
                          : '$streak ${streak == 1 ? 'day' : 'days'}',
                      Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: () {
                    _open(
                      context,
                      CheckInScreen(
                        onBackToHome: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.favorite_outline_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Check in with yourself',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _darkMetric(
      String label,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 15,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 6.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


// ==========================================================
// MENTAL TOOLKIT
// ==========================================================

  Widget _buildQuickOrbit(BuildContext context) {
    final tools = [
      (
      'Mood',
      'Record a feeling',
      Icons.mood_outlined,
      const Color(0xFFE29A45),
      const Color(0xFFFFF5E9),
          () => _open(context, const MoodScreen()),
      ),
      (
      'Emotion',
      'Scan expression',
      Icons.face_retouching_natural_outlined,
      const Color(0xFFAD76B5),
      const Color(0xFFF8EFF9),
          () => _open(context, const EmotionScreen()),
      ),
      (
      'Voice',
      'Explore your voice',
      Icons.mic_none_rounded,
      const Color(0xFF6D9A72),
      const Color(0xFFEEF7EF),
          () => _open(context, const VoiceScreen()),
      ),
      (
      'Assessment',
      'Reflect deeper',
      Icons.psychology_outlined,
      const Color(0xFF6B7FD7),
      const Color(0xFFF1F3FC),
          () => _open(context, const AssessmentsScreen()),
      ),
      (
      'Progress',
      'See patterns',
      Icons.insights_outlined,
      const Color(0xFF5C8FA8),
      const Color(0xFFEDF5F8),
          () => _open(context, const ProgressScreen()),
      ),
      (
      'Text Emotion',
      'Analyze your words',
      Icons.text_fields_rounded,
      AppColors.navy,
      const Color(0xFFEFF7F3),
          () => _open(context, const TextEmotionScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION HEADING
        const Text(
          'Your mental toolkit',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Choose the kind of support you need right now.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.55),
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 14),

        // COMPACT FEATURED AI CHAT CARD
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(context, const AiChatScreen()),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // SUPPORT-AGENT ICON
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.borderMint,
                      ),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.navy,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // AI CHAT TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'AI COMPANION',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),

                        const SizedBox(height: 3),

                        const Text(
                          'AI Chat',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Talk it out, one moment at a time.',
                          style: TextStyle(
                            color: AppColors.navy.withValues(
                              alpha: 0.65,
                            ),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // SUBTLE ARROW
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // TWO ROWS OF THREE TOOL CARDS

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = width < 430
                ? 2
                : width < 850
                ? 3
                : 4;

            final aspectRatio = width < 430
                ? 1.05
                : width < 850
                ? 1.0
                : 1.15;

            return GridView.builder(
              itemCount: tools.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = tools[index];

                return _toolTile(
                  title: item.$1,
                  subtitle: item.$2,
                  icon: item.$3,
                  iconColor: item.$4,
                  background: item.$5,
                  onTap: item.$6,
                );
              },
            );
          },
        ),
      ],
    );
  }


  Widget _toolTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.borderMint,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.45),
                  fontSize: 8.2,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // EXERCISES
  // ==========================================================
  Widget _miniInfo(
      IconData icon,
      String text,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.mint,
          size: 13,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
  // ==========================================================
  // EXERCISES
  // ==========================================================

  Widget _buildExerciseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // TITLE
        // ------------------------------------------------------

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MindMate Reset',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Guided tools for the moment you are in.',
                    style: TextStyle(
                      color: Color(0x851D2B3A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.mint,
                    size: 12,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '12 TOOLS',
                    style: TextStyle(
                      color: AppColors.mint,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // FEATURED EXERCISE
        // ------------------------------------------------------

        GestureDetector(
          onTap: () {
            _open(
              context,
              const CalmGroundingScreen(),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0F8F4),
                  Color(0xFFE4F2EA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.borderMint,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -25,
                  top: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mint.withValues(alpha: 0.055),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🌿',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Text(
                                  'FEATURED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.mint,
                                size: 13,
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            '60-Second Calm Reset',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Breathe, ground yourself, '
                                'and reset after a difficult moment.',
                            style: TextStyle(
                              color: Color(0x8A1D2B3A),
                              fontSize: 10.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              _miniInfo(
                                Icons.timer_outlined,
                                '1 min',
                              ),
                              const SizedBox(width: 10),
                              _miniInfo(
                                Icons.self_improvement_outlined,
                                'Guided',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.navy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ------------------------------------------------------
        // LIBRARY HEADER
        // ------------------------------------------------------

        Row(
          children: [
            const Text(
              'EXPLORE',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.borderMint,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '12 guided exercises',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.38),
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 11),

        // ------------------------------------------------------
        // 4-COLUMN EXERCISE GRID
        // ------------------------------------------------------

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: 0.93,
          children: [
            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const BodyScanScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '🧘',
                title: 'Body Scan',
                subtitle: 'Notice physical tension',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const ThoughtResetScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '💭',
                title: 'Thought Reset',
                subtitle: 'Challenge thoughts',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const ExamPressureResetScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '📚',
                title: 'Exam Pressure',
                subtitle: 'Reduce study stress',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const SleepWindDownScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '🌙',
                title: 'Sleep Wind-Down',
                subtitle: 'Prepare to rest',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const StressReleaseScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '⚡',
                title: 'Stress Release',
                subtitle: 'Release tension',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const SelfCompassionPauseScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '💚',
                title: 'Self-Compassion',
                subtitle: 'Be kind to yourself',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const QuickReflectionScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '✍️',
                title: 'Quick Reflection',
                subtitle: 'Pause and notice',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const FocusResetScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '🎯',
                title: 'Focus Reset',
                subtitle: 'Regain attention',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const MoodLiftScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '🌤️',
                title: 'Mood Lift',
                subtitle: 'Shift your mood',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const GroundingScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '🌿',
                title: 'Grounding',
                subtitle: 'Reconnect now',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const BoxBreathingScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '🌬️',
                title: 'Box Breathing',
                subtitle: 'Breathe with rhythm',
              ),
            ),

            GestureDetector(
              onTap: () {
                _open(
                  context,
                  const DigitalDetoxScreen(),
                );
              },
              child: _exerciseMiniCard(
                emoji: '📵',
                title: 'Digital Detox',
                subtitle: 'Take a screen break',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // MINIMIZED EXERCISE CARD
  // ==========================================================

  Widget _exerciseMiniCard({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.45),
              fontSize: 8.2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PRIVACY
  // ==========================================================

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.45),
            size: 17,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Your wellbeing information is handled with care. MindMate provides supportive self-reflection tools, AI-powered features and wellbeing insights to help you better understand your patterns.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.48),
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}