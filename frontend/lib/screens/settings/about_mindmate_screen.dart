import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutMindMateScreen extends StatelessWidget {
  const AboutMindMateScreen({super.key});

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
                12,
                20,
                36,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildBrandHeader(),

                    const SizedBox(height: 34),

                    _buildIntroSection(),

                    const SizedBox(height: 30),

                    _buildWhatMindMateOffers(),

                    const SizedBox(height: 30),

                    _buildImportantNote(),

                    const SizedBox(height: 30),

                    _buildProjectInformation(),

                    const SizedBox(height: 28),

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
              'About MindMate',
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
  // BRAND HEADER
  // ------------------------------------------------------------

  Widget _buildBrandHeader() {
    return Container(
      height: 225,
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
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(
                  alpha: 0.10,
                ),
              ),
            ),
          ),

          Positioned(
            left: -75,
            bottom: -85,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.045,
                  ),
                  width: 20,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Image.asset(
                        'assets/images/logo1.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: const Text(
                        'V1.0.0',
                        style: TextStyle(
                          color: AppColors.mint,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Text(
                  'MindMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Your wellbeing companion.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.62,
                    ),
                    fontSize: 11,
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

  // ------------------------------------------------------------
  // INTRO
  // ------------------------------------------------------------

  Widget _buildIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEyebrow('WHY MINDMATE'),

        const SizedBox(height: 10),

        const Text(
          'A little space to\ncheck in with yourself.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 13),

        Text(
          'MindMate is designed to make everyday wellbeing '
              'support feel simple, approachable and easy to access.',
          style: TextStyle(
            color: AppColors.navy.withValues(
              alpha: 0.55,
            ),
            fontSize: 11.2,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // WHAT MINDMATE OFFERS
  // ------------------------------------------------------------

  Widget _buildWhatMindMateOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEyebrow('WHAT YOU CAN DO'),

        const SizedBox(height: 15),

        _buildFeatureRow(
          icon: Icons.favorite_border_rounded,
          title: 'Check in',
          text:
          'Pause and reflect on how you are feeling.',
        ),

        _buildFeatureRow(
          icon: Icons.spa_outlined,
          title: 'Reset',
          text:
          'Use short guided exercises for difficult moments.',
        ),

        _buildFeatureRow(
          icon: Icons.insights_outlined,
          title: 'Understand your patterns',
          text:
          'Look back at your wellbeing activity and insights.',
        ),

        _buildFeatureRow(
          icon: Icons.support_agent_outlined,
          title: 'Find support',
          text:
          'Access safety information and support guidance when needed.',
        ),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(13),
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  text,
                  style: TextStyle(
                    color: AppColors.navy.withValues(
                      alpha: 0.48,
                    ),
                    fontSize: 9.8,
                    height: 1.35,
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

  // ------------------------------------------------------------
  // IMPORTANT NOTE
  // ------------------------------------------------------------

  Widget _buildImportantNote() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17,
        16,
        17,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.mint,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Important note',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'MindMate is a wellbeing support application and '
                      'does not replace professional medical or '
                      'psychological care.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(
                      alpha: 0.55,
                    ),
                    fontSize: 10,
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

  // ------------------------------------------------------------
  // PROJECT INFORMATION
  // ------------------------------------------------------------

  Widget _buildProjectInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEyebrow('PROJECT'),

        const SizedBox(height: 12),

        const Text(
          'Built as a final-year project.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'MindMate is being developed as a final-year project '
              'focused on creating accessible digital wellbeing tools '
              'for students.',
          style: TextStyle(
            color: AppColors.navy.withValues(
              alpha: 0.55,
            ),
            fontSize: 10.8,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.fromLTRB(
            14,
            13,
            14,
            13,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.code_rounded,
                color: AppColors.mint,
                size: 19,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Some features currently use demonstration data '
                      'and will be connected to backend services later.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(
                      alpha: 0.50,
                    ),
                    fontSize: 9.8,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 42,
          height: 1,
          color: AppColors.borderMint,
        ),

        const SizedBox(height: 15),

        Text(
          'MindMate',
          style: TextStyle(
            color: AppColors.navy.withValues(
              alpha: 0.45,
            ),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'A little space for your wellbeing.',
          style: TextStyle(
            color: AppColors.navy.withValues(
              alpha: 0.32,
            ),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // EYEBROW
  // ------------------------------------------------------------

  Widget _buildEyebrow(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.mint,
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.7,
      ),
    );
  }
}
