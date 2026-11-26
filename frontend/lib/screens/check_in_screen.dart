import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_colors.dart';
import '../../models/mood_analysis.dart';
import 'home_screen.dart';
import 'safety_support_screen.dart';

// Same breakpoints as the home screen.
const double _kTablet = 600;
const double _kDesktop = 900;

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

  MoodAnalysis? _moodAnalysis;
  String? _aiError;

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
    {'label': 'Low', 'emoji': '😔'},
    {'label': 'Okay', 'emoji': '😕'},
    {'label': 'Neutral', 'emoji': '😐'},
    {'label': 'Good', 'emoji': '🙂'},
    {'label': 'Great', 'emoji': '😊'},
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

  // ==========================================================
  // PROGRESS
  // ==========================================================

  List<MapEntry<String, bool>> get _steps => [
    MapEntry('Overall mood', _selectedMood != -1),
    MapEntry('Mood intensity', _intensitySelected),
    MapEntry('Emotions', _selectedEmotions.isNotEmpty),
    MapEntry('Energy level', _energySelected),
    MapEntry('Sleep quality', _sleepSelected),
    MapEntry('Influences', _selectedFactors.isNotEmpty),
  ];

  double _calculateProgress() {
    final done = _steps.where((s) => s.value).length;
    return done / _steps.length;
  }

  // ==========================================================
  // SUBMIT (logic unchanged)
  // ==========================================================

  Future<void> _submitCheckIn() async {
    setState(() {
      _moodError = null;
      _intensityError = null;
      _emotionError = null;
      _energyError = null;
      _sleepError = null;
      _factorError = null;
      _aiError = null;

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

    if (_moodError != null ||
        _intensityError != null ||
        _emotionError != null ||
        _energyError != null ||
        _sleepError != null ||
        _factorError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    bool checkInSaved = false;

    try {
      // 1. Get logged-in user's email.
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('logged_in_email');

      if (email == null || email.isEmpty) {
        throw Exception('No logged-in account found.');
      }

      // 2. Get backend URL.
      final baseUrl = dotenv.env['API_BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('API base URL is not configured.');
      }

      // 3. Prepare check-in data.
      final checkInData = {
        'email': email,
        'mood': _moods[_selectedMood]['label'],
        'moodIntensity': _moodIntensity.round(),
        'emotions': _selectedEmotions.toList(),
        'energyLevel': _energyLevel.round(),
        'sleepQuality': _sleepQuality.round(),
        'factors': _selectedFactors.toList(),
        'reflection': _reflectionController.text.trim(),
      };

      // 4. Save check-in and run backend crisis detection FIRST.
      final saveResponse = await http.post(
        Uri.parse('$baseUrl/api/check-ins'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(checkInData),
      );

      if (!mounted) return;

      if (saveResponse.statusCode != 201) {
        debugPrint('CHECK-IN SAVE ERROR: ${saveResponse.body}');
        throw Exception('Unable to save your check-in. Please try again.');
      }

      checkInSaved = true;

      // 5. Read the crisis detection result.
      final saveData =
      jsonDecode(saveResponse.body) as Map<String, dynamic>;

      final crisisData = saveData['crisisDetection'] as Map<String, dynamic>?;

      final crisisDetected = crisisData?['detected'] == true;

      debugPrint('CHECK-IN SAVED SUCCESSFULLY');
      debugPrint('CRISIS DETECTED: $crisisDetected');

      // 6. If a potential crisis is detected, open Safety Support.
      // Do not wait for Gemini mood analysis.
      if (crisisDetected) {
        setState(() {
          _isSubmitting = false;
        });

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SafetySupportScreen(),
          ),
        );

        return;
      }

      // 7. No crisis detected: run the existing Gemini mood analysis.
      final aiResponse = await http.post(
        Uri.parse(ApiConfig.moodAnalysisUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mood': checkInData['mood'],
          'moodIntensity': checkInData['moodIntensity'],
          'emotions': checkInData['emotions'],
          'energyLevel': checkInData['energyLevel'],
          'sleepQuality': checkInData['sleepQuality'],
          'factors': checkInData['factors'],
          'reflection': checkInData['reflection'],
        }),
      );

      if (!mounted) return;

      if (aiResponse.statusCode != 200) {
        debugPrint('MOOD AI ERROR: ${aiResponse.body}');

        setState(() {
          _isSubmitting = false;
          _aiError =
          'Your check-in was saved, but your mood insight is unavailable right now.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_aiError!),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );

        return;
      }

      // 8. Parse Gemini analysis.
      final aiData = jsonDecode(aiResponse.body);
      final analysis = MoodAnalysis.fromJson(aiData);

      if (!mounted) return;

      // 9. Show the MindMate Insight dialog.
      setState(() {
        _moodAnalysis = analysis;
        _isSubmitting = false;
      });

      _showMoodAnalysisDialog();
    } catch (error) {
      if (!mounted) return;

      debugPrint('CHECK-IN ERROR: $error');

      setState(() {
        _isSubmitting = false;
        _aiError = checkInSaved
            ? 'Your check-in was saved, but an additional service is unavailable.'
            : error.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_aiError!),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ==========================================================
  // INSIGHT DIALOG
  // ==========================================================

  void _showMoodAnalysisDialog() {
    final analysis = _moodAnalysis;

    if (analysis == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderMint),
                        ),
                        child: const Center(
                          child: Text('🌿', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Your MindMate Insight',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.lightMint,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderMint),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.mood_rounded,
                              color: AppColors.mint,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRIMARY EMOTION',
                                  style: TextStyle(
                                    color:
                                    AppColors.navy.withValues(alpha: 0.5),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  analysis.primaryEmotion,
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              analysis.intensity,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'What MindMate noticed',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      analysis.summary,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.65),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'A few things you can try',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...analysis.suggestions.map(
                          (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.mint,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  color: AppColors.navy.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // SHARED BUILDING BLOCKS
  // ==========================================================

  /// White rounded card. Border turns red when [error] is set.
  Widget _card({required Widget child, String? error}) {
    final hasError = error != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasError
              ? Colors.red.withValues(alpha: 0.55)
              : AppColors.borderMint,
          width: hasError ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (hasError) _buildInlineError(error),
        ],
      ),
    );
  }

  Widget _cardHeader(
      IconData icon,
      String title,
      String subtitle, {
        Widget? trailing,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.mint, size: 20),
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
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing,
        ],
      ],
    );
  }

  Widget _valueChip(String text, {required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.mint : AppColors.lightMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInlineError(String? error) {
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 2),
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
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required bool selected,
    required String leftLabel,
    required String rightLabel,
    required ValueChanged<double> onChanged,
    String? error,
  }) {
    return _card(
      error: error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            icon,
            title,
            subtitle,
            trailing: _valueChip(
              selected ? '${value.round()}/10' : 'Select',
              active: selected,
            ),
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.mint,
              inactiveTrackColor: AppColors.lightMint,
              thumbColor: AppColors.mint,
              overlayColor: AppColors.mint.withValues(alpha: 0.14),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftLabel,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
                Text(
                  rightLabel,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipWrap({
    required List<String> options,
    required Set<String> selectedSet,
    required ValueChanged<String> onTap,
  }) {
    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: options.map((option) {
        final selected = selectedSet.contains(option);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onTap(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.lightMint : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? AppColors.mint : AppColors.borderMint,
                  width: selected ? 1.4 : 1,
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
                    option,
                    style: TextStyle(
                      color: selected
                          ? AppColors.navy
                          : AppColors.navy.withValues(alpha: 0.65),
                      fontSize: 12.5,
                      fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Puts two cards side by side when there is room, otherwise stacks them.
  Widget _pair(Widget a, Widget b, bool twoCol) {
    if (!twoCol) {
      return Column(
        children: [a, const SizedBox(height: 18), b],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 18),
          Expanded(child: b),
        ],
      ),
    );
  }

  // ==========================================================
  // FORM SECTIONS
  // ==========================================================

  Widget _buildMoodSection(bool roomy) {
    return _card(
      error: _moodError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.mood_rounded,
            'Overall mood',
            'Choose the option that best describes how you feel.',
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_moods.length, (index) {
              final mood = _moods[index];
              final selected = _selectedMood == index;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == _moods.length - 1 ? 0 : (roomy ? 12 : 7),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = index;
                          _moodError = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          vertical: roomy ? 18 : 13,
                          horizontal: 3,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.lightMint
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? AppColors.mint
                                : AppColors.borderMint,
                            width: selected ? 1.6 : 1,
                          ),
                          boxShadow: selected
                              ? [
                            BoxShadow(
                              color:
                              AppColors.mint.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            AnimatedScale(
                              scale: selected ? 1.15 : 1,
                              duration: const Duration(milliseconds: 180),
                              child: Text(
                                mood['emoji']!,
                                style: TextStyle(fontSize: roomy ? 32 : 25),
                              ),
                            ),
                            SizedBox(height: roomy ? 9 : 6),
                            Text(
                              mood['label']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.navy
                                    : AppColors.navy.withValues(alpha: 0.55),
                                fontSize: roomy ? 12.5 : 10.5,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityCard() {
    return _sliderCard(
      icon: Icons.speed_rounded,
      title: 'Mood intensity',
      subtitle: 'How strongly are you feeling this mood?',
      value: _moodIntensity,
      selected: _intensitySelected,
      leftLabel: 'Very low',
      rightLabel: 'Very high',
      error: _intensityError,
      onChanged: (value) {
        setState(() {
          _moodIntensity = value;
          _intensitySelected = true;
          _intensityError = null;
        });
      },
    );
  }

  Widget _buildEnergyCard() {
    return _sliderCard(
      icon: Icons.bolt_rounded,
      title: 'Energy level',
      subtitle: 'How much energy do you have today?',
      value: _energyLevel,
      selected: _energySelected,
      leftLabel: 'Exhausted',
      rightLabel: 'Full of energy',
      error: _energyError,
      onChanged: (value) {
        setState(() {
          _energyLevel = value;
          _energySelected = true;
          _energyError = null;
        });
      },
    );
  }

  Widget _buildSleepCard() {
    return _sliderCard(
      icon: Icons.bedtime_outlined,
      title: 'Sleep quality',
      subtitle: 'How would you describe your sleep?',
      value: _sleepQuality,
      selected: _sleepSelected,
      leftLabel: 'Very poor',
      rightLabel: 'Excellent',
      error: _sleepError,
      onChanged: (value) {
        setState(() {
          _sleepQuality = value;
          _sleepSelected = true;
          _sleepError = null;
        });
      },
    );
  }

  Widget _buildEmotionCard() {
    return _card(
      error: _emotionError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.favorite_border_rounded,
            'What are you feeling?',
            'Select all emotions that feel relevant right now.',
            trailing: _valueChip(
              '${_selectedEmotions.length} selected',
              active: _selectedEmotions.isNotEmpty,
            ),
          ),
          const SizedBox(height: 16),
          _chipWrap(
            options: _emotions,
            selectedSet: _selectedEmotions,
            onTap: (emotion) {
              setState(() {
                if (_selectedEmotions.contains(emotion)) {
                  _selectedEmotions.remove(emotion);
                } else {
                  _selectedEmotions.add(emotion);
                }

                if (_selectedEmotions.isNotEmpty) {
                  _emotionError = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsCard() {
    return _card(
      error: _factorError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.hub_outlined,
            'What influenced your mood?',
            'Choose anything that may have affected how you feel.',
          ),
          const SizedBox(height: 16),
          _chipWrap(
            options: _factors,
            selectedSet: _selectedFactors,
            onTap: (factor) {
              setState(() {
                final selected = _selectedFactors.contains(factor);

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
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.edit_note_rounded,
            'Reflection',
            'Optional — write whatever is on your mind.',

          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderMint),
            ),
            child: TextField(
              controller: _reflectionController,
              maxLines: 5,
              maxLength: 500,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 14,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Write a few thoughts...',
                hintStyle: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.35),
                  fontSize: 13.5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _formSections(bool twoCol, bool roomy) {
    const gap = SizedBox(height: 18);

    return [
      _buildMoodSection(roomy),
      gap,
      _buildEmotionCard(),
      gap,
      _pair(_buildIntensityCard(), _buildEnergyCard(), twoCol),
      gap,
      _pair(_buildSleepCard(), _buildFactorsCard(), twoCol),
      gap,
      _buildReflectionCard(),
    ];
  }

  // ==========================================================
  // HEADER / INTRO / PROGRESS / SUBMIT
  // ==========================================================


  Widget _buildTopBar({required bool wide}) {
    final done = _steps.where((s) => s.value).length;

    return Row(
      children: [
        if (!wide) ...[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: widget.onBackToHome,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 44,
                  height: 44,
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
          ),
          const SizedBox(width: 14),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Check-in',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (!wide) ...[
                const SizedBox(height: 3),
                Text(
                  '$done of ${_steps.length} completed',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.mint,
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                '$done/${_steps.length}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildIntro({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wide ? 'How are you\nfeeling today?' : 'How are you feeling today?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: wide ? 34 : 27,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Take a moment to notice what is happening within you.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Compact progress bar for mobile / tablet.
  Widget _buildProgressCompact() {
    final progress = _calculateProgress();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF29495A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.mint,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your daily check-in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A few moments for yourself can make a difference.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
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

  /// Progress card with checklist for the desktop side panel.
  Widget _buildProgressPanel() {
    final progress = _calculateProgress();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF29495A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.mint,
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Your progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 14),
          for (final step in _steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: step.value
                          ? AppColors.mint
                          : Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.value
                            ? AppColors.mint
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: step.value
                        ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    step.key,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: step.value ? 1 : 0.6),
                      fontSize: 13.5,
                      fontWeight:
                      step.value ? FontWeight.w700 : FontWeight.w500,
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
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          disabledBackgroundColor: AppColors.mint.withValues(alpha: 0.6),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 20),
            SizedBox(width: 9),
            Text(
              'Complete Check-in',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          color: AppColors.navy.withValues(alpha: 0.38),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          'Your check-in is private and personal.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.45),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final wide = w >= _kDesktop;
            final medium = !wide && w >= _kTablet;

            final hPad = wide
                ? 40.0
                : medium
                ? 28.0
                : 20.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        wide ? 28 : 16,
                        hPad,
                        wide ? 16 : 12,
                      ),
                      child: _buildTopBar(wide: wide),
                    ),

                    Container(
                      height: 1.5,
                      margin: EdgeInsets.symmetric(horizontal: hPad),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: wide
                          ? _buildWideBody(hPad)
                          : _buildNarrowBody(hPad, medium),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Desktop: fixed left panel + independently scrolling form.
  Widget _buildWideBody(double hPad) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360 + hPad,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 6, 22, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntro(wide: true),
                const SizedBox(height: 26),
                _buildProgressPanel(),
                const SizedBox(height: 18),
                _buildSubmitButton(),
                const SizedBox(height: 14),
                _buildPrivacyNote(),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(6, 6, hPad, 40),
            child: Column(
              children: _formSections(true, true),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile / tablet: single scrolling column of cards.
  Widget _buildNarrowBody(double hPad, bool medium) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 36),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntro(wide: false),
              const SizedBox(height: 20),
              _buildProgressCompact(),
              const SizedBox(height: 22),
              ..._formSections(medium, medium),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              _buildPrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}
