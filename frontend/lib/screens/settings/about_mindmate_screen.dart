
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutMindMateScreen extends StatelessWidget {
  const AboutMindMateScreen({super.key});

  static const Color _muted = Color(0xFF71808A);
  static const Color _softBackground = Color(0xFFF3F8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildAppBar(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildBrandHeader(),

                  const SizedBox(height: 38),

                  _buildSectionHeading(
                    eyebrow: 'OUR PURPOSE',
                    title: 'A little more support, every day.',
                  ),

                  const SizedBox(height: 14),

                  _buildIntroduction(),

                  const SizedBox(height: 36),

                  _buildSectionHeading(
                    eyebrow: 'THE EXPERIENCE',
                    title: 'Everything in one place.',
                    subtitle:
                    'Tools designed to help you understand, reflect '
                        'and take small steps towards better wellbeing.',
                  ),

                  const SizedBox(height: 20),

                  _buildFeatures(),

                  const SizedBox(height: 38),

                  _buildSectionHeading(
                    eyebrow: 'YOUR JOURNEY',
                    title: 'Three simple steps.',
                  ),

                  const SizedBox(height: 20),

                  _buildJourney(),

                  const SizedBox(height: 36),

                  _buildStudentSection(),

                  const SizedBox(height: 34),

                  _buildDisclaimer(),

                  const SizedBox(height: 34),

                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // APP BAR

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 22, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderMint),
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

          const Text(
            'About MindMate',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  // BRAND HEADER

  Widget _buildBrandHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -42,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 24,
                ),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -55,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.10),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Image.asset(
                      'assets/images/logo1.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MindMate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your wellbeing companion',
                          style: TextStyle(
                            color: Color(0xFFD1DED9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 27),

              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Understand yourself.\nTake care of your wellbeing.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'A supportive space for self-reflection, emotional '
                    'awareness and healthier everyday habits.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION HEADING

  Widget _buildSectionHeading({
    required String eyebrow,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.mint,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.65,
            height: 1.25,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.65,
            ),
          ),
        ],
      ],
    );
  }

  // INTRODUCTION

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MindMate is a mental wellbeing application designed to help '
              'students understand their emotions, reflect on their experiences '
              'and develop healthier everyday habits.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            height: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 15),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'From daily check-ins to guided activities and personal '
                    'insights, MindMate brings useful wellbeing tools together '
                    'in one accessible experience.',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.62),
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // FEATURES

  Widget _buildFeatures() {
    final features = [
      (
      Icons.favorite_outline_rounded,
      'Mood check-ins',
      'Reflect on your feelings and record your mood.',
      ),
      (
      Icons.psychology_outlined,
      'Emotion recognition',
      'Explore emotions through text, voice and facial input.',
      ),
      (
      Icons.chat_bubble_outline_rounded,
      'AI Chat',
      'Explore your thoughts through supportive conversations.',
      ),
      (
      Icons.assignment_outlined,
      'Assessments',
      'Complete structured wellbeing assessments.',
      ),
      (
      Icons.spa_outlined,
      'Guided exercises',
      'Try breathing, grounding and relaxation activities.',
      ),
      (
      Icons.insights_outlined,
      'Insights and progress',
      'Review your wellbeing activity over time.',
      ),
      (
      Icons.notifications_none_rounded,
      'Reminders',
      'Set reminders for check-ins and wellbeing activities.',
      ),
      (
      Icons.school_outlined,
      'Student Wellbeing',
      'Access student-focused tools when Student Mode is enabled.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _softBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Column(
        children: [
          for (int i = 0; i < features.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      features[i].$1,
                      color: AppColors.mint,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          features[i].$2,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          features[i].$3,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (i != features.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 71, right: 15),
                child: Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.borderMint.withValues(alpha: 0.8),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // HOW IT WORKS

  Widget _buildJourney() {
    final steps = [
      (
      '01',
      Icons.favorite_outline_rounded,
      'Check in',
      'Take a moment to reflect on your mood and feelings.',
      ),
      (
      '02',
      Icons.explore_outlined,
      'Explore',
      'Discover exercises, assessments and tools that suit your needs.',
      ),
      (
      '03',
      Icons.insights_outlined,
      'Reflect',
      'Use your activity and insights to understand your experiences.',
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.lightMint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderMint),
                      ),
                      child: Icon(
                        steps[i].$2,
                        color: AppColors.mint,
                        size: 21,
                      ),
                    ),

                    if (i != steps.length - 1)
                      Container(
                        width: 1.5,
                        height: 30,
                        color: AppColors.borderMint,
                      ),
                  ],
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${steps[i].$1}  ${steps[i].$3}',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          steps[i].$4,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11.5,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // STUDENT WELLBEING

  Widget _buildStudentSection() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
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

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Made with student life in mind',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'MindMate includes student-focused wellbeing support '
                      'for experiences such as academic pressure, stress, '
                      'difficulty focusing and emotional overload.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    height: 1.65,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Student Mode is available in Wellbeing Preferences.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
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

  // IMPORTANT INFORMATION

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 21,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A helpful reminder',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'MindMate supports self-reflection and everyday '
                      'wellbeing. Emotion recognition and assessment results '
                      'are not medical diagnoses and do not replace '
                      'professional medical or psychological care. '
                      'Consider contacting a qualified health professional '
                      'when you need additional support.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FOOTER

  Widget _buildFooter() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo1.png',
          width: 38,
          height: 32,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 9),

        const Text(
          'MindMate',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Your wellbeing companion',
          style: TextStyle(
            color: _muted,
            fontSize: 10.5,
          ),
        ),

        const SizedBox(height: 13),

        Container(
          width: 28,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(5),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Version 1.0.0',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
