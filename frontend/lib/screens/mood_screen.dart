import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;
  double? _intensity;

  String? _moodError;
  String? _intensityError;
  String? _reasonError;
  String? _commentError;

  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😄',
      'label': 'Very Happy',
      'color': Color(0xFFF5C96A),
    },
    {
      'emoji': '🙂',
      'label': 'Happy',
      'color': Color(0xFF8CCF9F),
    },
    {
      'emoji': '😐',
      'label': 'Okay',
      'color': Color(0xFF8DB3C7),
    },
    {
      'emoji': '😔',
      'label': 'Sad',
      'color': Color(0xFF8A9BD1),
    },
    {
      'emoji': '😞',
      'label': 'Very Sad',
      'color': Color(0xFF9A82B8),
    },
  ];

  final List<String> _factors = [
    'Studies',
    'Work',
    'Family',
    'Friends',
    'Sleep',
    'Health',
    'Relationships',
    'Other',
  ];

  final Set<String> _selectedFactors = {};

  final TextEditingController _noteController =
  TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMood = index;
    });
  }

  void _toggleFactor(String factor) {
    setState(() {
      if (_selectedFactors.contains(factor)) {
        _selectedFactors.remove(factor);
      } else {
        _selectedFactors.add(factor);
      }

      if (_selectedFactors.isNotEmpty) {
        _reasonError = null;
      }
    });
  }

  void _saveMood() {
    setState(() {
      _moodError = null;
      _intensityError = null;
      _reasonError = null;
      _commentError = null;

      if (_selectedMood == null) {
        _moodError = 'Please select your mood.';
      }

      if (_intensity == null) {
        _intensityError = 'Please select your mood intensity.';
      }

      if (_selectedFactors.isEmpty) {
        _reasonError = 'Please select at least one reason.';
      }

      if (_noteController.text.trim().isEmpty) {
        _commentError = 'Write a short note about how you are feeling.';
      }
    });

    if (_moodError != null ||
        _intensityError != null ||
        _reasonError != null ||
        _commentError != null) {
      return;
    }

    final mood = _moods[_selectedMood!]['label'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            16,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.mint,
                  size: 38,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Mood Check-In Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Thank you for taking a moment to check in with yourself.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _moods[_selectedMood!]['emoji'],
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      mood,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Intensity: ${_intensity!.round()} / 10',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.55),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 20,
          ),
        ),
        title: const Text(
          'Mood Tracker',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              const Text(
                'How are you feeling?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Choose the mood that best describes you right now.',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.52),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              _buildMoodSelector(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Mood intensity',
                'How strongly are you feeling this mood?',
              ),

              const SizedBox(height: 18),

              _buildIntensitySelector(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'What may be affecting your mood?',
                'Select all that apply.',
              ),

              const SizedBox(height: 15),

              _buildFactors(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Add a note',
                'Optional — write anything you would like to remember.',
              ),

              const SizedBox(height: 15),

              _buildNoteField(),

              const SizedBox(height: 30),

              _buildSaveButton(),

              const SizedBox(height: 18),

              _buildPrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF294253),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.mood_rounded,
              color: AppColors.mint,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Mood Check',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Take a moment to check in with yourself.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
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

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _moods.length,
                (index) {
              final selected = _selectedMood == index;
              final mood = _moods[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = index;
                    _moodError = null;
                  });
                },
                child: SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: selected
                              ? mood['color'].withValues(alpha: 0.20)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? mood['color']
                                : AppColors.borderMint,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            mood['emoji'],
                            style: const TextStyle(fontSize: 27),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_moodError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_moodError!),
        ],
      ],
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 14,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.50),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            14,
            16,
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _intensityError != null
                  ? Colors.red
                  : AppColors.borderMint,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '1',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _intensity ?? 5,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.mint,
                      inactiveColor: AppColors.lightMint,
                      onChanged: (value) {
                        setState(() {
                          _intensity = value;
                          _intensityError = null;
                        });
                      },
                    ),
                  ),
                  const Text(
                    '10',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                _intensity == null
                    ? 'Select intensity'
                    : 'Intensity: ${_intensity!.round()} / 10',
                style: TextStyle(
                  color: _intensityError != null
                      ? Colors.red
                      : AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        if (_intensityError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_intensityError!),
        ],
      ],
    );
  }

  Widget _buildFactors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: _factors.map(
                (factor) {
              final selected =
              _selectedFactors.contains(factor);

              return GestureDetector(
                onTap: () {
                  _toggleFactor(factor);
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
                    borderRadius: BorderRadius.circular(13),
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
            },
          ).toList(),
        ),

        if (_reasonError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_reasonError!),
        ],
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _noteController,
          maxLines: 4,
          maxLength: 300,
          onChanged: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _commentError = null;
              });
            }
          },
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: 'How are you feeling today?',
            hintStyle: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 11,
            ),
            filled: true,
            fillColor: Colors.white,
            counterStyle: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 9,
            ),
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.mint,
                width: 1.4,
              ),
            ),
          ),
        ),

        if (_commentError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_commentError!),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _saveMood,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              size: 19,
            ),
            SizedBox(width: 7),
            Text(
              'Save Mood',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.mint,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your mood entries are private and are currently stored only for this session.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.60),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}