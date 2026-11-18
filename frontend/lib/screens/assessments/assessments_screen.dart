
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'anxiety_stress_screen.dart';
import 'depression_mood_screen.dart';
import 'student_wellbeing_screen.dart';
import 'general_wellbeing_screen.dart';
import 'phq9_screen.dart';
import 'gad7_screen.dart';
import 'who5_screen.dart';

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(18, 30, 18, 10),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
              const Expanded(
                child: Center(
                  child: Text(
                    'Assessments',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 34),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),

              const Text(
                'Choose an assessment',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Select a topic to explore your current wellbeing.',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.52),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeading(
                title: 'Validated Assessments',
                subtitle: 'Standardized mental wellbeing questionnaires',
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.psychology_outlined,
                title: 'PHQ-9',
                description:
                'Patient Health Questionnaire for screening depressive symptoms.',
                questions: '9 questions',
                duration: '3 min',
                iconColor: const Color(0xFF6B7FD7),
                backgroundColor: const Color(0xFFF1F3FC),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Phq9Screen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.self_improvement_rounded,
                title: 'GAD-7',
                description:
                'Generalized Anxiety Disorder questionnaire for anxiety symptoms.',
                questions: '7 questions',
                duration: '3 min',
                iconColor: const Color(0xFFE29A45),
                backgroundColor: const Color(0xFFFFF5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Gad7Screen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.favorite_outline_rounded,
                title: 'WHO-5',
                description:
                'World Health Organization questionnaire measuring general mental wellbeing.',
                questions: '5 questions',
                duration: '2 min',
                iconColor: AppColors.mint,
                backgroundColor: AppColors.lightMint,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Who5Screen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              _buildSectionHeading(
                title: 'MindMate Wellbeing Assessments',
                subtitle: 'Additional topic-specific questionnaires',
                icon: Icons.spa_outlined,
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.psychology_outlined,
                title: 'Anxiety & Stress',
                description:
                'Explore your current levels of anxiety, stress and emotional pressure.',
                questions: '20 questions',
                duration: '5 min',
                iconColor: const Color(0xFF6B7FD7),
                backgroundColor: const Color(0xFFF1F3FC),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnxietyStressScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.mood_outlined,
                title: 'Depression & Mood',
                description:
                'Reflect on your mood, motivation and emotional wellbeing.',
                questions: '20 questions',
                duration: '5 min',
                iconColor: const Color(0xFFE29A45),
                backgroundColor: const Color(0xFFFFF5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DepressionMoodScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.school_outlined,
                title: 'Student Wellbeing',
                description:
                'Explore study pressure, academic stress and burnout.',
                questions: '20 questions',
                duration: '5 min',
                iconColor: AppColors.mint,
                backgroundColor: AppColors.lightMint,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentWellbeingScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildAssessmentCard(
                context: context,
                icon: Icons.favorite_outline_rounded,
                title: 'General Wellbeing',
                description:
                'Get a broader picture of your current emotional wellbeing.',
                questions: '20 questions',
                duration: '5 min',
                iconColor: const Color(0xFF5C8FA8),
                backgroundColor: const Color(0xFFEDF5F8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeneralWellbeingScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              _buildPrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF294253)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppColors.mint,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MindMate Assessments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Take a few minutes to understand how you have been feeling.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.mint, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
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
                  color: AppColors.navy.withValues(alpha: 0.50),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required String description,
    required String questions,
    required String duration,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderMint),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.navy,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.52),
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.quiz_outlined,
                          text: questions,
                        ),
                        const SizedBox(width: 7),
                        _buildInfoChip(
                          icon: Icons.access_time_rounded,
                          text: duration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.mint, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.mint,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your assessment responses and results are securely saved to your account.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.60),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
