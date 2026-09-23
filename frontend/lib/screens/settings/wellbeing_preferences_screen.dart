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
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopBar(),
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
                    _buildHero(),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'MINDMATE REMINDERS',
                      'Choose the gentle moments you want to receive.',
                    ),

                    const SizedBox(height: 12),

                    _buildReminderCard(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'PERSONALIZATION',
                      'Adjust MindMate around your daily routine.',
                    ),

                    const SizedBox(height: 12),

                    _buildPersonalizationCard(),

                    const SizedBox(height: 24),

                    _buildPrivacyNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
              'Wellbeing Preferences',
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

  Widget _buildHero() {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft background shape
          Positioned(
            right: -55,
            top: -55,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.10),
              ),
            ),
          ),

          // Simple curved accent
          Positioned(
            right: 20,
            bottom: -70,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.045),
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
              17,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const Spacer(),

                const Text(
                  'Make MindMate work for you.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Set a few preferences so your experience '
                      'feels more personal.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // Natural summary row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            color: AppColors.mint,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Check-in: $_preferredTime',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (_studentMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: AppColors.mint,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Student mode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 39,
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.065),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.mint,
              size: 14,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.48),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
    );
  }

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
            color: AppColors.navy.withValues(alpha: 0.55),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.48),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.favorite_border_rounded,
            title: 'Daily check-in',
            subtitle: 'A gentle reminder to check in with yourself.',
            value: _dailyCheckIn,
            onChanged: (value) {
              setState(() {
                _dailyCheckIn = value;
              });
            },
          ),
          _divider(),
          _buildSwitchTile(
            icon: Icons.spa_outlined,
            title: 'Exercise suggestions',
            subtitle: 'Get short exercises based on your wellbeing.',
            value: _exerciseSuggestions,
            onChanged: (value) {
              setState(() {
                _exerciseSuggestions = value;
              });
            },
          ),
          _divider(),
          _buildSwitchTile(
            icon: Icons.insights_outlined,
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
    );
  }

  Widget _buildPersonalizationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreferenceTile(
            icon: Icons.schedule_outlined,
            title: 'Preferred check-in time',
            subtitle: _preferredTime,
            onTap: _selectPreferredTime,
          ),
          _divider(),
          _buildSwitchTile(
            icon: Icons.school_outlined,
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
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        15,
        14,
        13,
        14,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.lightMint
                  : AppColors.background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: value
                    ? AppColors.mint.withValues(alpha: 0.30)
                    : AppColors.borderMint,
              ),
            ),
            child: Icon(
              icon,
              color: value
                  ? AppColors.mint
                  : AppColors.navy.withValues(alpha: 0.38),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.44),
                    fontSize: 9.8,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildCustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 49,
        height: 29,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? AppColors.mint
              : AppColors.navy.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? AppColors.mint
                : AppColors.borderMint,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            14,
            14,
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferred check-in time',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightMint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.mint,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.navy,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.borderMint.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        15,
        14,
        15,
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
              size: 17,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your preferences, your pace.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'These preferences are currently stored locally '
                      'for the demo.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.50),
                    fontSize: 9.5,
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

  void _selectPreferredTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final List<String> times = [
          'Morning',
          'Afternoon',
          'Evening',
          'Night',
        ];

        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.lightMint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderMint,
                        ),
                      ),
                      child: const Icon(
                        Icons.schedule_outlined,
                        color: AppColors.mint,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in time',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'When would you like MindMate to check in?',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                ...times.map(
                      (time) {
                    final bool selected =
                        _preferredTime == time;

                    return Padding(
                      padding:
                      const EdgeInsets.only(bottom: 9),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _preferredTime = time;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius:
                          BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 160),
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.lightMint
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? AppColors.mint
                                    : AppColors.borderMint,
                                width: selected ? 1.2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.background,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _timeIcon(time),
                                    color: AppColors.mint,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      color: AppColors.navy,
                                      fontSize: 12,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.mint,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 2),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(
                        color: AppColors.borderMint,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _timeIcon(String time) {
    switch (time) {
      case 'Morning':
        return Icons.wb_sunny_outlined;
      case 'Afternoon':
        return Icons.wb_sunny_rounded;
      case 'Evening':
        return Icons.wb_twilight_rounded;
      case 'Night':
        return Icons.nightlight_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }
}