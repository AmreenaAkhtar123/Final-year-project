import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class SafetySupportScreen extends StatefulWidget {
  const SafetySupportScreen({super.key});

  @override
  State<SafetySupportScreen> createState() => _SafetySupportScreenState();
}

class _SafetySupportScreenState extends State<SafetySupportScreen> {
  // ---------------------------------------------------------------------------
  // SUPPORT OPTIONS
  // ---------------------------------------------------------------------------

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'I need someone to talk to',
      'description':
      'Find a trusted person who can listen and support you through a difficult moment.',
      'icon': Icons.people_alt_outlined,
      'type': 'conversation',
    },
    {
      'title': 'I feel unsafe',
      'description':
      'Get immediate safety guidance and identify someone who can stay with you.',
      'icon': Icons.shield_outlined,
      'type': 'safety',
    },
    {
      'title': 'I need professional support',
      'description':
      'Learn when professional support may be helpful and how to take the next step.',
      'icon': Icons.medical_services_outlined,
      'type': 'professional',
    },
  ];

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroSection(),

                    const SizedBox(height: 20),

                    _buildSupportStatusCard(),

                    const SizedBox(height: 22),

                    _buildImmediateHelpCard(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'What do you need right now?',
                      'Choose the type of support that feels closest to your situation.',
                    ),

                    const SizedBox(height: 14),

                    _buildSupportOptions(),

                    const SizedBox(height: 18),

                    _buildTrustedPersonCard(),

                    const SizedBox(height: 28),

                    _buildRecommendedNextStep(),

                    const SizedBox(height: 28),

                    _buildSupportSteps(),

                    const SizedBox(height: 28),

                    _buildSafetyInfoCard(),

                    const SizedBox(height: 20),

                    _buildDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 20, 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Support?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'You do not have to handle everything alone.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
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
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: AppColors.mint,
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  'SUPPORT',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTRO
  // ---------------------------------------------------------------------------

  Widget _buildIntroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightMint,
            AppColors.lightMint.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.mint,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'It is okay to ask for help.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Whether you need someone to listen, safety guidance, or professional support, you can take one step at a time.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
                    height: 1.45,
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

  // ---------------------------------------------------------------------------
  // CURRENT SUPPORT STATUS
  // ---------------------------------------------------------------------------

  Widget _buildSupportStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: AppColors.mint,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current support status',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Based on your recent wellbeing activity',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.lightMint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.mint,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No immediate concern detected',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Continue checking in with yourself and reach out when you need support.',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 9.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'This status is a visual placeholder for the future risk-analysis module. It is not a clinical assessment or diagnosis.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.48),
              fontSize: 8.8,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMMEDIATE HELP
  // ---------------------------------------------------------------------------

  Widget _buildImmediateHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF2D8D2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emergency_outlined,
                  color: Color(0xFFD96B5F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need immediate help?',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your immediate safety comes first.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'If you are in immediate danger or feel unable to keep yourself safe, move to a safe place and seek immediate help from an appropriate emergency service or trusted person.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _showImmediateHelpDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD96B5F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.shield_outlined,
                size: 19,
              ),
              label: const Text(
                'View Safety Guidance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

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
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.52),
            fontSize: 10.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUPPORT OPTIONS
  // ---------------------------------------------------------------------------

  Widget _buildSupportOptions() {
    return Column(
      children: _supportOptions.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: _buildSupportOption(item),
        );
      }).toList(),
    );
  }

  Widget _buildSupportOption(
      Map<String, dynamic> item,
      ) {
    return GestureDetector(
      onTap: () {
        _handleSupportOption(item['type'] as String);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: AppColors.borderMint,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: AppColors.mint,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] as String,
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.52),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.navy,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRUSTED PERSON
  // ---------------------------------------------------------------------------

  Widget _buildTrustedPersonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              color: AppColors.mint,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reach someone you trust',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'A trusted friend, family member, teacher, counselor, or another supportive person can help you through a difficult moment.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RECOMMENDED NEXT STEP
  // ---------------------------------------------------------------------------

  Widget _buildRecommendedNextStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF3F8F6),
            AppColors.lightMint.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.mint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended next step',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Personalized guidance',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Stay connected with people who support you.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'If you have been experiencing difficulties, consider talking with someone you trust and checking in with your wellbeing regularly.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.58),
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _showRecommendationDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(
                  color: AppColors.borderMint,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.72),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 17,
              ),
              label: const Text(
                'View recommendation',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Recommendations will be personalized using wellbeing patterns in a future AI/data-analysis module.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.45),
              fontSize: 8.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUPPORT STEPS
  // ---------------------------------------------------------------------------

  Widget _buildSupportSteps() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: AppColors.mint,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'Taking the next step',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _buildSupportStep(
            number: '1',
            title: 'Recognize what you need',
            description:
            'It is okay if you cannot explain everything. Start with what feels most important right now.',
          ),
          const SizedBox(height: 13),
          _buildSupportStep(
            number: '2',
            title: 'Choose someone supportive',
            description:
            'Think of a person you trust and let them know that you could use some support.',
          ),
          const SizedBox(height: 13),
          _buildSupportStep(
            number: '3',
            title: 'Take one manageable step',
            description:
            'You do not need to solve everything at once. Focus on the next safe and helpful action.',
          ),
        ],
      ),
    );
  }

  Widget _buildSupportStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.mint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.52),
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SAFETY INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildSafetyInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.mint,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'Safety information',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSafetyPoint(
            Icons.location_on_outlined,
            'Choose a safe environment',
            'If you feel unsafe, move somewhere you feel protected and supported.',
          ),
          const SizedBox(height: 12),
          _buildSafetyPoint(
            Icons.person_outline_rounded,
            'Stay connected',
            'Reach out to someone you trust instead of facing a difficult moment alone.',
          ),
          const SizedBox(height: 12),
          _buildSafetyPoint(
            Icons.local_hospital_outlined,
            'Seek professional care',
            'A qualified mental-health professional can provide support suited to your situation.',
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyPoint(
      IconData icon,
      String title,
      String description,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.mint,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.52),
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DISCLAIMER
  // ---------------------------------------------------------------------------

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.48),
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'MindMate provides supportive information and self-reflection tools. '
                  'It is not a replacement for professional mental-health care or emergency services.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.52),
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUPPORT ACTIONS
  // ---------------------------------------------------------------------------

  void _handleSupportOption(String type) {
    switch (type) {
      case 'conversation':
        _showSupportDialog(
          title: 'Someone to talk to',
          icon: Icons.people_alt_outlined,
          message:
          'Think about someone you trust enough to tell that you are having a difficult time. You do not need to explain everything at once. Simply saying, "I could really use someone to talk to," can be a good first step.',
        );
        break;

      case 'safety':
        _showSafetyDialog();
        break;

      case 'professional':
        _showProfessionalSupportDialog();
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // IMMEDIATE SAFETY DIALOG
  // ---------------------------------------------------------------------------

  void _showImmediateHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.emergency_outlined,
                color: Color(0xFFD96B5F),
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Immediate safety',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'If you or someone else is in immediate danger, move to a safe location and seek immediate help from an appropriate emergency service or go to the nearest emergency department.\n\n'
                'If possible, ask a trusted person to stay with you while you get help.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TALK TO SOMEONE
  // ---------------------------------------------------------------------------

  void _showSupportDialog({
    required String title,
    required IconData icon,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
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
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SAFETY OPTION
  // ---------------------------------------------------------------------------

  void _showSafetyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Color(0xFFD96B5F),
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Prioritize your safety',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'If you feel unsafe, try to move to a place where you feel protected and stay near someone you trust.\n\n'
                'If there is immediate danger, seek help from an appropriate emergency service or go to the nearest emergency department.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PROFESSIONAL SUPPORT
  // ---------------------------------------------------------------------------

  void _showProfessionalSupportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.mint,
                size: 25,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Professional support',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'A qualified mental-health professional can provide personalized support and help you understand what you are experiencing.\n\n'
                'Consider contacting a psychologist, psychiatrist, counselor, or another appropriately qualified professional when difficulties are persistent, significantly affecting daily life, or difficult to manage on your own.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // RECOMMENDATION DIALOG
  // ---------------------------------------------------------------------------

  void _showRecommendationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.mint,
                size: 25,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your recommendation',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Based on the current demo information, staying connected with a trusted person and continuing regular wellbeing check-ins may be helpful.\n\n'
                'In the future, this section will use MindMate\'s data-analysis and recommendation modules to provide personalized guidance based on the user\'s wellbeing patterns.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}