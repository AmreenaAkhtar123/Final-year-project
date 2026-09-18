import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'profile_screen.dart';
import 'check_in_screen.dart';
import 'insights_screen.dart';
import 'notifications_screen.dart';
import 'ai_chat_screen.dart';
import 'assessments/assessments_screen.dart';
import 'mood_screen.dart';
import 'progress_screen.dart';
import 'voice_screen.dart';
import 'emotion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Home',
    'Check-in',
    'Insights',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),

            const CheckInScreen(),

            const InsightsScreen(),

            const ProfileScreen(),
          ],
        ),
      ),

      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHome() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 28),

                _buildGreeting(),

                const SizedBox(height: 22),

                _buildWellbeingCard(),

                const SizedBox(height: 28),

                _buildSectionHeader(
                  title: 'Your MindMate tools',
                  subtitle: 'Support for your everyday wellbeing',
                ),

                const SizedBox(height: 15),

                _buildFeatureGrid(),

                const SizedBox(height: 28),

                _buildStudentWellbeingCard(),

                const SizedBox(height: 28),

                _buildSectionHeader(
                  title: 'Your progress',
                  subtitle: 'A quick look at your recent wellbeing',
                ),

                const SizedBox(height: 15),

                _buildProgressCard(),

                const SizedBox(height: 28),

                _buildSafetyCard(),

                const SizedBox(height: 24),

                _buildPrivacyNote(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        // =========================================================
        // MINDMATE LOGO
        // =========================================================

        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo1.png',
              width: 50,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // =========================================================
        // NOTIFICATION
        // =========================================================


        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.navy,
                    size: 23,
                  ),
                ),

                Positioned(
                  top: 9,
                  right: 9,
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
        ),

        const SizedBox(width: 10),

        // =========================================================
        // PROFILE
        // =========================================================

        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 3;
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.navy,
              size: 23,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good evening, 👋',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.60),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'How are you feeling today?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELLBEING CARD
  // ============================================================

  Widget _buildWellbeingCard() {
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
            color: AppColors.navy.withValues(alpha: 0.16),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.10),
              ),
            ),
          ),

          Positioned(
            right: 15,
            bottom: -70,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 20,
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
                      horizontal: 11,
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
                        SizedBox(width: 6),
                        Text(
                          'WELLBEING SNAPSHOT',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildScoreCircle(),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You’re doing well',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Your recent check-ins show a positive pattern.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.mint,
                              size: 17,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '8% better this week',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 47,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckInScreen(),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline_rounded,
                        size: 19,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Start today’s check-in',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle() {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(
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
                'score',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.52),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FEATURE GRID
  // ============================================================

  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        _buildFeatureCard(
          icon: Icons.smart_toy_outlined,
          title: 'AI Chat',
          subtitle: 'Talk anytime',
          iconColor: AppColors.mint,
          background: AppColors.lightMint,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AiChatScreen(),
              ),
            );
          },
        ),

        _buildFeatureCard(
          icon: Icons.psychology_outlined,
          title: 'Assessment',
          subtitle: 'Check your wellbeing',
          iconColor: const Color(0xFF6B7FD7),
          background: const Color(0xFFF1F3FC),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AssessmentsScreen(),
              ),
            );
          },
        ),

        _buildFeatureCard(
          icon: Icons.mood_outlined,
          title: 'Mood',
          subtitle: 'Track how you feel',
          iconColor: const Color(0xFFE29A45),
          background: const Color(0xFFFFF5E9),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MoodScreen(),
              ),
            );
          },
        ),

        _buildFeatureCard(
          icon: Icons.insights_outlined,
          title: 'Progress',
          subtitle: 'View your reports',
          iconColor: const Color(0xFF5C8FA8),
          background: const Color(0xFFEDF5F8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProgressScreen(),
              ),
            );
          },
        ),

        _buildFeatureCard(
          icon: Icons.face_retouching_natural_outlined,
          title: 'Emotion',
          subtitle: 'Facial emotion scan',
          iconColor: const Color(0xFFAD76B5),
          background: const Color(0xFFF8EFF9),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmotionScreen(),
              ),
            );
          },
        ),

        _buildFeatureCard(
          icon: Icons.mic_none_rounded,
          title: 'Voice',
          subtitle: 'Voice emotion analysis',
          iconColor: const Color(0xFF6D9A72),
          background: const Color(0xFFEEF7EF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VoiceScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
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
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderMint.withValues(alpha: 0.75),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.035),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.48),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STUDENT WELLBEING
  // ============================================================

  Widget _buildStudentWellbeingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.mint,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'STUDENT WELLBEING',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: AppColors.mint,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  'Feeling overwhelmed with studies?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Check your stress, exam pressure and burnout level.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.53),
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          IconButton(
            onPressed: () {
              _showMessage(
                'Student stress and burnout assessment will open here.',
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.navy,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.mint,
                size: 21,
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'Weekly wellbeing',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                'This week',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniBar('M', 0.52),
              _buildMiniBar('T', 0.68),
              _buildMiniBar('W', 0.45),
              _buildMiniBar('T', 0.78),
              _buildMiniBar('F', 0.72),
              _buildMiniBar('S', 0.86),
              _buildMiniBar('S', 0.72, active: true),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.mint,
                  size: 16,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Your mood has been more consistent this week.',
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.72),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBar(
      String day,
      double value, {
        bool active = false,
      }) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 75,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            heightFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: active
                    ? AppColors.mint
                    : AppColors.mint.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          day,
          style: TextStyle(
            color: active
                ? AppColors.navy
                : AppColors.navy.withValues(alpha: 0.45),
            fontSize: 9,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAFETY
  // ============================================================

  Widget _buildSafetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF4DDD5),
        ),
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

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need support right now?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Access crisis support and emergency resources.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.52),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _showMessage(
                'Crisis detection and emergency support will open here.',
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFFD67A65),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  Widget _buildPrivacyNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: AppColors.navy.withValues(alpha: 0.38),
        ),

        const SizedBox(width: 6),

        Text(
          'Your wellbeing data is private and protected',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.42),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildNavigationBar() {
    return NavigationBar(
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
    );
  }
  // ============================================================
  // PLACEHOLDER
  // ============================================================

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: AppColors.mint,
                size: 38,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.55),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
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