import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StudentWellbeingScreen extends StatefulWidget {
  const StudentWellbeingScreen({super.key});

  @override
  State<StudentWellbeingScreen> createState() =>
      _StudentWellbeingScreenState();
}

class _StudentWellbeingScreenState
    extends State<StudentWellbeingScreen> {
  int _currentQuestion = 0;

  final List<int?> _answers = List<int?>.filled(20, null);

  final List<String> _questions = [
    'How often have you felt stressed because of your studies?',
    'How often have you felt overwhelmed by your academic workload?',
    'How often have you worried about your academic performance?',
    'How often have you found it difficult to concentrate while studying?',
    'How often have you struggled to manage your study time?',
    'How often have you felt pressure to achieve good grades?',
    'How often have you postponed academic tasks because they felt overwhelming?',
    'How often have you felt mentally exhausted after studying?',
    'How often have you had difficulty balancing studies with personal life?',
    'How often have you compared your academic progress with other students?',
    'How often have you felt that you were not meeting your academic expectations?',
    'How often have you lost motivation to study?',
    'How often have academic responsibilities affected your sleep?',
    'How often have you felt anxious before exams or important assignments?',
    'How often have you found it difficult to relax because of academic responsibilities?',
    'How often have you felt burned out from studying?',
    'How often have you avoided asking for help with academic difficulties?',
    'How often have your studies affected your relationships or social life?',
    'How often have academic stress affected your overall mood?',
    'Overall, how often have your studies negatively affected your wellbeing recently?',
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
                  Icons.school_rounded,
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
          'Student Wellbeing',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
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
              Icons.school_rounded,
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
                  'Student Wellbeing Check',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reflect on your academic pressure and overall student experience.',
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