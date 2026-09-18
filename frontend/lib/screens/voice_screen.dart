import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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

  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isAnalyzing = false;

  String _getMoodEmoji() {
    switch (_detectedMood) {
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

  String? _recordedPath;
  String? _errorMessage;

  String? _detectedMood;
  int? _confidence;
  String? _moodDescription;
  IconData? _moodIcon;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ============================================================
  // RECORDING
  // ============================================================

  Future<void> _startRecording() async {
    try {
      setState(() {
        _errorMessage = null;
        _detectedMood = null;
        _confidence = null;
        _moodDescription = null;
        _moodIcon = null;
      });

      final hasPermission = await _recorder.hasPermission();

      if (!hasPermission) {
        setState(() {
          _errorMessage =
          'Microphone permission is required to record your voice.';
        });
        return;
      }

      final directory = await getTemporaryDirectory();

      final path =
          '${directory.path}/mindmate_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      );

      await _recorder.start(
        config,
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordedPath = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to start recording.';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
        _errorMessage = 'Unable to stop recording.';
      });
    }
  }

  // ============================================================
  // PLAYBACK
  // ============================================================

  Future<void> _togglePlayback() async {
    final path = _recordedPath;

    if (path == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();

        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.play(
          DeviceFileSource(path),
        );

        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to play the recording.';
        });
      }
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteRecording() async {
    final path = _recordedPath;

    if (path != null) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }

    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    setState(() {
      _recordedPath = null;
      _isPlaying = false;
      _isAnalyzing = false;
      _detectedMood = null;
      _confidence = null;
      _moodDescription = null;
      _moodIcon = null;
      _errorMessage = null;
    });
  }

  // ============================================================
  // DEMO ANALYSIS
  // ============================================================

  Future<void> _analyzeVoice() async {
    if (_recordedPath == null) {
      setState(() {
        _errorMessage = 'Please record your voice first.';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = null;
        _isAnalyzing = true;
        _detectedMood = null;
        _confidence = null;
        _moodDescription = null;
        _moodIcon = null;
      });

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // DEMO RESULT
      // Replace this with your backend response later.
      // ----------------------------------------------------------

      setState(() {
        _isAnalyzing = false;
        _detectedMood = 'Calm';
        _confidence = 89;
        _moodIcon = Icons.spa_rounded;
        _moodDescription =
        'Your voice sounds calm and steady. '
            'Take a moment to acknowledge how you are feeling today.';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Unable to analyze your voice.';
        });
      }
    }
  }

  void _tryAgain() {
    setState(() {
      _detectedMood = null;
      _confidence = null;
      _moodDescription = null;
      _moodIcon = null;
      _errorMessage = null;
    });
  }

  void _showDetectionInfo() {
    showDialog(
      context: context,
      builder: (context) {
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
            'The future MindMate model will analyze characteristics '
                'of your voice to estimate an emotional state.\n\n'
                'This current result is a demo and does not represent '
                'a real machine-learning prediction.',
            style: TextStyle(
              color: AppColors.textDark,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildDecorations(),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                22,
                10,
                22,
                28,
              ),
              child: Column(
                children: [
                  _buildHeader(),

                  const SizedBox(height: 26),

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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.navy,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Voice Support',
        style: TextStyle(
          color: AppColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
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
                    AppColors.lightMint.withValues(alpha: 0.0),
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
                    AppColors.lightMint.withValues(alpha: 0.0),
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
            border: Border.all(
              color: AppColors.borderMint,
            ),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightMint,
                  AppColors.background,
                ],
              ),
              border: Border.all(
                color: AppColors.borderMint,
              ),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 178,
                        height: 178,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mint.withValues(
                              alpha: 0.20,
                            ),
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
                          color: AppColors.mint.withValues(
                            alpha: 0.5,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withValues(
                              alpha: 0.20,
                            ),
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
                  style: TextStyle(
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
                    onPressed:
                    _isAnalyzing
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
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          _smallFeatureIcon(
            Icons.record_voice_over_outlined,
          ),

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
        border: Border.all(
          color: AppColors.borderMint,
        ),
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
                      'Your recording is ready to analyze',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed:
                _isAnalyzing ? null : _togglePlayback,
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
                onPressed:
                _isAnalyzing ? null : _deleteRecording,
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
    final heights = [
      12.0,
      20.0,
      15.0,
      28.0,
      18.0,
      34.0,
      22.0,
      16.0,
      30.0,
      20.0,
      38.0,
      25.0,
      16.0,
      27.0,
      18.0,
      32.0,
      21.0,
      14.0,
      26.0,
      18.0,
      30.0,
      20.0,
      13.0,
      24.0,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 21,
            ),
            const SizedBox(width: 9),
            const Text(
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
  // ANALYZING
  // ============================================================

  Widget _buildAnalyzingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Analyzing your voice',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
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
          // --------------------------------------------------------
          // TOP LABEL
          // --------------------------------------------------------

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
                  'DEMO',
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

          // --------------------------------------------------------
          // MOOD VISUAL
          // --------------------------------------------------------

          Stack(
            alignment: Alignment.center,
            children: [
              // Outer soft circle
              Container(
                width: 142,
                height: 142,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightMint.withValues(alpha: 0.55),
                ),
              ),

              // Inner circle
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

                // IMPORTANT: Center the whole emoji
                child: Center(
                  child: Text(
                    _getMoodEmoji(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      height: 1.0,
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
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------------
          // CONFIDENCE
          // --------------------------------------------------------

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
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------------
          // WELLBEING INSIGHT
          // --------------------------------------------------------

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

          // --------------------------------------------------------
          // ABOUT INSIGHT
          // --------------------------------------------------------

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
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.navy,
                      size: 18,
                    ),

                    const SizedBox(width: 9),

                    const Expanded(
                      child: Text(
                        'About this insight',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Icon(
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

          // --------------------------------------------------------
          // ANALYZE AGAIN
          // --------------------------------------------------------

          TextButton.icon(
            onPressed: _tryAgain,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
            label: const Text(
              'Analyze another recording',
            ),
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

  Widget _buildConfidence() {
    final confidence = _confidence ?? 0;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Analysis confidence',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              '$confidence%',
              style: const TextStyle(
                color: AppColors.navy,
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
            minHeight: 8,
            backgroundColor: AppColors.lightMint,
            valueColor:
            const AlwaysStoppedAnimation<Color>(
              AppColors.mint,
            ),
          ),
        ),
      ],
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
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMint,
        ),
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
              'Your recording stays on your device for now. '
                  'The final MindMate version will securely process '
                  'voice data through the backend.',
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