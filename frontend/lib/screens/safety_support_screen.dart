
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'emergency_contacts_screen.dart';

class SafetySupportScreen extends StatefulWidget {
  const SafetySupportScreen({super.key});

  @override
  State<SafetySupportScreen> createState() => _SafetySupportScreenState();
}

class _SafetySupportScreenState extends State<SafetySupportScreen> {
  // ---------------------------------------------------------------------------
  // THEME
  // ---------------------------------------------------------------------------

  static const Color _softBackground = Color(0xFFF7FAF8);
  static const Color _mutedText = Color(0xFF718078);
  static const Color _urgentColor = Color(0xFFD96B5F);
  static const Color _urgentBackground = Color(0xFFFFF5F2);

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroSection(),

                    const SizedBox(height: 24),

                    _buildTrustedPersonCard(),

                    const SizedBox(height: 30),

                    _buildSectionTitle(
                      'How can we support you?',
                      'Choose the kind of support you need right now.',
                    ),

                    const SizedBox(height: 16),

                    _buildSupportOptions(),

                    const SizedBox(height: 24),

                    _buildImmediateHelpCard(),

                    const SizedBox(height: 24),

                    _buildGentleReminder(),

                    const SizedBox(height: 16),

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
      padding: const EdgeInsets.fromLTRB(16, 10, 20, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.navy,
                  size: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Support',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your wellbeing matters',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(10),
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
  // INTRODUCTION
  // ---------------------------------------------------------------------------

  Widget _buildIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You don’t have to\nface it alone.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 29,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Support is available. Take a moment to find the help you need, '
              'one step at a time.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.62),
            fontSize: 12,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TRUSTED PERSON / EMERGENCY CONTACTS
  // ---------------------------------------------------------------------------

  Widget _buildTrustedPersonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  color: AppColors.mint,
                  size: 23,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'REACH SOMEONE YOU TRUST',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              const Icon(
                Icons.verified_user_outlined,
                color: Colors.white54,
                size: 19,
              ),
            ],
          ),

          const SizedBox(height: 19),

          const Text(
            'Your trusted people,\none tap away.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'Manage your emergency contacts and reach out '
                'when you need someone by your side.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 11,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: _openEmergencyContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Manage Emergency Contacts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 11),

          Center(
            child: Text(
              'Your contacts are managed privately in your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEmergencyContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmergencyContactsScreen(),
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
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _mutedText,
            fontSize: 10.5,
            height: 1.45,
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
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSupportOption(
                title: 'Talk to someone',
                description: 'Find emotional support.',
                icon: Icons.people_alt_outlined,
                onTap: () {
                  _handleSupportOption('conversation');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSupportOption(
                title: 'Safety guidance',
                description: 'Explore safety steps.',
                icon: Icons.shield_outlined,
                onTap: _showSafetyDialog,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSupportOption(
                title: 'Professional help',
                description: 'Explore support resources.',
                icon: Icons.medical_services_outlined,
                onTap: _showProfessionalSupportDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSupportOption(
                title: 'Immediate help',
                description: 'Prioritize your safety.',
                icon: Icons.emergency_outlined,
                isUrgent: true,
                onTap: _showImmediateHelpDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildSupportOption({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isUrgent = false,
  }) {
    final Color iconColor = isUrgent ? _urgentColor : AppColors.mint;
    final Color iconBackground =
    isUrgent ? const Color(0xFFFFE8E3) : AppColors.lightMint;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 145,
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isUrgent
                  ? const Color(0xFFF2D8D2)
                  : AppColors.borderMint,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),

              const SizedBox(height: 13),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                description,
                style: const TextStyle(
                  color: _mutedText,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: iconColor,
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // IMMEDIATE HELP
  // ---------------------------------------------------------------------------

  Widget _buildImmediateHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _urgentBackground,
        borderRadius: BorderRadius.circular(21),
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
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E3),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: _urgentColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you in immediate danger?',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your immediate safety comes first.',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          const Text(
            'Move to a safe place and seek help from an appropriate '
                'emergency service or a trusted person if you cannot '
                'keep yourself safe.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 10.5,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _showImmediateHelpDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: _urgentColor,
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFEBC9C2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(
                Icons.shield_outlined,
                size: 18,
              ),
              label: const Text(
                'View Immediate Safety Guidance',
                style: TextStyle(
                  fontSize: 11,
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
  // GENTLE REMINDER
  // ---------------------------------------------------------------------------

  Widget _buildGentleReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF7F3),
            Color(0xFFF7FAF8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                width: 39,
                height: 39,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: AppColors.mint,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              const Text(
                'A gentle reminder',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          const Text(
            'Taking the first step to ask for help is an important step.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'You do not need to figure everything out today. '
                'Give yourself time, stay connected, and take one '
                'manageable step at a time.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.62),
              fontSize: 10.5,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 13),

          TextButton.icon(
            onPressed: _showRecommendationDialog,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mint,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 17,
            ),
            label: const Text(
              'A helpful next step',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DISCLAIMER
  // ---------------------------------------------------------------------------

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.48),
            size: 17,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'MindMate is a supportive tool, not a replacement for '
                  'professional mental-health care or emergency services. '
                  'If you are in immediate danger, seek urgent assistance.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.58),
                fontSize: 9.5,
                height: 1.5,
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
          'Think about someone you trust enough to tell that you are '
              'having a difficult time. You do not need to explain '
              'everything at once. Simply saying, '
              '"I could really use someone to talk to," '
              'can be a good first step.',
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
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.emergency_outlined,
                color: _urgentColor,
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
            'If you or someone else is in immediate danger, move to a '
                'safe location and seek immediate help from an appropriate '
                'emergency service or go to the nearest emergency department.\n\n'
                'If possible, ask a trusted person to stay with you while '
                'you get help.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
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
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: _urgentColor,
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
            'If you feel unsafe, try to move to a place where you feel '
                'protected and stay near someone you trust.\n\n'
                'If there is immediate danger, seek help from an appropriate '
                'emergency service or go to the nearest emergency department.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
      builder: (dialogContext) {
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
            'A qualified mental-health professional can provide '
                'personalized support and help you understand what you '
                'are experiencing.\n\n'
                'Consider contacting a psychologist, psychiatrist, '
                'counselor, or another appropriately qualified professional '
                'when difficulties are persistent, significantly affecting '
                'daily life, or difficult to manage on your own.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
      builder: (dialogContext) {
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
            'Based on the current demo information, staying connected '
                'with a trusted person and continuing regular wellbeing '
                'check-ins may be helpful.\n\n'
                'In the future, this section will use MindMate\'s '
                'data-analysis and recommendation modules to provide '
                'personalized guidance based on the user\'s wellbeing patterns.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
