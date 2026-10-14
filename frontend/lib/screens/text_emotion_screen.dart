import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';

class TextEmotionScreen extends StatefulWidget {
  const TextEmotionScreen({super.key});

  @override
  State<TextEmotionScreen> createState() => _TextEmotionScreenState();
}

class _TextEmotionScreenState extends State<TextEmotionScreen> {
  final TextEditingController _textController = TextEditingController();

  static const int _maxCharacters = 2000;

  bool _isAnalyzing = false;

  String? _detectedEmotion;
  double? _confidence;
  String? _errorMessage;

  final List<String> _suggestions = [
    'I feel happy and grateful today.',
    'I am worried about my upcoming exams.',
    'I feel tired and overwhelmed with work.',
    'I have been feeling disconnected lately.',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeEmotion() async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please write something before analyzing.';
        _detectedEmotion = null;
        _confidence = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _detectedEmotion = null;
      _confidence = null;
    });

    try {
      final response = await http
          .post(
        Uri.parse(ApiConfig.textEmotionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'language': 'english',
        }),
      )
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'The server returned an invalid response.',
          );
        }

        final dynamic rawEmotion =
            decoded['predicted_emotion'] ?? decoded['emotion'];

        if (rawEmotion == null ||
            rawEmotion.toString().trim().isEmpty) {
          throw const FormatException(
            'No emotion prediction was returned by the server.',
          );
        }

        double? confidence;
        final dynamic rawConfidence = decoded['confidence'];

        if (rawConfidence is num) {
          confidence = rawConfidence.toDouble();

          // Supports confidence values returned as either
          // 0.85 or 85.
          if (confidence >= 0 && confidence <= 1) {
            confidence *= 100;
          }

          confidence = confidence.clamp(0, 100).toDouble();
        }

        setState(() {
          _detectedEmotion = rawEmotion.toString().trim();
          _confidence = confidence;
        });
      } else {
        var message = 'Unable to analyze your text. Please try again.';

        try {
          final dynamic decoded = jsonDecode(response.body);

          if (decoded is Map) {
            message = (decoded['message'] ??
                decoded['error'] ??
                message)
                .toString();
          }
        } catch (_) {
          // Keep the default error message.
        }

        setState(() {
          _errorMessage = message;
        });
      }
    } on FormatException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Could not connect to the analysis service. '
            'Please check your internet connection and backend.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _useSuggestion(String suggestion) {
    setState(() {
      _textController.text = suggestion;
      _textController.selection = TextSelection.collapsed(
        offset: suggestion.length,
      );

      _detectedEmotion = null;
      _confidence = null;
      _errorMessage = null;
    });
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _detectedEmotion = null;
      _confidence = null;
      _errorMessage = null;
    });
  }

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

    if (value.contains('neutral') ||
        value.contains('calm')) {
      return const Color(0xFF578A9A);
    }

    return AppColors.navy;
  }

  IconData _emotionIcon(String emotion) {
    final value = emotion.toLowerCase();

    if (value.contains('happy') ||
        value.contains('joy') ||
        value.contains('love') ||
        value.contains('excit')) {
      return Icons.sentiment_very_satisfied_rounded;
    }

    if (value.contains('sad')) {
      return Icons.sentiment_dissatisfied_rounded;
    }

    if (value.contains('anger') || value.contains('angry')) {
      return Icons.mood_bad_rounded;
    }

    if (value.contains('fear') ||
        value.contains('anxious') ||
        value.contains('worry')) {
      return Icons.sentiment_dissatisfied_rounded;
    }

    if (value.contains('neutral')) {
      return Icons.sentiment_neutral_rounded;
    }

    if (value.contains('calm')) {
      return Icons.spa_rounded;
    }

    return Icons.psychology_alt_rounded;
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

    if (value.contains('stress') ||
        value.contains('overwhelm')) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
        title: const Text(
          'Text Emotion',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildSectionHeading(
                'Express yourself',
                'Write naturally. There is no right or wrong way.',
              ),
              const SizedBox(height: 13),
              _buildTextInput(),
              const SizedBox(height: 20),
              _buildSuggestions(),
              const SizedBox(height: 24),
              _buildAnalyzeButton(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 15),
                _buildError(),
              ],
              if (_detectedEmotion != null) ...[
                const SizedBox(height: 27),
                _buildResult(),
              ],
              const SizedBox(height: 24),
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
          colors: [
            Color(0xFFEFF7F3),
            Color(0xFFE2F0E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.navy,
                  size: 27,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: AppColors.mint,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'AI-powered',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Understand your emotions',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore the feelings expressed in your words '
                'and take a moment to check in with yourself.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.72),
              fontSize: 12,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _headerFeature(Icons.edit_note_rounded, 'Write'),
              const SizedBox(width: 18),
              _headerFeature(Icons.psychology_alt_rounded, 'Explore'),
              const SizedBox(width: 18),
              _headerFeature(Icons.favorite_border_rounded, 'Reflect'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.navy,
          size: 16,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
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
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withOpacity(0.6),
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    final characterCount = _textController.text.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMint),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 12, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.notes_rounded,
                  color: AppColors.mint,
                  size: 19,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Your thoughts',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (characterCount > 0)
                  TextButton(
                    onPressed: _clearText,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mint,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _textController,
            minLines: 5,
            maxLines: 7,
            maxLength: _maxCharacters,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textCapitalization: TextCapitalization.sentences,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              height: 1.7,
            ),
            decoration: InputDecoration(
              hintText:
              'What has been on your mind lately?\n\n'
                  'Write about your day, your feelings, '
                  'or something you are working through...',
              hintStyle: TextStyle(
                color: AppColors.navy.withOpacity(0.42),
                fontSize: 12,
                height: 1.7,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                12,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (_) {
              setState(() {
                _detectedEmotion = null;
                _confidence = null;
                _errorMessage = null;
              });
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F4F2)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: AppColors.navy.withOpacity(0.5),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'English',
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$characterCount / $_maxCharacters',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.5),
                    fontSize: 10,
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

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.mint,
              size: 18,
            ),
            const SizedBox(width: 7),
            const Text(
              'Not sure where to start?',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ..._suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: () => _useSuggestion(suggestion),
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.mint,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.navy.withOpacity(0.4),
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _analyzeEmotion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          disabledBackgroundColor: AppColors.navy.withOpacity(0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isAnalyzing
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 11),
            Text(
              'Analyzing your words...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 19),
            SizedBox(width: 9),
            Text(
              'Analyze My Emotions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0D2CC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB85445),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9B4338),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final emotion = _detectedEmotion!;
    final color = _emotionColor(emotion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.navy,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Emotion Insight',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'A reflection based on your written text',
                    style: TextStyle(
                      color: Color(0xFF77847F),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderMint),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.18),
                  ),
                ),
                child: Icon(
                  _emotionIcon(emotion),
                  color: color,
                  size: 39,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                emotion,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Detected emotion',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_confidence != null) ...[
                const SizedBox(height: 23),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Model confidence',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_confidence!.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _confidence! / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.lightMint,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'This percentage represents the model output, '
                      'not a measurement of your emotional wellbeing.',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.55),
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.favorite_outline_rounded,
                          color: AppColors.navy,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'A moment for yourself',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _supportiveMessage(emotion),
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.78),
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _clearText,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Analyze Another Text',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This insight is an AI-generated estimate, not a '
              'diagnosis. Your own understanding of your feelings matters.',
          style: TextStyle(
            color: AppColors.navy.withOpacity(0.55),
            fontSize: 10,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMint.withOpacity(0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.navy,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your feelings are personal. Share only what you '
                  'feel comfortable submitting. Your result is an '
                  'AI-generated estimate, not a mental-health diagnosis.',
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.72),
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
