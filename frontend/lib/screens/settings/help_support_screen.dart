import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          _buildHeader(),

          const SizedBox(height: 24),

          _buildFaq(
            question: 'How does MindMate work?',
            answer:
            'MindMate provides wellbeing tools such as check-ins, '
                'guided exercises, insights and reflective activities.',
          ),

          _buildFaq(
            question: 'Are the wellbeing scores medical diagnoses?',
            answer:
            'No. MindMate wellbeing scores are intended to help '
                'you reflect on patterns and are not clinical diagnoses.',
          ),

          _buildFaq(
            question: 'Can I use MindMate without completing everything?',
            answer:
            'Yes. You can use individual features independently, '
                'including exercises, check-ins and insights.',
          ),

          _buildFaq(
            question: 'Where can I get urgent help?',
            answer:
            'Use the Safety & Support section when you need immediate '
                'guidance or support from another person.',
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need more help?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Support contact functionality can be connected here '
                      'when the backend and support system are implemented.',
                  style: TextStyle(
                    color: AppColors.navy,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF294253),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.help_outline_rounded,
            color: AppColors.mint,
            size: 27,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Find answers about MindMate and how its wellbeing features work.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaq({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        iconColor: AppColors.mint,
        collapsedIconColor: AppColors.navy,
        title: Text(
          question,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.55),
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}