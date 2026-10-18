
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<void>? _playerCompleteSubscription;

  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isAnalyzing = false;

  String? _recordedPath;
  String? _errorMessage;
  String _selectedLanguage = 'english';

  String? _detectedMood;
  int? _confidence;
  String? _moodDescription;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Subscribe once instead of adding a new listener on every playback.
    _playerCompleteSubscription =
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _playerCompleteSubscription?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ============================================================
  // EMOTION HELPERS
  // ============================================================

  String _getMoodEmoji() {
    switch (_detectedMood?.toLowerCase()) {
      case 'happy':
      case 'joy':
      case 'love':
        return '😊';
      case 'calm':
        return '😌';
      case 'sad':
      case 'sadness':
        return '😔';
      case 'angry':
      case 'anger':
        return '😠';
      case 'fearful':
      case 'fear':
      case 'anxious':
        return '😟';
      case 'disgust':
        return '😖';
      case 'surprised':
      case 'surprise':
        return '😮';
      case 'neutral':
        return '😐';
      default:
        return '🎙️';
    }
  }

  String _describeEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return 'The voice model detected a happy emotional pattern. '
            'Consider what may be contributing to how you feel.';

      case 'calm':
        return 'The voice model detected a calm emotional pattern. '
            'Take a moment to reflect on your current wellbeing.';

      case 'sad':
      case 'sadness':
        return 'The voice model detected a sadness-related emotional '
            'pattern. If you are feeling low, consider taking a gentle '
            'moment for yourself.';

      case 'angry':
      case 'anger':
        return 'The voice model detected an anger-related emotional '
            'pattern. A pause and a few comfortable breaths may help '
            'you reflect.';

      case 'fearful':
      case 'fear':
        return 'The voice model detected a fear-related emotional '
            'pattern. Take your time and notice what would help you '
            'feel supported.';

      case 'disgust':
        return 'The voice model detected a disgust-related emotional '
            'pattern. Reflect on your experience and what may be behind it.';

      case 'surprised':
      case 'surprise':
        return 'The voice model detected a surprise-related emotional '
            'pattern. Consider what may have prompted this response.';

      case 'neutral':
        return 'The voice model detected a neutral emotional pattern. '
            'You can use this moment to check in with yourself.';

      default:
        return 'The voice model detected a $emotion emotional pattern. '
            'Use this result as a starting point for personal reflection.';
    }
  }

  String _normalizeEmotion(String emotion) {
    return emotion
        .trim()
        .toLowerCase()
        .split(RegExp(r'[\s_-]+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }

  // ============================================================
  // RECORDING
  // ============================================================

  Future<void> _startRecording() async {
    if (_isRecording || _isAnalyzing) return;

    try {
      setState(() {
        _errorMessage = null;
        _detectedMood = null;
        _confidence = null;
        _moodDescription = null;
      });

      final hasPermission = await _recorder.hasPermission();

      if (!hasPermission) {
        if (!mounted) return;

        setState(() {
          _errorMessage =
          'Microphone permission is required to record your voice.';
        });
        return;
      }

      final directory = await getTemporaryDirectory();

      final path =
          '${directory.path}/mindmate_voice_'
          '${DateTime.now().millisecondsSinceEpoch}.wav';

      // WAV PCM audio at 16 kHz mono is suitable for Wav2Vec2.
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _recorder.start(config, path: path);

      if (!mounted) {
        await _recorder.stop();
        return;
      }

      setState(() {
        _isRecording = true;
        _recordedPath = null;
        _isPlaying = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _errorMessage =
        'Unable to start recording. Please check microphone '
            'permission and try again. Details: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();

      if (!mounted) return;

      if (path == null || path.isEmpty) {
        setState(() {
          _isRecording = false;
          _recordedPath = null;
          _errorMessage =
          'The recording could not be saved. Please record again.';
        });
        return;
      }

      final file = File(path);

      if (!await file.exists() || await file.length() == 0) {
        setState(() {
          _isRecording = false;
          _recordedPath = null;
          _errorMessage =
          'The recording is empty. Please try recording again.';
        });
        return;
      }

      setState(() {
        _isRecording = false;
        _recordedPath = path;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _errorMessage = 'Unable to stop recording: $e';
      });
    }
  }

  // ============================================================
  // PLAYBACK
  // ============================================================

  Future<void> _togglePlayback() async {
    final path = _recordedPath;

    if (path == null || _isAnalyzing || _isRecording) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();

        if (mounted) {
          setState(() => _isPlaying = false);
        }
      } else {
        await _audioPlayer.play(DeviceFileSource(path));

        if (mounted) {
          setState(() => _isPlaying = true);
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _errorMessage = 'Unable to play the recording: $e';
      });
    }
  }

  // ============================================================
  // DELETE RECORDING
  // ============================================================

  Future<void> _deleteRecording() async {
    if (_isAnalyzing || _isRecording) return;

    try {
      final path = _recordedPath;

      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      if (path != null) {
        final file = File(path);

        if (await file.exists()) {
          await file.delete();
        }
      }

      if (!mounted) return;

      setState(() {
        _recordedPath = null;
        _isPlaying = false;
        _detectedMood = null;
        _confidence = null;
        _moodDescription = null;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to delete the recording: $e';
      });
    }
  }

  // ============================================================
  // VOICE EMOTION ANALYSIS
  // ============================================================

  Future<void> _analyzeVoice() async {
    if (_isAnalyzing || _isRecording) return;

    final path = _recordedPath;

    if (path == null) {
      setState(() {
        _errorMessage = 'Please record your voice first.';
      });
      return;
    }

    final audioFile = File(path);

    try {
      if (!await audioFile.exists() || await audioFile.length() == 0) {
        if (!mounted) return;

        setState(() {
          _errorMessage =
          'The recording is empty or no longer exists. '
              'Please record again.';
        });
        return;
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to read the recording: $e';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _errorMessage = null;
      _isAnalyzing = true;
      _detectedMood = null;
      _confidence = null;
      _moodDescription = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.voiceEmotionUrl),
      );

      request.fields['language'] = _selectedLanguage;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          path,
          filename: 'voice_recording.wav',
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 130),
      );

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      Map<String, dynamic> result;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map) {
          throw const FormatException('Unexpected response format.');
        }

        result = Map<String, dynamic>.from(decoded);
      } on FormatException {
        throw Exception(
          'The server returned an invalid response. '
              'Please check the backend logs.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          result['success'] != true) {
        final serverMessage =
            result['message'] ?? result['detail'];

        throw Exception(
          serverMessage?.toString() ??
              'Voice analysis failed with HTTP ${response.statusCode}.',
        );
      }

      final emotionValue =
          result['predicted_emotion'] ?? result['emotion'];

      final confidenceValue = result['confidence'];

      if (emotionValue is! String || confidenceValue is! num) {
        throw Exception(
          'The server response is missing the emotion or confidence.',
        );
      }

      final rawEmotion = emotionValue.trim();

      if (rawEmotion.isEmpty) {
        throw Exception('The model returned an empty emotion label.');
      }

      final rawConfidence = confidenceValue.toDouble();

      if (!rawConfidence.isFinite ||
          rawConfidence < 0 ||
          rawConfidence > 100) {
        throw Exception(
          'The server returned an invalid confidence value.',
        );
      }

      // Model APIs usually return 0–1; also accept 0–100.
      final confidencePercent = rawConfidence <= 1
          ? (rawConfidence * 100).round()
          : rawConfidence.round();

      final boundedConfidence =
      confidencePercent.clamp(0, 100).toInt();

      final normalizedEmotion = _normalizeEmotion(rawEmotion);
      final description = _describeEmotion(rawEmotion);

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _detectedMood = normalizedEmotion;
        _confidence = boundedConfidence;
        _moodDescription = description;
        _errorMessage = null;
      });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _errorMessage =
        'Voice analysis timed out. Please check that both '
            'backend services are running and try again.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && _isAnalyzing) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _tryAgain() {
    setState(() {
      _detectedMood = null;
      _confidence = null;
      _moodDescription = null;
      _errorMessage = null;
    });
  }

  // ============================================================
  // ABOUT DETECTION
  // ============================================================

  void _showDetectionInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'About Voice Analysis',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'MindMate uses a trained voice emotion model to estimate '
                'emotional patterns in your recording.\n\n'
                'The prediction may be incorrect and does not diagnose '
                'a mental health condition. Your own understanding of '
                'your feelings matters more than a model prediction.',
            style: TextStyle(
              color: AppColors.textDark,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LANGUAGE SELECTOR
  // ============================================================


  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose voice language',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: Row(
            children: [
              _buildLanguageOption(
                label: 'English',
                value: 'english',
                icon: Icons.language_rounded,
              ),
              const SizedBox(width: 6),
              _buildLanguageOption(
                label: 'اردو (Urdu)',
                value: 'urdu',
                icon: Icons.translate_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = _selectedLanguage == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.mint
                  : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.navy.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.navy,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _buildDecorations(),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildLanguageSelector(),
                  const SizedBox(height: 20),
                  _buildVoiceHero(),
                  const SizedBox(height: 24),
                  if (_recordedPath == null && !_isRecording)
                    _buildInstructionCard(),
                  if (_recordedPath != null) ...[
                    _buildRecordingCard(),
                    const SizedBox(height: 18),
                    _buildAnalyzeButton(),
                  ],
                  if (_isAnalyzing) ...[
                    const SizedBox(height: 20),
                    _buildAnalyzingCard(),
                  ],
                  if (_detectedMood != null) ...[
                    const SizedBox(height: 22),
                    _buildAnalysisResult(),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 15),
                    _buildError(),
                  ],
                  const SizedBox(height: 24),
                  _buildPrivacyCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  Widget _buildAppBar() {
    return SizedBox(
      height: 54,
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
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.borderMint),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.navy,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Voice Support',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
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

  // ============================================================
  // BACKGROUND DECORATIONS
  // ============================================================

  Widget _buildDecorations() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -75,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lightMint.withValues(alpha: 0.9),
                    AppColors.lightMint.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 270,
            left: -100,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lightMint.withValues(alpha: 0.65),
                    AppColors.lightMint.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderMint),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.mint,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your voice tells a story',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Take a moment to speak naturally.\n'
              'MindMate will help you check in with yourself.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VOICE HERO
  // ============================================================

  Widget _buildVoiceHero() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _isRecording
            ? 1 + (_pulseController.value * 0.06)
            : 1.0;

        return Transform.scale(
          scale: pulse,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightMint,
                  AppColors.background,
                ],
              ),
              border: Border.all(color: AppColors.borderMint),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isRecording)
                      Container(
                        width: 178,
                        height: 178,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mint.withValues(alpha: 0.2),
                            width: 18,
                          ),
                        ),
                      ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isRecording
                              ? [
                            AppColors.mint,
                            AppColors.navy,
                          ]
                              : [
                            Colors.white,
                            AppColors.lightMint,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.mint.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withValues(alpha: 0.2),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_none_rounded,
                        size: 55,
                        color: _isRecording
                            ? Colors.white
                            : AppColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  _isRecording
                      ? 'Listening to you...'
                      : _isAnalyzing
                      ? 'Understanding your voice...'
                      : 'Tap below to start',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isRecording
                      ? 'Speak freely. There is no right or wrong way.'
                      : 'Find a quiet moment and speak naturally.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing
                        ? null
                        : (_isRecording
                        ? _stopRecording
                        : _startRecording),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      AppColors.navy.withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _isRecording
                          ? 'Finish Recording'
                          : 'Start Speaking',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INSTRUCTION CARD
  // ============================================================

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        children: [
          _smallFeatureIcon(Icons.record_voice_over_outlined),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speak in your own words',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A few seconds of natural speech is enough to begin.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
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

  // ============================================================
  // RECORDING CARD
  // ============================================================

  Widget _buildRecordingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMint),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.audiotrack_rounded,
                  color: AppColors.mint,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice recording ready',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'WAV audio ready to analyze',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isAnalyzing ? null : _togglePlayback,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightMint,
                ),
                icon: Icon(
                  _isPlaying
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _isAnalyzing ? null : _deleteRecording,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildWaveform(),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    const heights = <double>[
      12, 20, 15, 28, 18, 34, 22, 16, 30, 20, 38, 25,
      16, 27, 18, 32, 21, 14, 26, 18, 30, 20, 13, 24,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights.map((height) {
        return Container(
          width: 3,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: AppColors.mint.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // ANALYZE BUTTON
  // ============================================================

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _analyzeVoice,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          AppColors.mint.withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 21),
            SizedBox(width: 9),
            Text(
              'Analyze My Voice',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANALYZING CARD
  // ============================================================

  Widget _buildAnalyzingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Analyzing your voice',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'MindMate is preparing your mood insight...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANALYSIS RESULT
  // ============================================================

  Widget _buildAnalysisResult() {
    final confidence = _confidence ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.055),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'VOICE MOOD',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MODEL RESULT',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 142,
                height: 142,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightMint.withValues(alpha: 0.55),
                ),
              ),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppColors.lightMint,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.mint.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mint.withValues(alpha: 0.12),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMoodEmoji(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Detected mood',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _detectedMood ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Confidence',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$confidence%',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 7,
              backgroundColor: AppColors.lightMint,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightMint.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.mint,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your wellbeing insight',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _moodDescription ?? '',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDetectionInfo,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderMint),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.navy,
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'About this insight',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.navy,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _tryAgain,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Analyze another recording'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIVACY INFORMATION
  // ============================================================

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your recording is sent to the MindMate backend for '
                  'emotion analysis. Avoid including sensitive personal '
                  'information in your recording.',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL ICON
  // ============================================================

  Widget _smallFeatureIcon(IconData icon) {
    return Container(
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
    );
  }
}
