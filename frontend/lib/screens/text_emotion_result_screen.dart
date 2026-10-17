
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class TextEmotionResultScreen extends StatelessWidget {
  final String emotion;
  final double? confidence;

  const TextEmotionResultScreen({
    super.key,
    required this.emotion,
    this.confidence,
  });

  Color _emotionColor(String emotion) {
    final value = emotion.toLowerCase();

    if (value.contains('happy') ||
        value.contains('joy') ||
        value.contains('love') ||
        value.contains('excit')) {
      return const Color(0xFF438B68);
    }

    if (value.contains('sad') ||
        value.contains('fear') ||
        value.contains('anxious') ||
        value.contains('worry')) {
      return const Color(0xFF687DD0);
    }

    if (value.contains('anger') ||
        value.contains('angry') ||
        value.contains('disgust')) {
      return const Color(0xFFD16E59);
    }

    if (value.contains('stress') ||
        value.contains('overwhelm')) {
      return const Color(0xFF9675B7);
    }

    if (value.contains('neutral') ||
        value.contains('calm')) {
      return const Color(0xFF578A9A);
    }

    return AppColors.navy;
  }


  IconData _emotionIcon(String emotion) {
    final value = emotion.toLowerCase().trim();

    // Happiness and positive emotions
    if (value.contains('happy') ||
        value.contains('happiness') ||
        value.contains('joy') ||
        value.contains('joyful') ||
        value.contains('excited') ||
        value.contains('excitement')) {
      return Icons.sentiment_very_satisfied_rounded;
    }

    if (value.contains('love') ||
        value.contains('loving') ||
        value.contains('affection')) {
      return Icons.favorite_rounded;
    }

    if (value.contains('grateful') ||
        value.contains('gratitude') ||
        value.contains('thankful')) {
      return Icons.volunteer_activism_rounded;
    }

    // Sadness
    if (value.contains('sad') ||
        value.contains('sadness') ||
        value.contains('sorrow') ||
        value.contains('disappointed') ||
        value.contains('disappointment') ||
        value.contains('grief')) {
      return Icons.sentiment_very_dissatisfied_rounded;
    }

    // Anger
    if (value.contains('anger') ||
        value.contains('angry') ||
        value.contains('furious') ||
        value.contains('irritated') ||
        value.contains('frustrat')) {
      return Icons.mood_bad_rounded;
    }

    // Fear and anxiety
    if (value.contains('fear') ||
        value.contains('afraid') ||
        value.contains('scared') ||
        value.contains('terrified')) {
      return Icons.warning_amber_rounded;
    }

    if (value.contains('anxious') ||
        value.contains('anxiety') ||
        value.contains('worry') ||
        value.contains('nervous') ||
        value.contains('uneasy')) {
      return Icons.psychology_alt_rounded;
    }

    // Stress and overwhelm
    if (value.contains('stress') ||
        value.contains('overwhelm') ||
        value.contains('pressure') ||
        value.contains('burnout')) {
      return Icons.cloud_rounded;
    }

    // Calmness and relaxation
    if (value.contains('calm') ||
        value.contains('relaxed') ||
        value.contains('relaxation') ||
        value.contains('peaceful') ||
        value.contains('serene')) {
      return Icons.spa_rounded;
    }

    // Neutral emotions
    if (value.contains('neutral') ||
        value.contains('indifferent')) {
      return Icons.sentiment_neutral_rounded;
    }

    // Confusion
    if (value.contains('confus') ||
        value.contains('uncertain') ||
        value.contains('puzzled')) {
      return Icons.help_outline_rounded;
    }

    // Surprise
    if (value.contains('surpris') ||
        value.contains('astonished') ||
        value.contains('amazed')) {
      return Icons.sentiment_satisfied_alt_rounded;
    }

    // Disgust
    if (value.contains('disgust') ||
        value.contains('repulsed')) {
      return Icons.sick_rounded;
    }

    // Hope and optimism
    if (value.contains('hope') ||
        value.contains('optimis')) {
      return Icons.wb_sunny_rounded;
    }

    // Loneliness
    if (value.contains('lonely') ||
        value.contains('loneliness') ||
        value.contains('isolated')) {
      return Icons.person_outline_rounded;
    }

    // Default for unrecognized model labels
    return Icons.psychology_rounded;
  }


  String _emotionSubtitle(String emotion) {
    final value = emotion.toLowerCase();

    if (value.contains('happy') ||
        value.contains('joy') ||
        value.contains('love') ||
        value.contains('excit')) {
      return 'A little light in your words.';
    }

    if (value.contains('sad')) {
      return 'Give yourself room to feel.';
    }

    if (value.contains('anger') || value.contains('angry')) {
      return 'Your feelings deserve to be heard.';
    }

    if (value.contains('fear') ||
        value.contains('anxious') ||
        value.contains('worry')) {
      return 'Take it one moment at a time.';
    }

    if (value.contains('stress') ||
        value.contains('overwhelm')) {
      return 'You do not have to do everything at once.';
    }

    if (value.contains('neutral') || value.contains('calm')) {
      return 'A moment to reconnect with yourself.';
    }

    return 'A starting point for self-reflection.';
  }

  String _supportiveMessage(String emotion) {
    final value = emotion.toLowerCase();

    if (value.contains('happy') ||
        value.contains('joy') ||
        value.contains('love') ||
        value.contains('excit')) {
      return 'Take a moment to appreciate what is going well. '
          'Notice what contributed to this feeling and how you '
          'might make room for more positive moments.';
    }

    if (value.contains('sad')) {
      return 'It is okay to have difficult days. Be gentle with '
          'yourself, allow space for your feelings, and consider '
          'connecting with someone you trust.';
    }

    if (value.contains('anger') || value.contains('angry')) {
      return 'When emotions feel intense, give yourself a pause. '
          'A few slow breaths and some space may help you decide '
          'what you need next.';
    }

    if (value.contains('fear') ||
        value.contains('anxious') ||
        value.contains('worry')) {
      return 'Try focusing on one manageable step at a time. '
          'You do not need to solve everything at once. A short '
          'break or grounding exercise may help.';
    }

    if (value.contains('stress') || value.contains('overwhelm')) {
      return 'Consider what feels most demanding right now. '
          'Breaking a task into smaller steps and taking a brief '
          'rest may make things feel more manageable.';
    }

    if (value.contains('neutral') || value.contains('calm')) {
      return 'Use this moment to check in with yourself. Notice '
          'what you need today, whether that is rest, connection, '
          'movement, or simply some quiet time.';
    }

    return 'Use this prediction as a starting point for reflection. '
        'Your words provide only part of the picture, and you are '
        'the best person to interpret what you are experiencing.';
  }

  @override
  Widget build(BuildContext context) {
    final color = _emotionColor(emotion);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
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
        title: const Column(
          children: [
            Text(
              'Emotion Insights',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'YOUR WELLNESS JOURNEY',
              style: TextStyle(
                color: Color(0xFF819088),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 19),
            child: Icon(
              Icons.psychology_rounded,
              color: AppColors.mint,
              size: 27,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeading(),
              const SizedBox(height: 23),
              _buildEmotionCard(color),
              if (confidence != null) ...[
                const SizedBox(height: 17),
                _buildConfidenceCard(color),
              ],
              const SizedBox(height: 17),
              _buildReflectionCard(),
              const SizedBox(height: 22),
              _buildPrimaryButton(context),
              const SizedBox(height: 11),
              _buildSecondaryButton(context),
              const SizedBox(height: 22),
              _buildDisclaimer(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'MindMate · One moment at a time',
                  style: TextStyle(
                    color: Color(0xFF929D96),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your feelings,',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'in focus.',
          style: TextStyle(
            color: AppColors.mint,
            fontSize: 29,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'Your text has been analyzed. Here is what '
              'the model detected.',
          style: TextStyle(
            color: AppColors.navy.withOpacity(0.67),
            fontSize: 12,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF5EF),
            Color(0xFFF8FBF9),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: AppColors.borderMint),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderMint),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.mint,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Analysis complete',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.mint,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 25),
          Center(
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.09),
                    blurRadius: 24,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 19,
                    right: 19,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: color.withOpacity(0.55),
                      size: 15,
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.09),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _emotionIcon(emotion),
                      color: color,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 21),
          const Center(
            child: Text(
              'YOUR DETECTED EMOTION',
              style: TextStyle(
                color: Color(0xFF74857B),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              emotion,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _emotionSubtitle(emotion),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.65),
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: AppColors.borderMint,
          ),
          const SizedBox(height: 19),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderMint),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.mint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make space for your feelings',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your words can help you reflect on '
                          'what matters to you.',
                      style: TextStyle(
                        color: Color(0xFF65766D),
                        fontSize: 11,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(Color color) {
    final raw = confidence!;
    final percentage = (raw <= 1 ? raw * 100 : raw)
        .clamp(0.0, 100.0);
    final progress = percentage / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderMint),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Model confidence',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Prediction strength',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.57),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}% confidence',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 91,
            height: 91,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 83,
                  height: 83,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.lightMint,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.round()}%',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        color: Color(0xFF89958E),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3F0FB),
            Color(0xFFFAF8FD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE6DFF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: Color(0xFF8977B8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A moment for yourself',
                      style: TextStyle(
                        color: Color(0xFF3F355C),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'YOUR DAILY REFLECTION',
                      style: TextStyle(
                        color: Color(0xFF897BA3),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _supportiveMessage(emotion),
            style: const TextStyle(
              color: Color(0xFF51476B),
              fontSize: 12,
              height: 1.85,
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.spa_outlined,
                color: Color(0xFF8977B8),
                size: 17,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Be gentle with yourself today.',
                  style: TextStyle(
                    color: Color(0xFF6F6289),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_rounded,
              size: 19,
            ),
            SizedBox(width: 10),
            Text(
              'Analyze Another Text',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: AppColors.borderMint,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 17,
            ),
            SizedBox(width: 8),
            Text(
              'Back to My Text',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMint.withOpacity(0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.navy,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This insight is an AI-generated estimate, not a '
                  'diagnosis. Text alone cannot fully describe how '
                  'you feel. Your own understanding of your emotions '
                  'matters most.',
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.72),
                fontSize: 10,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
