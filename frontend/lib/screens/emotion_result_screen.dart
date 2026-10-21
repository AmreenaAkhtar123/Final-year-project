
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class EmotionResultScreen extends StatelessWidget {
  final String emotion;
  final double confidence;

  const EmotionResultScreen({
    super.key,
    this.emotion = 'Neutral',
    this.confidence = 0.0,
  });

  // ------------------------------------------------------------
  // EMOTION EMOJI
  // ------------------------------------------------------------

  String get _emoji {
    switch (emotion) {
      case 'Happy':
        return '😊';
      case 'Sad':
        return '😔';
      case 'Angry':
        return '😠';
      case 'Fear':
        return '😨';
      case 'Disgust':
        return '🤢';
      case 'Surprise':
        return '😮';
      case 'Neutral':
        return '😐';
      default:
        return '😐';
    }
  }

  // ------------------------------------------------------------
  // EMOTION INSIGHT
  // ------------------------------------------------------------

  String get _insight {
    switch (emotion) {
      case 'Happy':
        return 'The model identified facial features associated '
            'with a happy expression. Take a moment to reflect '
            'on how you are feeling.';

      case 'Sad':
        return 'The model identified facial features associated '
            'with a sad expression. If you are feeling low, '
            'consider taking a gentle moment for yourself.';

      case 'Angry':
        return 'The model identified facial features associated '
            'with an angry expression. If you feel tense, '
            'a short pause may help you reflect.';

      case 'Fear':
        return 'The model identified facial features associated '
            'with a fearful expression. If you feel worried, '
            'try grounding yourself in the present moment.';

      case 'Disgust':
        return 'The model identified facial features associated '
            'with a disgust expression. Consider what you are '
            'experiencing and how you feel about it.';

      case 'Surprise':
        return 'The model identified facial features associated '
            'with a surprised expression. Take a moment to '
            'notice what has your attention.';

      case 'Neutral':
        return 'The model identified facial features associated '
            'with a neutral expression. You can still check in '
            'with yourself, whatever you may be feeling.';

      default:
        return 'This result is an AI estimate of a facial '
            'expression. Only you can describe how you feel.';
    }
  }

  // ------------------------------------------------------------
  // MINDFUL SUGGESTION
  // ------------------------------------------------------------

  String get _suggestion {
    switch (emotion) {
      case 'Happy':
        return 'Pause and appreciate a moment in your day '
            'that feels meaningful to you.';

      case 'Sad':
        return 'Be kind to yourself. Try a comforting activity '
            'or talk to someone you trust if you need support.';

      case 'Angry':
        return 'If it feels helpful, pause and take a few '
            'comfortable, slow breaths before responding.';

      case 'Fear':
        return 'Notice your surroundings and gently focus on '
            'five things you can see around you.';

      case 'Disgust':
        return 'Take a moment to identify what is bothering '
            'you and consider what would help you feel comfortable.';

      case 'Surprise':
        return 'Give yourself a moment to process what happened '
            'before deciding what to do next.';

      case 'Neutral':
        return 'Take a short mindful pause and ask yourself '
            'what you need right now.';

      default:
        return 'Take a moment to check in with yourself '
            'and choose an activity that feels supportive.';
    }
  }

  // ------------------------------------------------------------
  // NORMALIZED CONFIDENCE
  // ------------------------------------------------------------

  double get _safeConfidence {
    if (!confidence.isFinite) return 0.0;
    return confidence.clamp(0.0, 1.0).toDouble();
  }

  int get _percentage => (_safeConfidence * 100).round();

  // ------------------------------------------------------------
  // MAIN SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildResultCard(),
                    const SizedBox(height: 18),
                    _buildInsightCard(),
                    const SizedBox(height: 14),
                    _buildSuggestionCard(),
                    const SizedBox(height: 18),
                    _buildDisclaimer(),
                    const SizedBox(height: 22),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
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
          Expanded(
            child: Center(
              child: const Text(
                'Emotion Result',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RESULT CARD
  // ------------------------------------------------------------

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF2E4A5D),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'FACIAL EMOTION ANALYSIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.mint.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _emoji,
                style: const TextStyle(
                  fontSize: 54,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Predicted expression',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            emotion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Model confidence',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                ),
              ),
              Text(
                '$_percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _safeConfidence,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This score reflects the model prediction, '
                'not the certainty of your actual emotional state.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INSIGHT CARD
  // ------------------------------------------------------------

  Widget _buildInsightCard() {
    return _infoCard(
      icon: Icons.insights_rounded,
      title: 'What this may mean',
      text: _insight,
    );
  }

  // ------------------------------------------------------------
  // SUGGESTION CARD
  // ------------------------------------------------------------

  Widget _buildSuggestionCard() {
    return _infoCard(
      icon: Icons.spa_rounded,
      title: 'Mindful suggestion',
      text: _suggestion,
    );
  }

  // ------------------------------------------------------------
  // REUSABLE INFORMATION CARD
  // ------------------------------------------------------------

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            decoration: const BoxDecoration(
              color: AppColors.lightMint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 21,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.68),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DISCLAIMER
  // ------------------------------------------------------------

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Emotion detection is an AI-based estimate, '
                  'not a medical diagnosis. Facial expressions '
                  'do not always reflect how someone feels.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.68),
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTION BUTTONS
  // ------------------------------------------------------------

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // Return to EmotionScreen to capture another photo.
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.camera_alt_rounded,
              size: 19,
            ),
            label: const Text(
              'Analyze Again',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              // Return to EmotionScreen, then leave the feature.
              Navigator.pop(context);
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }
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
              'Done',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
