
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/assessment_service.dart';

class Who5Screen extends StatefulWidget {
  const Who5Screen({super.key});

  @override
  State<Who5Screen> createState() => _Who5ScreenState();
}

class _Who5ScreenState extends State<Who5Screen> {
  int _currentQuestion = 0;
  bool _isSaving = false;

  final List<int?> _answers = List<int?>.filled(5, null);

  final List<String> _questions = [
    'I have felt cheerful and in good spirits.',
    'I have felt calm and relaxed.',
    'I have felt active and vigorous.',
    'I woke up feeling fresh and rested.',
    'My daily life has been filled with things that interest me.',
  ];

  final List<String> _options = [
    'All of the time',
    'Most of the time',
    'More than half of the time',
    'Less than half of the time',
    'Some of the time',
    'At no time',
  ];

  void _selectAnswer(int index) {
    setState(() {
      _answers[_currentQuestion] = 5 - index;
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
    if (_currentQuestion == 0) return;

    setState(() {
      _currentQuestion--;
    });
  }

  int get _score =>
      _answers.fold(0, (sum, answer) => sum + (answer ?? 0));

  int get _percentageScore => _score * 4;

  String get _resultLevel =>
      _percentageScore < 50 ? 'Poor Wellbeing' : 'Adequate Wellbeing';

  Future<void> _showResult() async {
    if (_isSaving) return;

    final answers = _answers.map((answer) => answer!).toList();

    setState(() {
      _isSaving = true;
    });

    try {
      await AssessmentService.saveAssessment(
        assessmentType: 'who5',
        answers: answers,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showResultDialog();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'WHO-5 Complete',
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
                  Icons.favorite_outline_rounded,
                  color: AppColors.mint,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Your WHO-5 result',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _resultLevel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Raw Score: $_score / 25',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Wellbeing Index: $_percentageScore / 100',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'This screening result is for wellbeing awareness. '
                    'It is not a medical diagnosis. If your score is below '
                    '50, consider speaking with a qualified professional.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.60),
                  fontSize: 10.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your assessment has been saved successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(18, 30, 18, 10),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
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
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'WHO-5 Assessment',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
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
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 25),
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
                            color: AppColors.navy.withValues(alpha: 0.45),
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

                    const SizedBox(height: 25),

                    Text(
                      _questions[_currentQuestion],
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ...List.generate(
                      _options.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAnswerOption(
                          index: index,
                          text: _options[index],
                        ),
                      ),
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
              Icons.favorite_outline_rounded,
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
                  'WHO-5 Well-Being Index',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Think about how you have been feeling over the last two weeks.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
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

  Widget _buildAnswerOption({
    required int index,
    required String text,
  }) {
    final selected = _answers[_currentQuestion] == 5 - index;

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightMint : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? AppColors.mint : AppColors.borderMint,
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
                color: selected ? AppColors.mint : Colors.transparent,
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
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
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
              'Choose one response for each statement based on your '
                  'experience over the last two weeks. There are no right '
                  'or wrong answers.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.60),
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isFirst = _currentQuestion == 0;
    final isLast = _currentQuestion == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderMint.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isFirst) ...[
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _previousQuestion,
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
              const SizedBox(width: 10),
            ],
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isSaving ? null : _nextQuestion,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSaving
                            ? 'Saving Assessment...'
                            : isLast
                            ? 'Submit Assessment'
                            : 'Next Question',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Icon(
                        _isSaving
                            ? Icons.hourglass_top_rounded
                            : isLast
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
