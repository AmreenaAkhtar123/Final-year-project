import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'ai_chat_screen.dart';
import 'assessments/assessments_screen.dart';
import 'check_in_screen.dart';
import 'emotion_screen.dart';
import 'exercise/calm_grounding_screen.dart';
import 'insights_screen.dart';
import 'mood_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'safety_support_screen.dart';
import 'student_wellbeing_screen.dart';
import 'voice_screen.dart';
import 'weekly_wellbeing_screen.dart';
import 'exercise/body_scan_screen.dart';
import 'exercise/thought_reset_screen.dart';
import 'exercise/exam_pressure_reset_screen.dart';
import 'exercise/sleep_wind_down_screen.dart';
import 'exercise/stress_release_screen.dart';
import 'exercise/self_compassion_pause_screen.dart';
import 'exercise/quick_reflection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _HomeFeed(),
            CheckInScreen(),
            InsightsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.lightMint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed();

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(context),
              const SizedBox(height: 25),
              _buildGreeting(),
              const SizedBox(height: 18),
              _buildDailyPulse(context),
              const SizedBox(height: 24),
              _buildQuickOrbit(context),
              const SizedBox(height: 28),
              _buildExerciseSection(context),
              const SizedBox(height: 28),
              _buildStudentFocus(context),
              const SizedBox(height: 28),
              _buildWeeklyProgress(context),
              const SizedBox(height: 28),
              _buildSupportCard(context),
              const SizedBox(height: 22),
              _buildPrivacyNote(),
            ]),
          ),
        ),
      ],
    );
  }

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
        _circleButton(
          icon: Icons.notifications_none_rounded,
          badge: true,
          onTap: () => _open(context, const NotificationsScreen()),
        ),
        const SizedBox(width: 9),
        _profileButton(
          onTap: () => _open(context, const ProfileScreen()),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderMint),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(icon, color: AppColors.navy, size: 22),
            ),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _profileButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: AppColors.lightMint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderMint),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: AppColors.navy,
          size: 22,
        ),
      ),
    );
  }

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

  // A distinctive home hero: not a generic score card, but a "Daily Pulse"
  // that connects check-in, reflection and progress in one place.
  Widget _buildDailyPulse(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF29495A)],
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
                    'TODAY',
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
                            value: 0.72,
                            strokeWidth: 7,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.mint,
                            ),
                          ),
                        ),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '72',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'A little check-in can change the whole day.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Your latest wellbeing snapshot is ready. Keep the streak going gently.',
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
                    child: _darkMetric('MOOD', 'Calm', Icons.mood_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _darkMetric('ENERGY', '7/10', Icons.bolt_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _darkMetric('STREAK', '6 days', Icons.local_fire_department_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: () => _open(context, const CheckInScreen()),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.favorite_outline_rounded, size: 18),
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

  Widget _darkMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mint, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildQuickOrbit(BuildContext context) {
    final tools = [
      ('AI Chat', 'Talk it out', Icons.smart_toy_outlined, AppColors.mint,
      const Color(0xFFEFF7F3), () => _open(context, const AiChatScreen())),
      ('Mood', 'Record a feeling', Icons.mood_outlined, const Color(0xFFE29A45),
      const Color(0xFFFFF5E9), () => _open(context, const MoodScreen())),
      ('Emotion', 'Scan expression', Icons.face_retouching_natural_outlined,
      const Color(0xFFAD76B5), const Color(0xFFF8EFF9),
          () => _open(context, const EmotionScreen())),
      ('Voice', 'Explore your voice', Icons.mic_none_rounded,
      const Color(0xFF6D9A72), const Color(0xFFEEF7EF),
          () => _open(context, const VoiceScreen())),
      ('Assessment', 'Reflect deeper', Icons.psychology_outlined,
      const Color(0xFF6B7FD7), const Color(0xFFF1F3FC),
          () => _open(context, const AssessmentsScreen())),
      ('Progress', 'See patterns', Icons.insights_outlined,
      const Color(0xFF5C8FA8), const Color(0xFFEDF5F8),
          () => _open(context, const ProgressScreen())),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: AppColors.navy.withValues(alpha: 0.52),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          itemCount: tools.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 0.93,
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
        ),
      ],
    );
  }

  Widget _toolTile({
    required String title,
    required String subtitle,
    required IconData icon,
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
            border: Border.all(color: AppColors.borderMint),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.45),
                  fontSize: 8.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------
        // SECTION HEADER
        // --------------------------------------------------------
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MindMate Reset',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Small guided exercises for the moment you are in.',
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
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '12 EXERCISES',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // --------------------------------------------------------
        // FEATURED WORKING EXERCISE
        // --------------------------------------------------------
        GestureDetector(
          onTap: () => _open(
            context,
            const CalmGroundingScreen(),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0F8F4),
                  Color(0xFFE5F2EC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.borderMint,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Exercise icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mint.withValues(alpha: 0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🌿',
                      style: TextStyle(
                        fontSize: 29,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // Information
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'QUICK RESET',
                            style: TextStyle(
                              color: AppColors.mint,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 7),
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.mint,
                            size: 12,
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      Text(
                        '60-Second Calm Reset',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Breathe, ground yourself, and reset after a difficult moment.',
                        style: TextStyle(
                          color: Color(0x8A1D2B3A),
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 9),

                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: AppColors.mint,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'About 1 minute',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.self_improvement_outlined,
                            color: AppColors.mint,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Guided',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.navy,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // --------------------------------------------------------
        // EXPLORE EXERCISES
        // --------------------------------------------------------
        Row(
          children: [
            const Text(
              'EXPLORE EXERCISES',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
            const Spacer(),
            Text(
              '12 more',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.38),
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // --------------------------------------------------------
        // EXERCISE LIBRARY
        // --------------------------------------------------------
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: 1.72,
          children: [
            GestureDetector(
              onTap: () => _open(
                context,
                const BodyScanScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '🧘',
                title: 'Body Scan',
                subtitle: 'Notice physical tension',
              ),
            ),

            GestureDetector(
              onTap: () => _open(
                context,
                const ThoughtResetScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '💭',
                title: 'Thought Reset',
                subtitle: 'Challenge unhelpful thoughts',
              ),
            ),

            GestureDetector(
              onTap: () => _open(
                context,
                const ExamPressureResetScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '📚',
                title: 'Exam Pressure Reset',
                subtitle: 'Student stress support',
              ),
            ),

            GestureDetector(
              onTap: () => _open(
                context,
                const StressReleaseScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '⚡',
                title: 'Stress Release',
                subtitle: 'Release built-up tension',
              ),
            ),

            GestureDetector(
              onTap: () => _open(
                context,
                const SleepWindDownScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '🌙',
                title: 'Sleep Wind-Down',
                subtitle: 'Prepare for sleep',
              ),
            ),

            GestureDetector(
              onTap: () => _open(
                context,
                const SelfCompassionPauseScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '💚',
                title: 'Self-Compassion Pause',
                subtitle: 'Practice kinder self-talk',
              ),
            ),

            GestureDetector(
              onTap: () => _open(
                context,
                const QuickReflectionScreen(),
              ),
              child: _exerciseMiniCard(
                emoji: '✍️',
                title: 'Quick Reflection',
                subtitle: 'Understand what you feel',
              ),
            ),

            _exerciseMiniCard(
              emoji: '🎯',
              title: 'Focus Reset',
              subtitle: 'Regain concentration',
            ),
            _exerciseMiniCard(
              emoji: '🌤️',
              title: 'Mood Lift',
              subtitle: 'Try a positive action',
            ),
            _exerciseMiniCard(
              emoji: '👀',
              title: '5-4-3-2-1 Grounding',
              subtitle: 'Return to the present',
            ),
            _exerciseMiniCard(
              emoji: '🫁',
              title: 'Box Breathing',
              subtitle: 'Slow breathing and reset',
            ),
            _exerciseMiniCard(
              emoji: '📵',
              title: 'Digital Detox',
              subtitle: 'Pause screens and recharge',
            ),
          ],
        ),
      ],
    );
  }

  Widget _exerciseMiniCard({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          // Text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.42),
                    fontSize: 7.8,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Coming soon indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'SOON',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.35),
                fontSize: 6,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentFocus(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(
        context,
        const StudentWellbeingScreen(),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF1FBF6),
              Color(0xFFE7F6EF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.borderMint,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              bottom: -35,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mint.withValues(alpha: 0.055),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(17),
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
                  child: const Center(
                    child: Text(
                      '🎓',
                      style: TextStyle(fontSize: 27),
                    ),
                  ),
                ),

                const SizedBox(width: 13),

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
                              color: AppColors.mint.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'STUDENT MODE',
                              style: TextStyle(
                                color: AppColors.mint,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 6.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'How is student life feeling?',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Explore stress, exam pressure, burnout, sleep and motivation.',
                        style: TextStyle(
                          color: Color(0x871D2B3A),
                          fontSize: 9.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context) {
    const values = [0.52, 0.68, 0.45, 0.78, 0.72, 0.86, 0.72];
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GestureDetector(
      onTap: () => _open(context, const WeeklyWellbeingScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderMint),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.mint,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your week at a glance',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Small patterns become clearer over time.',
                        style: TextStyle(
                          color: Color(0x781D2B3A),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.navy,
                  size: 13,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(values.length, (index) {
                  final active = index == 5;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 22,
                        height: 70,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: values[index],
                          child: Container(
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.mint
                                  : AppColors.mint.withValues(alpha: 0.48),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[index],
                        style: TextStyle(
                          color: active
                              ? AppColors.navy
                              : AppColors.navy.withValues(alpha: 0.42),
                          fontSize: 8,
                          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.mint, size: 15),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Your strongest day was Saturday. Tap to explore the full week.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context, const SafetySupportScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF4DDD5)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9E3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Color(0xFFD67A65),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need support right now?',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find safety guidance, trusted-person support and professional-support information.',
                    style: TextStyle(
                      color: Color(0x851D2B3A),
                      fontSize: 9.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.navy,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.45),
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MindMate is designed around private, supportive self-reflection. AI and risk-analysis features will be connected in later development increments.',
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
