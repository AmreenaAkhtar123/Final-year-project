import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class WellbeingPreferencesScreen extends StatefulWidget {
  const WellbeingPreferencesScreen({super.key});

  @override
  State<WellbeingPreferencesScreen> createState() =>
      _WellbeingPreferencesScreenState();
}

class _WellbeingPreferencesScreenState
    extends State<WellbeingPreferencesScreen> {
  bool _dailyCheckIn = true;
  bool _exerciseSuggestions = true;
  bool _weeklyInsights = true;
  bool _studentMode = true;

  String _preferredTime = 'Evening';

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
          'Wellbeing Preferences',
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
          _buildIntro(),

          const SizedBox(height: 24),

          _buildSectionTitle(
            'MindMate reminders',
            'Choose what you want to receive.',
          ),

          const SizedBox(height: 12),

          _buildCard(
            children: [
              _buildSwitch(
                title: 'Daily check-in',
                subtitle: 'Receive a gentle reminder to check in.',
                value: _dailyCheckIn,
                onChanged: (value) {
                  setState(() {
                    _dailyCheckIn = value;
                  });
                },
              ),
              _divider(),
              _buildSwitch(
                title: 'Exercise suggestions',
                subtitle: 'Receive suggestions for short exercises.',
                value: _exerciseSuggestions,
                onChanged: (value) {
                  setState(() {
                    _exerciseSuggestions = value;
                  });
                },
              ),
              _divider(),
              _buildSwitch(
                title: 'Weekly insights',
                subtitle: 'Receive a summary of your wellbeing patterns.',
                value: _weeklyInsights,
                onChanged: (value) {
                  setState(() {
                    _weeklyInsights = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 26),

          _buildSectionTitle(
            'Personalization',
            'Adjust MindMate around your routine.',
          ),

          const SizedBox(height: 12),

          _buildCard(
            children: [
              _buildPreferenceTile(
                icon: Icons.schedule_outlined,
                title: 'Preferred check-in time',
                subtitle: _preferredTime,
                onTap: _selectPreferredTime,
              ),
              _divider(),
              _buildSwitch(
                title: 'Student mode',
                subtitle: 'Show student-focused wellbeing content.',
                value: _studentMode,
                onChanged: (value) {
                  setState(() {
                    _studentMode = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'These preferences are currently stored locally for the demo.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.40),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.tune_rounded,
            color: AppColors.mint,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Make MindMate fit the way you prefer to use it.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
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
            color: AppColors.navy.withValues(alpha: 0.42),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.42),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.mint,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Container(
        width: 40,
        height: 40,
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
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.navy.withValues(alpha: 0.42),
          fontSize: 10,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.navy,
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: AppColors.borderMint.withValues(alpha: 0.7),
      ),
    );
  }

  void _selectPreferredTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Preferred check-in time',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...[
                  'Morning',
                  'Afternoon',
                  'Evening',
                  'Night',
                ].map(
                      (time) => ListTile(
                    title: Text(time),
                    trailing: _preferredTime == time
                        ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.mint,
                    )
                        : null,
                    onTap: () {
                      setState(() {
                        _preferredTime = time;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}