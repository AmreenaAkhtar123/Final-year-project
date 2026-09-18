import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class EmotionResultScreen extends StatelessWidget {
  final String emotion;
  final double confidence;

  const EmotionResultScreen({
    super.key,
    this.emotion = 'Happy',
    this.confidence = 0.92,
  });

  String get _emoji {
    switch (emotion) {
      case 'Happy':
        return '😊';
      case 'Calm':
        return '😌';
      case 'Sad':
        return '😔';
      case 'Angry':
        return '😠';
      case 'Anxious':
        return '😟';
      case 'Excited':
        return '🤩';
      case 'Neutral':
        return '😐';
      default:
        return '😌';
    }
  }

  String get _insight {
    switch (emotion) {
      case 'Happy':
        return 'Your facial expression suggests a positive emotional state.';
      case 'Calm':
        return 'Your expression appears relaxed and balanced.';
      case 'Sad':
        return 'Your expression may suggest a lower emotional state.';
      case 'Angry':
        return 'Your expression may indicate some emotional tension.';
      case 'Anxious':
        return 'Your expression may suggest signs of worry or tension.';
      case 'Excited':
        return 'Your expression suggests an energized and positive state.';
      default:
        return 'Your expression appears relatively neutral.';
    }
  }

  String get _suggestion {
    switch (emotion) {
      case 'Happy':
        return 'Take a moment to appreciate how you are feeling today.';
      case 'Calm':
        return 'Keep this feeling going with a few slow, mindful breaths.';
      case 'Sad':
        return 'Be gentle with yourself. Consider talking to someone you trust.';
      case 'Angry':
        return 'Pause for a moment and take a few slow, deep breaths.';
      case 'Anxious':
        return 'Try a short breathing exercise to help settle your mind.';
      case 'Excited':
        return 'Enjoy this positive energy and channel it into something meaningful.';
      default:
        return 'Take a moment to check in with yourself.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();

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

                    _buildResultCard(percentage),

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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.navy,
            ),
          ),
          const Expanded(
            child: Text(
              'Emotion Result',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildResultCard(int percentage) {
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
              'MOOD SNAPSHOT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
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
            'Emotion detected',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            emotion,
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
                'Confidence',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                ),
              ),
              Text(
                '$percentage%',
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
              value: confidence,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return _infoCard(
      icon: Icons.insights_rounded,
      title: 'What this may mean',
      text: _insight,
    );
  }

  Widget _buildSuggestionCard() {
    return _infoCard(
      icon: Icons.spa_rounded,
      title: 'Mindful suggestion',
      text: _suggestion,
    );
  }

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
            child: const Icon(
              Icons.spa_rounded,
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
              'Emotion detection is an AI-based estimate and is not a medical diagnosis.',
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

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
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
              Navigator.pop(context);
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