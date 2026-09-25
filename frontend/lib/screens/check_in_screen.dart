import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'home_screen.dart';

class CheckInScreen extends StatefulWidget {
  final VoidCallback onBackToHome;

  const CheckInScreen({
    super.key,
    required this.onBackToHome,
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int _selectedMood = -1;

  double _moodIntensity = 5;
  double _energyLevel = 5;
  double _sleepQuality = 5;

  final Set<String> _selectedEmotions = {};
  final Set<String> _selectedFactors = {};

  final TextEditingController _reflectionController =
  TextEditingController();

  bool _isSubmitting = false;

  // Tracks whether the user has actually selected a slider value.
  bool _intensitySelected = false;
  bool _energySelected = false;
  bool _sleepSelected = false;

  // Inline validation errors.
  String? _moodError;
  String? _intensityError;
  String? _emotionError;
  String? _energyError;
  String? _sleepError;
  String? _factorError;

  final List<Map<String, String>> _moods = const [
    {
      'label': 'Low',
      'emoji': '😔',
    },
    {
      'label': 'Okay',
      'emoji': '😕',
    },
    {
      'label': 'Neutral',
      'emoji': '😐',
    },
    {
      'label': 'Good',
      'emoji': '🙂',
    },
    {
      'label': 'Great',
      'emoji': '😊',
    },
  ];

  final List<String> _emotions = const [
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

  final List<String> _factors = const [
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

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    int completed = 0;

    if (_selectedMood != -1) completed++;
    if (_intensitySelected) completed++;
    if (_selectedEmotions.isNotEmpty) completed++;
    if (_energySelected) completed++;
    if (_sleepSelected) completed++;
    if (_selectedFactors.isNotEmpty) completed++;

    return completed / 6;
  }

  void _submitCheckIn() {
    setState(() {
      _moodError = null;
      _intensityError = null;
      _emotionError = null;
      _energyError = null;
      _sleepError = null;
      _factorError = null;

      if (_selectedMood == -1) {
        _moodError = 'Please select your overall mood.';
      }

      if (!_intensitySelected) {
        _intensityError = 'Please select your mood intensity.';
      }

      if (_selectedEmotions.isEmpty) {
        _emotionError = 'Please select at least one emotion.';
      }

      if (!_energySelected) {
        _energyError = 'Please select your energy level.';
      }

      if (!_sleepSelected) {
        _sleepError = 'Please select your sleep quality.';
      }

      if (_selectedFactors.isEmpty) {
        _factorError = 'Please select at least one factor.';
      }
    });

    // Do not continue if any required field is missing.
    if (_moodError != null ||
        _intensityError != null ||
        _emotionError != null ||
        _energyError != null ||
        _sleepError != null ||
        _factorError != null) {
      return;
    }

    // Reflection is optional, so it is intentionally not validated.

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showCompletionDialog();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mint,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Check-in Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thank you for taking a moment to check in with yourself today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
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

  Widget _buildInlineError(String? error) {
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        left: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.onBackToHome,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
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
        const Spacer(),
        const Text(
          'Daily Check-in',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you\nfeeling today?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Take a moment to notice what is happening within you.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    final progress = _calculateProgress();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.lightMint,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.mint,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your daily check-in',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A few moments for yourself can make a difference.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Overall mood',
          'Choose the option that best describes how you feel.',
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(
            _moods.length,
                (index) {
              final mood = _moods[index];
              final selected = _selectedMood == index;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == _moods.length - 1 ? 0 : 7,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = index;
                        _moodError = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 3,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.lightMint
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.mint
                              : AppColors.borderMint,
                          width: selected ? 1.4 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood['emoji']!,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mood['label']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.navy
                                  : Colors.black54,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildInlineError(_moodError),
      ],
    );
  }

  Widget _buildSliderLabels(
      String left,
      String right,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 11,
          ),
        ),
        Text(
          right,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
              'Mood intensity',
              'How strongly are you feeling this mood?',
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _intensitySelected
                    ? '${_moodIntensity.round()}/10'
                    : 'Select',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.mint,
            inactiveTrackColor: AppColors.lightMint,
            thumbColor: AppColors.mint,
            overlayColor: AppColors.lightMint,
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 9,
            ),
          ),
          child: Slider(
            value: _moodIntensity,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _moodIntensity = value;
                _intensitySelected = true;
                _intensityError = null;
              });
            },
          ),
        ),
        _buildSliderLabels(
          'Very low',
          'Very high',
        ),
        _buildInlineError(_intensityError),
      ],
    );
  }

  Widget _buildEmotionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'What are you feeling?',
          'Select all emotions that feel relevant right now.',
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 9,
          children: _emotions.map((emotion) {
            final selected = _selectedEmotions.contains(emotion);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedEmotions.remove(emotion);
                  } else {
                    _selectedEmotions.add(emotion);
                  }

                  if (_selectedEmotions.isNotEmpty) {
                    _emotionError = null;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.lightMint
                      : Colors.white,
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
                        color: AppColors.mint,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      emotion,
                      style: TextStyle(
                        color: selected
                            ? AppColors.navy
                            : Colors.black54,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        _buildInlineError(_emotionError),
      ],
    );
  }

  Widget _buildEnergySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
              'Energy level',
              'How much energy do you have today?',
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _energySelected
                    ? '${_energyLevel.round()}/10'
                    : 'Select',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.mint,
            inactiveTrackColor: AppColors.lightMint,
            thumbColor: AppColors.mint,
            overlayColor: AppColors.lightMint,
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 9,
            ),
          ),
          child: Slider(
            value: _energyLevel,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _energyLevel = value;
                _energySelected = true;
                _energyError = null;
              });
            },
          ),
        ),
        _buildSliderLabels(
          'Exhausted',
          'Full of energy',
        ),
        _buildInlineError(_energyError),
      ],
    );
  }

  Widget _buildSleepSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
              'Sleep quality',
              'How would you describe your sleep?',
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _sleepSelected
                    ? '${_sleepQuality.round()}/10'
                    : 'Select',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.mint,
            inactiveTrackColor: AppColors.lightMint,
            thumbColor: AppColors.mint,
            overlayColor: AppColors.lightMint,
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 9,
            ),
          ),
          child: Slider(
            value: _sleepQuality,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _sleepQuality = value;
                _sleepSelected = true;
                _sleepError = null;
              });
            },
          ),
        ),
        _buildSliderLabels(
          'Very poor',
          'Excellent',
        ),
        _buildInlineError(_sleepError),
      ],
    );
  }

  Widget _buildFactorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'What influenced your mood?',
          'Choose anything that may have affected how you feel.',
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 9,
          children: _factors.map((factor) {
            final selected = _selectedFactors.contains(factor);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (factor == 'Nothing specific') {
                    if (selected) {
                      _selectedFactors.remove(factor);
                    } else {
                      _selectedFactors
                        ..clear()
                        ..add(factor);
                    }
                  } else {
                    _selectedFactors.remove('Nothing specific');

                    if (selected) {
                      _selectedFactors.remove(factor);
                    } else {
                      _selectedFactors.add(factor);
                    }
                  }

                  if (_selectedFactors.isNotEmpty) {
                    _factorError = null;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.lightMint
                      : Colors.white,
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
                        color: AppColors.mint,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      factor,
                      style: TextStyle(
                        color: selected
                            ? AppColors.navy
                            : Colors.black54,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        _buildInlineError(_factorError),
      ],
    );
  }

  Widget _buildReflectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Reflection',
          'Optional — write whatever is on your mind.',
        ),
        const SizedBox(height: 13),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: TextField(
            controller: _reflectionController,
            maxLines: 5,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: 'Write a few thoughts...',
              hintStyle: TextStyle(
                color: Colors.black38,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterStyle: TextStyle(
                color: Colors.black38,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    String title = 'A moment for yourself';
    String description =
        'Checking in with yourself is a small step toward understanding your wellbeing.';

    if (_selectedMood == 0) {
      title = 'Be gentle with yourself';
      description =
      'It sounds like today may feel a little difficult. Give yourself permission to slow down and take things one moment at a time.';
    } else if (_selectedMood == 4) {
      title = 'Hold on to this feeling';
      description =
      'It is wonderful to notice a good moment. Take a second to appreciate what is making today feel positive.';
    } else if (_energySelected && _energyLevel <= 3) {
      title = 'Your energy matters';
      description =
      'Low energy can be a sign that your mind and body need a little extra care today.';
    } else if (_sleepSelected && _sleepQuality <= 3) {
      title = 'Rest can make a difference';
      description =
      'If sleep has been difficult, consider giving yourself some extra space for rest and recovery today.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Text(
                '🌿',
                style: TextStyle(fontSize: 21),
              ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          disabledBackgroundColor: AppColors.mint.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
        )
            : const Text(
          'Complete Check-in',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          color: Colors.black38,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          'Your check-in is private and personal.',
          style: TextStyle(
            color: Colors.black.withOpacity(0.42),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                22,
                18,
                22,
                35,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildTopBar(),

                    const SizedBox(height: 28),

                    _buildIntro(),

                    const SizedBox(height: 24),

                    _buildProgress(),

                    const SizedBox(height: 30),

                    _buildMoodSection(),

                    const SizedBox(height: 30),

                    _buildIntensitySection(),

                    const SizedBox(height: 30),

                    _buildEmotionSection(),

                    const SizedBox(height: 30),

                    _buildEnergySection(),

                    const SizedBox(height: 30),

                    _buildSleepSection(),

                    const SizedBox(height: 30),

                    _buildFactorsSection(),

                    const SizedBox(height: 30),

                    _buildReflectionSection(),

                    const SizedBox(height: 24),

                    _buildInsightCard(),

                    const SizedBox(height: 26),

                    _buildSubmitButton(),

                    const SizedBox(height: 16),

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
}