import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutMindMateScreen extends StatelessWidget {
  const AboutMindMateScreen({super.key});

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
          'About MindMate',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
        children: [
          // -----------------------------------------------------------------
          // ORIGINAL MINDMATE CARD
          // -----------------------------------------------------------------

          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.navy,
                  Color(0xFF294253),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'MindMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your wellbeing companion',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 11,
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
                  ),
                  child: const Text(
                    'VERSION 1.0.0',
                    style: TextStyle(
                      color: AppColors.mint,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // -----------------------------------------------------------------
          // ABOUT MINDMATE
          // -----------------------------------------------------------------

          _buildSectionLabel('ABOUT MINDMATE'),

          const SizedBox(height: 12),

          _buildTextCard(
            title: 'A space to check in with yourself',
            text:
            'MindMate is a wellbeing companion designed to help students '
                'make time for their mental and emotional wellbeing in the '
                'middle of everyday life.',
          ),

          const SizedBox(height: 12),

          _buildTextCard(
            title: 'Built for everyday moments',
            text:
            'Whether you need a quick reset, want to reflect on how '
                'you are feeling, or simply want to understand your '
                'wellbeing better, MindMate brings practical tools into '
                'one simple experience.',
          ),

          const SizedBox(height: 30),

          // -----------------------------------------------------------------
          // WHAT MINDMATE OFFERS
          // -----------------------------------------------------------------

          _buildSectionLabel('WHAT MINDMATE OFFERS'),

          const SizedBox(height: 12),

          _buildFeatureList(),

          const SizedBox(height: 30),

          // -----------------------------------------------------------------
          // HOW IT WORKS
          // -----------------------------------------------------------------

          _buildSectionLabel('HOW IT WORKS'),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Column(
              children: [
                _buildStep(
                  number: '01',
                  title: 'Check in',
                  text:
                  'Take a moment to reflect on your current mood and '
                      'how you are feeling.',
                ),
                _buildStepDivider(),
                _buildStep(
                  number: '02',
                  title: 'Explore',
                  text:
                  'Choose tools, activities or exercises that match '
                      'what you need in the moment.',
                ),
                _buildStepDivider(),
                _buildStep(
                  number: '03',
                  title: 'Reflect',
                  text:
                  'Use your check-ins and insights to notice patterns '
                      'in your wellbeing over time.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // -----------------------------------------------------------------
          // DESIGNED FOR STUDENTS
          // -----------------------------------------------------------------

          _buildSectionLabel('DESIGNED FOR STUDENTS'),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: AppColors.mint,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support that fits student life',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        'MindMate is designed around common moments in student '
                            'life, including stress, study pressure, emotional '
                            'overload, difficulty focusing and the need for a '
                            'short break.',
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.58),
                          fontSize: 10.5,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // -----------------------------------------------------------------
          // IMPORTANT NOTE
          // -----------------------------------------------------------------

          _buildSectionLabel('IMPORTANT NOTE'),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.mint,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    'MindMate is a wellbeing support application and does '
                        'not replace professional medical or psychological care. '
                        'If you need professional help, consider reaching out '
                        'to a qualified mental health professional or an '
                        'appropriate support service.',
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.58),
                      fontSize: 10.5,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 34),

          // -----------------------------------------------------------------
          // FOOTER
          // -----------------------------------------------------------------

          _buildFooter(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION LABEL
  // ---------------------------------------------------------------------------

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.48),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT CARD
  // ---------------------------------------------------------------------------

  Widget _buildTextCard({
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.58),
              fontSize: 10.8,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURE LIST
  // ---------------------------------------------------------------------------

  Widget _buildFeatureList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          _buildFeatureRow(
            icon: Icons.favorite_border_rounded,
            title: 'Wellbeing check-ins',
            text:
            'Record how you are feeling and build awareness of your '
                'day-to-day wellbeing.',
          ),

          _buildFeatureDivider(),

          _buildFeatureRow(
            icon: Icons.spa_outlined,
            title: 'Guided exercises',
            text:
            'Use short exercises for grounding, breathing, reflection, '
                'focus, stress and relaxation.',
          ),

          _buildFeatureDivider(),

          _buildFeatureRow(
            icon: Icons.psychology_outlined,
            title: 'Personal insights',
            text:
            'Review your wellbeing patterns and see how your experiences '
                'change over time.',
          ),

          _buildFeatureDivider(),

          _buildFeatureRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'AI companion',
            text:
            'Have a supportive conversation and explore your thoughts '
                'in a private space.',
          ),

          _buildFeatureDivider(),

          _buildFeatureRow(
            icon: Icons.support_outlined,
            title: 'Support resources',
            text:
            'Access guidance and support information when you feel you '
                'need additional help.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
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

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  text,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.54),
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 73),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.borderMint,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HOW IT WORKS
  // ---------------------------------------------------------------------------

  Widget _buildStep({
    required String number,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.mint,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
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
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                text,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.54),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        top: 14,
        bottom: 14,
      ),
      child: Container(
        width: 1,
        height: 18,
        color: AppColors.borderMint,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOOTER
  // ---------------------------------------------------------------------------

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 42,
          height: 1,
          color: AppColors.borderMint,
        ),

        const SizedBox(height: 16),

        const Text(
          'MindMate',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Your wellbeing companion',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.40),
            fontSize: 9.5,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Version 1.0.0',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.25),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}