import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class DepressionMoodScreen extends StatefulWidget {
  const DepressionMoodScreen({super.key});

  @override
  State<DepressionMoodScreen> createState() =>
      _DepressionMoodScreenState();
}

class _DepressionMoodScreenState extends State<DepressionMoodScreen> {
  int _currentQuestion = 0;

  final List<int?> _answers = List<int?>.filled(20, null);

  final List<String> _questions = [
    'How often have you felt down, sad, or emotionally low?',
    'How often have you had little interest or pleasure in activities?',
    'How often have you felt tired or had little energy?',
    'How often have you found it difficult to get motivated?',
    'How often have you felt hopeless about the future?',
    'How often have you felt that everyday tasks were difficult to manage?',
    'How often have you had trouble concentrating on things?',
    'How often have you felt emotionally overwhelmed?',
    'How often have you felt lonely even when around other people?',
    'How often have you felt less confident in yourself?',
    'How often have you been unusually critical of yourself?',
    'How often have you felt that you were not doing well enough?',
    'How often have you experienced changes in your sleeping pattern?',
    'How often have you experienced changes in your appetite?',
    'How often have you preferred staying away from social activities?',
    'How often have you found it difficult to enjoy things you normally like?',
    'How often have you felt emotionally disconnected from others?',
    'How often have you struggled to keep up with your usual responsibilities?',
    'How often have your mood changes affected your daily life?',
    'Overall, how often have you experienced low mood or reduced enjoyment recently?',
  ];

  final List<String> _options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  void _selectAnswer(int index) {
    setState(() {
      _answers[_currentQuestion] = index;
    });
  }

  void _nextQuestion() {
    if (_answers[_currentQuestion] == null) {
      _showMessage('Please select an answer first.');
      return;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      _showResult();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion == 0) {
      return;
    }

    setState(() {
      _currentQuestion--;
    });
  }

  void _showResult() {
    int score = 0;

    for (final answer in _answers) {
      if (answer != null) {
        score += answer!;
      }
    }

    String level;

    if (score <= 10) {
      level = 'Low';
    } else if (score <= 20) {
      level = 'Mild';
    } else if (score <= 30) {
      level = 'Moderate';
    } else {
      level = 'Higher';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Assessment Complete',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: const BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  color: AppColors.mint,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Your current result',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                level,
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score / 60',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'This result is for wellbeing awareness only and is not a medical diagnosis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 10.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
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

  @override
  Widget build(BuildContext context) {
    final progress =
        (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(
            18,
            30,
            18,
            10,
          ),
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
                    'Assessments',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 34),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopCard(),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Text(
                          'Question ${_currentQuestion + 1} of ${_questions.length}',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: AppColors.navy.withValues(
                              alpha: 0.45,
                            ),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: AppColors.lightMint,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          AppColors.mint,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      _questions[_currentQuestion],
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 26),

                    ...List.generate(
                      _options.length,
                          (index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: _buildAnswerOption(
                            index: index,
                            text: _options[index],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildInfoNote(),
                  ],
                ),
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF294253),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.sentiment_satisfied_alt_rounded,
              color: AppColors.mint,
              size: 26,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Depression & Mood Check',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Answer based on how you have been feeling recently.',
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

  Widget _buildAnswerOption({
    required int index,
    required String text,
  }) {
    final selected =
        _answers[_currentQuestion] == index;

    return GestureDetector(
      onTap: () {
        _selectAnswer(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : AppColors.borderMint,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.mint
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.mint
                      : AppColors.navy.withValues(alpha: 0.20),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 12.5,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 17,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'There are no right or wrong answers. Choose the option that best describes your experience.',
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

  Widget _buildBottomBar() {
    final isFirst = _currentQuestion == 0;
    final isLast =
        _currentQuestion == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderMint.withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isFirst)
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  onPressed: _previousQuestion,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                  ),
                ),
              ),

            if (!isFirst)
              const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _nextQuestion,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast
                            ? 'See Result'
                            : 'Next Question',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}