
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';
import 'text_emotion_result_screen.dart';

class TextEmotionScreen extends StatefulWidget {
  const TextEmotionScreen({super.key});

  @override
  State<TextEmotionScreen> createState() =>
      _TextEmotionScreenState();
}

class _TextEmotionScreenState extends State<TextEmotionScreen> {
  final TextEditingController _textController =
  TextEditingController();

  static const int _maxCharacters = 2000;

  bool _isAnalyzing = false;
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
        _errorMessage =
        'Please write something before analyzing.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
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
            decoded['predicted_emotion'] ??
                decoded['emotion'];

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

          // Supports confidence values such as 0.85 or 85.
          if (confidence >= 0 && confidence <= 1) {
            confidence *= 100;
          }

          confidence = confidence.clamp(0, 100).toDouble();
        }

        final emotion = rawEmotion.toString().trim();

        // Stop the loading indicator before navigating.
        setState(() {
          _isAnalyzing = false;
        });

        // Show the result on a completely separate screen.
        final bool? analyzeAnother =
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => TextEmotionResultScreen(
              emotion: emotion,
              confidence: confidence,
            ),
          ),
        );

        if (!mounted) return;

        // Clear the input only when the user chooses
        // "Analyze Another Text".
        if (analyzeAnother == true) {
          _clearText();
        }
      } else {
        var message =
            'Unable to analyze your text. Please try again.';

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
      _errorMessage = null;
    });
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _errorMessage = null;
    });
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
              _headerFeature(
                Icons.psychology_alt_rounded,
                'Explore',
              ),
              const SizedBox(width: 18),
              _headerFeature(
                Icons.favorite_border_rounded,
                'Reflect',
              ),
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
        Icon(icon, color: AppColors.navy, size: 16),
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

  Widget _buildSectionHeading(
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
                      tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
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
            maxLengthEnforcement:
            MaxLengthEnforcement.enforced,
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
                16, 14, 16, 12,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (_) {
              setState(() {
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
                top: BorderSide(
                  color: Color(0xFFF0F4F2),
                ),
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
        const Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.mint,
              size: 18,
            ),
            SizedBox(width: 7),
            Text(
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
                onTap: _isAnalyzing
                    ? null
                    : () => _useSuggestion(suggestion),
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
          disabledBackgroundColor:
          AppColors.navy.withOpacity(0.55),
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
            Icon(
              Icons.auto_awesome_rounded,
              size: 19,
            ),
            SizedBox(width: 9),
            Text(
              'Analyze My Emotions',
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

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0D2CC),
        ),
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
