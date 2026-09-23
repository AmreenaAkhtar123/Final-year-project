import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopBar(context),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                36,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildHeader(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'GETTING STARTED',
                      'A few things to help you get comfortable with MindMate.',
                    ),

                    const SizedBox(height: 12),

                    _buildFaq(
                      icon: Icons.auto_awesome_outlined,
                      question: 'How does MindMate work?',
                      answer:
                      'MindMate brings together check-ins, guided '
                          'exercises, reflections and wellbeing insights '
                          'to help you understand how you are feeling '
                          'and build healthier everyday habits.',
                    ),

                    _buildFaq(
                      icon: Icons.dashboard_outlined,
                      question: 'What can I do on the Home screen?',
                      answer:
                      'The Home screen gives you quick access to your '
                          'daily pulse, mental wellbeing tools, guided '
                          'exercises, student-focused support and your '
                          'weekly progress.',
                    ),

                    _buildFaq(
                      icon: Icons.person_outline_rounded,
                      question: 'Do I need to complete everything?',
                      answer:
                      'No. You can explore MindMate at your own pace. '
                          'You can use check-ins, exercises, reflections '
                          'and other tools independently depending on '
                          'what feels useful to you.',
                    ),

                    _buildFaq(
                      icon: Icons.account_circle_outlined,
                      question: 'Can I update my profile information?',
                      answer:
                      'Yes. Open your Profile and go to Personal '
                          'Information. You can update the information '
                          'available there, including your profile photo '
                          'and other personal details.',
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'WELLBEING TOOLS',
                      'Learn more about check-ins, exercises and insights.',
                    ),

                    const SizedBox(height: 12),

                    _buildFaq(
                      icon: Icons.favorite_border_rounded,
                      question: 'What is a daily check-in?',
                      answer:
                      'A check-in gives you a simple way to pause and '
                          'reflect on how you are feeling. Your responses '
                          'can help you notice patterns in your mood and '
                          'overall wellbeing over time.',
                    ),

                    _buildFaq(
                      icon: Icons.spa_outlined,
                      question: 'What are the MindMate exercises?',
                      answer:
                      'MindMate exercises are short guided activities '
                          'designed for different moments, such as stress, '
                          'exam pressure, difficult thoughts, sleep, '
                          'self-compassion and emotional reset.',
                    ),

                    _buildFaq(
                      icon: Icons.timer_outlined,
                      question: 'How long do the exercises take?',
                      answer:
                      'Exercise lengths vary. Some are designed as '
                          'quick one-minute resets, while others give you '
                          'more time for breathing, reflection or guided '
                          'relaxation.',
                    ),

                    _buildFaq(
                      icon: Icons.insights_outlined,
                      question: 'What are wellbeing insights?',
                      answer:
                      'Insights help you look back at your check-ins '
                          'and wellbeing activity so you can notice changes '
                          'and patterns. They are intended for personal '
                          'reflection rather than clinical assessment.',
                    ),

                    _buildFaq(
                      icon: Icons.assessment_outlined,
                      question: 'Are the wellbeing scores medical diagnoses?',
                      answer:
                      'No. MindMate scores are designed for personal '
                          'reflection and are not medical or clinical '
                          'diagnoses. If you have concerns about your '
                          'wellbeing, consider speaking with a qualified '
                          'health professional.',
                    ),

                    _buildFaq(
                      icon: Icons.trending_up_rounded,
                      question: 'How does my progress work?',
                      answer:
                      'Your progress brings together activity such as '
                          'check-ins and wellbeing exercises. It is meant '
                          'to help you understand your own consistency and '
                          'habits rather than measure your mental health '
                          'in a clinical way.',
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'ACCOUNT & PRIVACY',
                      'Manage your information and understand how your data is handled.',
                    ),

                    const SizedBox(height: 12),

                    _buildFaq(
                      icon: Icons.lock_outline_rounded,
                      question: 'Is my MindMate information private?',
                      answer:
                      'MindMate is designed with privacy in mind. '
                          'You can review the available privacy and data '
                          'settings from your Profile to understand and '
                          'manage your preferences.',
                    ),

                    _buildFaq(
                      icon: Icons.security_outlined,
                      question: 'Can I change my password?',
                      answer:
                      'Yes. Open Profile, go to Password & Security, '
                          'and use the password settings available there '
                          'to update your account password.',
                    ),

                    _buildFaq(
                      icon: Icons.tune_rounded,
                      question: 'Can I change my wellbeing preferences?',
                      answer:
                      'Yes. Wellbeing Preferences lets you adjust '
                          'available reminder and personalization options '
                          'so MindMate better matches the way you want to '
                          'use the app.',
                    ),

                    _buildFaq(
                      icon: Icons.delete_outline_rounded,
                      question: 'Can I delete my data?',
                      answer:
                      'The Privacy & Data section provides options for '
                          'managing your information. Available deletion '
                          'and data-management actions depend on the current '
                          'version and backend implementation of MindMate.',
                    ),

                    _buildFaq(
                      icon: Icons.download_outlined,
                      question: 'Can I export my data?',
                      answer:
                      'If data export is available in your current '
                          'version of MindMate, you can access it from '
                          'Privacy & Data. Export functionality may depend '
                          'on the backend implementation.',
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'SAFETY & SUPPORT',
                      'Important information if you need additional support.',
                    ),

                    const SizedBox(height: 12),

                    _buildFaq(
                      icon: Icons.warning_amber_rounded,
                      question: 'Where can I get urgent help?',
                      answer:
                      'If you feel that you may be in immediate danger '
                          'or need urgent support, use the Safety & Support '
                          'section for guidance and consider contacting '
                          'local emergency services or a trusted person.',
                    ),

                    _buildFaq(
                      icon: Icons.people_outline_rounded,
                      question: 'Can MindMate replace a mental health professional?',
                      answer:
                      'No. MindMate is a wellbeing support tool and is '
                          'not a replacement for a qualified mental health '
                          'professional, doctor or emergency service.',
                    ),

                    _buildFaq(
                      icon: Icons.phone_in_talk_outlined,
                      question: 'What should I do if I need someone to talk to?',
                      answer:
                      'Consider reaching out to someone you trust, such '
                          'as a friend, family member, teacher or qualified '
                          'professional. You can also open Safety & Support '
                          'in MindMate for additional guidance.',
                    ),

                    _buildFaq(
                      icon: Icons.self_improvement_outlined,
                      question: 'What if an exercise does not feel helpful?',
                      answer:
                      'You do not need to continue an exercise that '
                          'does not feel right for you. You can stop, try '
                          'another exercise, or take a break and consider '
                          'talking with someone you trust.',
                    ),

                    const SizedBox(height: 22),

                    _buildSupportCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        20,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Help & Support',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -55,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(
                  alpha: 0.10,
                ),
              ),
            ),
          ),

          Positioned(
            left: -70,
            bottom: -75,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.mint.withValues(
                    alpha: 0.08,
                  ),
                  width: 18,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const Spacer(),

                const Text(
                  'Need a little help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Find simple answers about MindMate and '
                      'the tools available to you.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.64,
                    ),
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.075,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.mint,
                        size: 14,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        'Browse the topics below',
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.90,
                          ),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.navy.withValues(
              alpha: 0.55,
            ),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.15,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(
              alpha: 0.48,
            ),
            fontSize: 10.5,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // FAQ
  // ------------------------------------------------------------

  Widget _buildFaq({
    required IconData icon,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(
              alpha: 0.025,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          splashColor: AppColors.lightMint,
          highlightColor:
          AppColors.lightMint.withValues(
            alpha: 0.45,
          ),
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(
            14,
            5,
            12,
            5,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            68,
            0,
            16,
            16,
          ),
          iconColor: AppColors.mint,
          collapsedIconColor:
          AppColors.navy.withValues(
            alpha: 0.45,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 20,
            ),
          ),
          title: Text(
            question,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  color: AppColors.navy.withValues(
                    alpha: 0.55,
                  ),
                  fontSize: 10.2,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SUPPORT CARD
  // ------------------------------------------------------------

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        15,
        16,
        15,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              color: AppColors.mint,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need more help?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Support contact functionality can be connected '
                      'here when the backend and support system are implemented.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(
                      alpha: 0.50,
                    ),
                    fontSize: 9.7,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}