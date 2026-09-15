import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // ============================================================
  // CHECK-IN STATE
  // ============================================================

  int _selectedMood = -1;
  double _moodIntensity = 5;
  double _energyLevel = 5;
  double _sleepQuality = 5;

  final Set<String> _selectedEmotions = {};
  final Set<String> _selectedFactors = {};

  final TextEditingController _reflectionController =
  TextEditingController();

  bool _isSubmitting = false;

  // ============================================================
  // DATA
  // ============================================================

  final List<_MoodOption> _moods = const [
    _MoodOption(
      emoji: '😔',
      title: 'Low',
      description: 'Not feeling my best',
    ),
    _MoodOption(
      emoji: '😕',
      title: 'Okay',
      description: 'Getting through it',
    ),
    _MoodOption(
      emoji: '😐',
      title: 'Neutral',
      description: 'Feeling balanced',
    ),
    _MoodOption(
      emoji: '🙂',
      title: 'Good',
      description: 'Feeling positive',
    ),
    _MoodOption(
      emoji: '😊',
      title: 'Great',
      description: 'Feeling wonderful',
    ),
  ];

  final List<String> _emotions = [
    'Calm',
    'Happy',
    'Anxious',
    'Sad',
    'Stressed',
    'Angry',
    'Lonely',
    'Motivated',
    'Overwhelmed',
    'Hopeful',
  ];

  final List<String> _factors = [
    'Studies',
    'Work',
    'Family',
    'Relationships',
    'Health',
    'Sleep',
    'Finances',
    'Social life',
    'Future',
    'Nothing specific',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submitCheckIn() async {
    if (_selectedMood == -1) {
      _showMessage(
        'Please select how you are feeling today.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Temporary delay.
    // Later this will send the check-in to the backend.
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    _showCompletionDialog();
  }

  // ============================================================
  // COMPLETION DIALOG
  // ============================================================

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mint,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Check-in Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Thank you for taking a moment to check in with yourself today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.mint,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your wellbeing insight will be updated.',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  20,
                  22,
                  35,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 25),

                    _buildIntro(),

                    const SizedBox(height: 22),

                    _buildProgress(),

                    const SizedBox(height: 28),

                    _buildMoodSection(),

                    const SizedBox(height: 25),

                    _buildIntensitySection(),

                    const SizedBox(height: 25),

                    _buildEmotionSection(),

                    const SizedBox(height: 25),

                    _buildEnergySection(),

                    const SizedBox(height: 25),

                    _buildSleepSection(),

                    const SizedBox(height: 25),

                    _buildFactorsSection(),

                    const SizedBox(height: 25),

                    _buildReflectionSection(),

                    const SizedBox(height: 25),

                    _buildInsightCard(),

                    const SizedBox(height: 28),

                    _buildSubmitButton(),

                    const SizedBox(height: 15),

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

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.navy,
              size: 21,
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Image.asset(
            'assets/images/logo1.png',
            width: 112,
            height: 38,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_outline_rounded,
                color: AppColors.mint,
                size: 14,
              ),
              SizedBox(width: 5),
              Text(
                'Check-in',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you\nfeeling today?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 31,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Take a quiet moment to check in with yourself. There are no right or wrong answers.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.52),
            fontSize: 12,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    final completed = _calculateProgress();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 43,
            height: 43,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: completed,
                  strokeWidth: 4,
                  backgroundColor: AppColors.lightMint,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(
                    AppColors.mint,
                  ),
                ),
                Text(
                  '${(completed * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your daily check-in',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  completed == 1
                      ? 'Everything is complete.'
                      : 'A few moments for yourself.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.45),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.self_improvement_rounded,
            color: AppColors.mint,
            size: 25,
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    int completed = 0;

    if (_selectedMood != -1) completed++;
    if (_selectedEmotions.isNotEmpty) completed++;
    if (_selectedFactors.isNotEmpty) completed++;
    if (_reflectionController.text.trim().isNotEmpty) completed++;

    return completed / 4;
  }

  // ============================================================
  // MOOD
  // ============================================================

  Widget _buildMoodSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '01',
            title: 'Your overall mood',
            subtitle: 'Choose what feels closest right now.',
          ),

          const SizedBox(height: 18),

          Row(
            children: List.generate(
              _moods.length,
                  (index) {
                final selected = _selectedMood == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                        right: index == _moods.length - 1 ? 0 : 7,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.lightMint
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selected
                              ? AppColors.mint
                              : AppColors.borderMint,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _moods[index].emoji,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            _moods[index].title,
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 9,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 13),

          if (_selectedMood != -1)
            Center(
              child: Text(
                _moods[_selectedMood].description,
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INTENSITY
  // ============================================================

  Widget _buildIntensitySection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '02',
            title: 'Mood intensity',
            subtitle: 'How strongly are you feeling this mood?',
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Very low',
                style: _smallLabelStyle(),
              ),
              Text(
                '${_moodIntensity.round()} / 10',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Very high',
                style: _smallLabelStyle(),
              ),
            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.mint,
              inactiveTrackColor: AppColors.lightMint,
              thumbColor: AppColors.mint,
              overlayColor:
              AppColors.mint.withValues(alpha: 0.10),
              trackHeight: 5,
            ),
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: _moodIntensity,
              onChanged: (value) {
                setState(() {
                  _moodIntensity = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMOTIONS
  // ============================================================

  Widget _buildEmotionSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '03',
            title: 'What are you feeling?',
            subtitle: 'Select all emotions that describe you.',
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotions.map((emotion) {
              final selected =
              _selectedEmotions.contains(emotion);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedEmotions.remove(emotion);
                    } else {
                      _selectedEmotions.add(emotion);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.mint
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.mint
                          : AppColors.borderMint,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        emotion,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.navy,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ENERGY
  // ============================================================

  Widget _buildEnergySection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '04',
            title: 'Energy level',
            subtitle: 'How much energy do you have right now?',
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _buildScaleIcon(
                Icons.battery_0_bar_rounded,
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.mint,
                    inactiveTrackColor: AppColors.lightMint,
                    thumbColor: AppColors.mint,
                    trackHeight: 5,
                  ),
                  child: Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: _energyLevel,
                    onChanged: (value) {
                      setState(() {
                        _energyLevel = value;
                      });
                    },
                  ),
                ),
              ),

              _buildScaleIcon(
                Icons.battery_full_rounded,
              ),
            ],
          ),

          Center(
            child: Text(
              _energyText,
              style: const TextStyle(
                color: AppColors.mint,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _energyText {
    if (_energyLevel <= 3) return 'Running on low energy';
    if (_energyLevel <= 6) return 'Moderate energy';
    if (_energyLevel <= 8) return 'Feeling energized';
    return 'Full of energy';
  }

  Widget _buildScaleIcon(IconData icon) {
    return Icon(
      icon,
      color: AppColors.mint,
      size: 22,
    );
  }

  // ============================================================
  // SLEEP
  // ============================================================

  Widget _buildSleepSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '05',
            title: 'Sleep quality',
            subtitle: 'How restful was your sleep last night?',
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(
                Icons.bedtime_outlined,
                color: AppColors.mint,
                size: 21,
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.mint,
                    inactiveTrackColor: AppColors.lightMint,
                    thumbColor: AppColors.mint,
                    trackHeight: 5,
                  ),
                  child: Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: _sleepQuality,
                    onChanged: (value) {
                      setState(() {
                        _sleepQuality = value;
                      });
                    },
                  ),
                ),
              ),

              const Icon(
                Icons.hotel_rounded,
                color: AppColors.mint,
                size: 21,
              ),
            ],
          ),

          Center(
            child: Text(
              _sleepText,
              style: const TextStyle(
                color: AppColors.mint,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _sleepText {
    if (_sleepQuality <= 3) return 'Poor sleep';
    if (_sleepQuality <= 6) return 'Could be better';
    if (_sleepQuality <= 8) return 'Good sleep';
    return 'Very restful';
  }

  // ============================================================
  // FACTORS
  // ============================================================

  Widget _buildFactorsSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '06',
            title: 'What influenced your mood?',
            subtitle: 'Choose anything that may have played a role.',
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _factors.map((factor) {
              final selected =
              _selectedFactors.contains(factor);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedFactors.remove(factor);
                    } else {
                      _selectedFactors.add(factor);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.lightMint
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.mint
                          : AppColors.borderMint,
                    ),
                  ),
                  child: Text(
                    factor,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 10.5,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REFLECTION
  // ============================================================

  Widget _buildReflectionSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            number: '07',
            title: 'A little reflection',
            subtitle: 'Optional — write whatever is on your mind.',
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _reflectionController,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText:
              'What would you like to remember about today?',
              hintStyle: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.32),
                fontSize: 11,
              ),
              filled: true,
              fillColor: AppColors.background,
              counterStyle: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.30),
                fontSize: 9,
              ),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.mint,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSIGHT
  // ============================================================

  Widget _buildInsightCard() {
    String title;
    String message;
    IconData icon;

    if (_selectedMood == 0) {
      title = 'Be gentle with yourself';
      message =
      'It sounds like today may be difficult. Taking things one small step at a time is enough.';
      icon = Icons.spa_rounded;
    } else if (_energyLevel <= 3) {
      title = 'Your energy matters';
      message =
      'Low energy can be a signal to slow down. Consider a short break, some water, or a few deep breaths.';
      icon = Icons.battery_2_bar_rounded;
    } else if (_sleepQuality <= 3) {
      title = 'Rest is part of wellbeing';
      message =
      'Your sleep may be affecting how you feel today. Try to give yourself some extra space to rest.';
      icon = Icons.nightlight_round;
    } else if (_selectedMood >= 3) {
      title = 'Keep nurturing this feeling';
      message =
      'It is great to notice positive moments. Consider remembering what helped you feel this way today.';
      icon = Icons.auto_awesome_rounded;
    } else {
      title = 'A moment for yourself';
      message =
      'Checking in is already a positive step. Small moments of self-awareness can make a difference.';
      icon = Icons.self_improvement_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightMint,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINDMATE INSIGHT',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.55),
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

  // ============================================================
  // SUBMIT
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submitCheckIn,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          disabledBackgroundColor:
          AppColors.mint.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Complete Check-in',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  Widget _buildPrivacyNote() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.32),
            size: 13,
          ),

          const SizedBox(width: 5),

          Text(
            'Your check-in is private and secure',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CONTAINER
  // ============================================================

  Widget _buildSectionContainer({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.mint,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

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
      ],
    );
  }

  // ============================================================
  // SMALL LABEL
  // ============================================================

  TextStyle _smallLabelStyle() {
    return TextStyle(
      color: AppColors.navy.withValues(alpha: 0.42),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );
  }
}

// ================================================================
// MOOD MODEL
// ================================================================

class _MoodOption {
  final String emoji;
  final String title;
  final String description;

  const _MoodOption({
    required this.emoji,
    required this.title,
    required this.description,
  });
}