import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MoodLiftScreen extends StatefulWidget {
  const MoodLiftScreen({super.key});

  @override
  State<MoodLiftScreen> createState() => _MoodLiftScreenState();
}

class _MoodLiftScreenState extends State<MoodLiftScreen> {
  int _currentStep = 0;

  int _moodLevel = 3;
  int _energyLevel = 3;

  String? _selectedMood;
  String? _selectedLift;
  String? _selectedMemory;

  bool _completed = false;

  String? _moodError;
  String? _liftError;
  String? _memoryError;

  final List<String> _moodOptions = [
    'Low',
    'Drained',
    'Restless',
    'Heavy',
    'Flat',
    'Okay',
  ];

  final List<String> _liftOptions = [
    'Move my body',
    'Change my surroundings',
    'Connect with someone',
    'Do something creative',
    'Give myself a quiet moment',
    'Finish one tiny task',
  ];

  final List<String> _memoryOptions = [
    'A place where I felt peaceful',
    'Something that made me laugh',
    'A person who makes me feel safe',
    'A small moment I am grateful for',
    'Something I was proud of',
  ];

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),

                    const SizedBox(height: 24),

                    _buildStepIndicator(),

                    const SizedBox(height: 26),

                    if (_currentStep == 0) _buildMoodCheck(),
                    if (_currentStep == 1) _buildEnergyCheck(),
                    if (_currentStep == 2) _buildLiftChoice(),
                    if (_currentStep == 3) _buildMemorySpark(),
                    if (_currentStep == 4) _buildLiftPlan(),

                    const SizedBox(height: 26),

                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.navy,
                    size: 15,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mood Lift',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find one small shift that feels possible.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 40,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightMint,
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.mint,
                  size: 31,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'You do not need to feel amazing.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'Sometimes a mood lift is simply moving from '
                '“really hard” to “a little easier.” Let’s find '
                'a small shift that matches what you need today.',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(
        5,
            (index) {
          final active = index <= _currentStep;

          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(
                right: index == 4 ? 0 : 6,
              ),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.mint
                    : AppColors.borderMint,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodCheck() {
    return _buildSectionCard(
      title: '1. Name the weather',
      subtitle:
      'You do not have to explain your mood. Just choose '
          'the closest description.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How does your mood feel right now?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
                  (index) {
                final level = index + 1;
                final selected = _moodLevel == level;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _moodLevel = level;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : AppColors.lightMint,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : AppColors.borderMint,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 9),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Very low',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              Text(
                'Feeling good',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'What does your mood feel like?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _moodOptions.map(
                  (mood) {
                final selected = _selectedMood == mood;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                      _moodError = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : AppColors.borderMint,
                      ),
                    ),
                    child: Text(
                      mood,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.navy,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          if (_moodError != null) ...[
            const SizedBox(height: 10),
            _buildInlineError(_moodError!),
          ],
        ],
      ),
    );
  }

  Widget _buildEnergyCheck() {
    return _buildSectionCard(
      title: '2. Check your energy',
      subtitle:
      'The best mood-lifting action depends on the energy '
          'you actually have — not the energy you wish you had.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How much energy do you have available?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(
            5,
                (index) {
              final level = index + 1;
              final selected = _energyLevel == level;

              final labels = [
                'Almost none',
                'A little',
                'Some energy',
                'Quite a bit',
                'Ready to move',
              ];

              final icons = [
                Icons.battery_0_bar_rounded,
                Icons.battery_2_bar_rounded,
                Icons.battery_4_bar_rounded,
                Icons.battery_5_bar_rounded,
                Icons.battery_full_rounded,
              ];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _energyLevel = level;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(13),
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
                  child: Row(
                    children: [
                      Icon(
                        icons[index],
                        color: selected
                            ? AppColors.mint
                            : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 13,
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
                          size: 21,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.mint,
                  size: 20,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Low energy is still valid information. '
                        'Your plan should meet you where you are.',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiftChoice() {
    return _buildSectionCard(
      title: '3. Pick your kind of lift',
      subtitle:
      'Choose one option. There is no need to do everything.',
      child: Column(
        children: [
          ..._liftOptions.asMap().entries.map(
                (entry) {
              final index = entry.key;
              final option = entry.value;
              final selected = _selectedLift == option;

              final icons = [
                Icons.directions_walk_rounded,
                Icons.change_circle_outlined,
                Icons.people_alt_outlined,
                Icons.brush_outlined,
                Icons.self_improvement_rounded,
                Icons.task_alt_rounded,
              ];

              final descriptions = [
                'Stretch, walk, dance, or move for a few minutes.',
                'Open a window, change rooms, or step somewhere different.',
                'Send a message, make a call, or sit with someone.',
                'Draw, write, make something, or play with an idea.',
                'Take a quiet pause without demanding productivity.',
                'Complete one tiny task that has been sitting in your mind.',
              ];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLift = option;
                    _liftError = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(bottom: 11),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.lightMint
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? AppColors.mint
                          : AppColors.borderMint,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.mint
                              : AppColors.lightMint,
                          borderRadius:
                          BorderRadius.circular(13),
                        ),
                        child: Icon(
                          icons[index],
                          color: selected
                              ? Colors.white
                              : AppColors.mint,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              descriptions[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
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
              );
            },
          ),
          if (_liftError != null) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildInlineError(_liftError!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemorySpark() {
    return _buildSectionCard(
      title: '4. Add a small spark',
      subtitle:
      'Bring one gentle memory into the present. '
          'You are not trying to recreate it — just notice it.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.mint,
                  size: 23,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'A tiny positive memory can act like an '
                        'emotional bookmark.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Which memory would you like to bring to mind?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._memoryOptions.map(
                (memory) {
              final selected = _selectedMemory == memory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMemory = memory;
                    _memoryError = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
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
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? AppColors.mint
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          memory,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_memoryError != null) ...[
            const SizedBox(height: 2),
            _buildInlineError(_memoryError!),
          ],
        ],
      ),
    );
  }

  Widget _buildLiftPlan() {
    return _buildSectionCard(
      title: '5. Build your lift plan',
      subtitle:
      'Here is your small experiment for the next few minutes.',
      child: Column(
        children: [
          _buildPlanRow(
            icon: Icons.mood_rounded,
            label: 'Current mood',
            value: '$_moodLevel / 5',
          ),
          const SizedBox(height: 10),
          _buildPlanRow(
            icon: Icons.battery_charging_full_rounded,
            label: 'Available energy',
            value: '$_energyLevel / 5',
          ),
          const SizedBox(height: 10),
          _buildPlanRow(
            icon: Icons.rocket_launch_rounded,
            label: 'Your chosen lift',
            value: _selectedLift ?? 'Not selected',
          ),
          const SizedBox(height: 10),
          _buildPlanRow(
            icon: Icons.auto_awesome_rounded,
            label: 'Memory spark',
            value: _selectedMemory ?? 'Not selected',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      color: AppColors.mint,
                      size: 21,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Your tiny mission',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _buildMissionText(),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildMissionText() {
    switch (_selectedLift) {
      case 'Move my body':
        return 'Move for 3–5 minutes. Stretch your shoulders, '
            'walk around, or put on one song and move with it.';

      case 'Change my surroundings':
        return 'Change one thing around you: open a window, '
            'step outside, move to another room, or tidy one '
            'small surface.';

      case 'Connect with someone':
        return 'Reach out to one person with a simple message '
            'such as “Hey, just checking in.” No long conversation '
            'required.';

      case 'Do something creative':
        return 'Spend 5 minutes making something with no pressure '
            'for it to be good — sketch, write, doodle, or create.';

      case 'Give myself a quiet moment':
        return 'Put your phone aside for a few minutes, get '
            'comfortable, and allow yourself to simply pause.';

      case 'Finish one tiny task':
        return 'Choose one task that takes less than 5 minutes '
            'and finish only that. Let “done” be enough for now.';

      default:
        return 'Choose one gentle action that could make the next '
            'few minutes feel slightly easier.';
    }
  }

  Widget _buildNavigationButtons() {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == 4;

    return Row(
      children: [
        if (!isFirstStep) ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.borderMint,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleNext,
              icon: Icon(
                isLastStep
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                isLastStep
                    ? 'Complete Mood Lift'
                    : 'Continue',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    bool valid = true;

    setState(() {
      if (_currentStep == 0) {
        if (_selectedMood == null) {
          _moodError =
          'Please choose the mood description that feels closest to you.';
          valid = false;
        } else {
          _moodError = null;
        }
      }

      if (_currentStep == 2) {
        if (_selectedLift == null) {
          _liftError =
          'Please choose one mood-lifting activity to continue.';
          valid = false;
        } else {
          _liftError = null;
        }
      }

      if (_currentStep == 3) {
        if (_selectedMemory == null) {
          _memoryError =
          'Please choose one memory spark before continuing.';
          valid = false;
        } else {
          _memoryError = null;
        }
      }
    });

    if (!valid) {
      return;
    }

    if (_currentStep == 4) {
      setState(() {
        _completed = true;
      });
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  Widget _buildInlineError(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 17,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 21,
          ),
          const SizedBox(width: 11),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 19),
          child,
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                6,
              ),
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.borderMint,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.navy,
                            size: 15,
                          ),
                        ),
                      ),
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          'Mood Lift Complete',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  30,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wb_sunny_rounded,
                        color: AppColors.mint,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'You found one small shift.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'You checked in with yourself, noticed what '
                          'you needed, and created a manageable next step.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildResultSummary(),

                    const SizedBox(height: 20),

                    _buildFinalMissionCard(),

                    const SizedBox(height: 20),

                    _buildResultReminder(),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentStep = 0;
                            _moodLevel = 3;
                            _energyLevel = 3;
                            _selectedMood = null;
                            _selectedLift = null;
                            _selectedMemory = null;
                            _completed = false;
                            _moodError = null;
                            _liftError = null;
                            _memoryError = null;
                          });
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: const Text(
                          'Try Again',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.borderMint,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildSafetyNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your check-in',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildResultMetric(
                  icon: Icons.mood_rounded,
                  title: 'Mood',
                  value: '$_moodLevel / 5',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResultMetric(
                  icon: Icons.battery_charging_full_rounded,
                  title: 'Energy',
                  value: '$_energyLevel / 5',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildResultDetail(
            icon: Icons.psychology_alt_rounded,
            title: 'Mood state',
            value: _selectedMood ?? '',
          ),

          const SizedBox(height: 10),

          _buildResultDetail(
            icon: Icons.auto_awesome_rounded,
            title: 'Memory spark',
            value: _selectedMemory ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildResultMetric({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 22,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
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
      ),
    );
  }

  Widget _buildFinalMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.flag_rounded,
                color: AppColors.mint,
                size: 23,
              ),
              SizedBox(width: 10),
              Text(
                'Your tiny mission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            _buildMissionText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.mint,
                  size: 19,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'The goal is not to force a happy mood. '
                        'The goal is to create one small positive shift.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: AppColors.mint,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Whatever your mood is today, you do not have '
                  'to fix everything at once. One manageable step '
                  'is enough for this moment.',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'MindMate exercises are general wellbeing tools '
                  'and are not a substitute for professional mental-health '
                  'care. If you feel unsafe or are in immediate danger, '
                  'seek appropriate emergency or professional support.',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}