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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
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

          const SizedBox(height: 28),

          _buildSection(
            title: 'About the app',
            text:
            'MindMate is designed to provide students with accessible '
                'wellbeing tools, reflective activities, guided exercises '
                'and personal wellbeing insights.',
          ),

          _buildSection(
            title: 'Important note',
            text:
            'MindMate is a wellbeing support application and does not '
                'replace professional medical or psychological care.',
          ),

          _buildSection(
            title: 'Project information',
            text:
            'MindMate is being developed as a final-year project. '
                'Some features currently use demonstration data and '
                'will be connected to backend services later.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            text,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.55),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}