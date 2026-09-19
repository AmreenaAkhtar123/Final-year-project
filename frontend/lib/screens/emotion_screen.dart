import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../core/constants/app_colors.dart';
import 'emotion_result_screen.dart';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key});

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  CameraController? _cameraController;

  List<CameraDescription> _cameras = [];

  bool _isCameraInitialized = false;
  bool _isLoadingCamera = true;
  bool _cameraError = false;
  bool _isDetecting = false;
  XFile? _capturedImage;
  bool _isCapturing = false;

  final List<Map<String, dynamic>> _emotionHistory = [
    {
      'emotion': 'Happy',
      'emoji': '😊',
      'confidence': 0.92,
      'time': 'Today, 4:20 PM',
    },
    {
      'emotion': 'Calm',
      'emoji': '😌',
      'confidence': 0.87,
      'time': 'Yesterday, 8:15 PM',
    },
    {
      'emotion': 'Anxious',
      'emoji': '😟',
      'confidence': 0.81,
      'time': 'Sep 15, 6:40 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  Future<XFile> _fixFrontCameraMirror(XFile original) async {
    final isFrontCamera = _cameraController?.description.lensDirection ==
        CameraLensDirection.front;

    if (!isFrontCamera) return original;

    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return original;

    final flipped = img.flipHorizontal(decoded);
    final flippedBytes = Uint8List.fromList(img.encodeJpg(flipped, quality: 92));

    final newPath = original.path.replaceFirst('.jpg', '_flipped.jpg');
    final file = await File(newPath).writeAsBytes(flippedBytes);

    return XFile(file.path);
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No camera available.');
      }

      CameraDescription selectedCamera = _cameras.first;

      for (final camera in _cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _cameraController = controller;

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _isLoadingCamera = false;
        _cameraError = false;
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');

      if (!mounted) return;

      setState(() {
        _cameraError = true;
        _isLoadingCamera = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _cameraController == null) {
      return;
    }

    final currentDirection =
        _cameraController!.description.lensDirection;

    final newCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras.first,
    );

    setState(() {
      _isCameraInitialized = false;
      _isLoadingCamera = true;
    });

    await _cameraController?.dispose();

    try {
      final controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _cameraController = controller;

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _isLoadingCamera = false;
        _cameraError = false;
      });
    } catch (e) {
      debugPrint('Camera switch error: $e');

      if (!mounted) return;

      setState(() {
        _cameraError = true;
        _isLoadingCamera = false;
      });
    }
  }

  Future<void> _captureFace() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final rawImage = await _cameraController!.takePicture();
      final fixedImage = await _fixFrontCameraMirror(rawImage);

      if (!mounted) return;

      setState(() {
        _capturedImage = fixedImage;
        _isCapturing = false;
      });
    } catch (e) {
      debugPrint('Image capture error: $e');

      if (!mounted) return;

      setState(() {
        _isCapturing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not capture the image. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDemoResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ======================================================
              // PREMIUM RESULT HEADER
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navy,
                      AppColors.navy.withValues(alpha: 0.92),
                      AppColors.mint.withValues(alpha: 0.78),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Header label
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
                          'MOOD SNAPSHOT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // EMOTION EMOJI
                    // =================================================

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 126,
                          height: 126,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.mint.withValues(alpha: 0.28),
                              width: 1.5,
                            ),
                          ),
                        ),

                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '😊',
                              style: TextStyle(
                                fontSize: 48,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Emotion detected',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Happy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'A positive expression was detected',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // RESULT DETAILS
              // ======================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  22,
                  22,
                  26,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // CONFIDENCE SECTION
                    // ==================================================

                    Row(
                      children: [
                        // Circular confidence
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: 0.92,
                                  strokeWidth: 6,
                                  backgroundColor:
                                  AppColors.lightMint,
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    AppColors.mint,
                                  ),
                                ),
                              ),

                              const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '92%',
                                    style: TextStyle(
                                      color: AppColors.navy,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'confidence',
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 7.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detection confidence',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'The expression pattern was '
                                    'recognized with high confidence.',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 11.5,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // WELLBEING INSIGHT
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightMint.withValues(
                          alpha: 0.62,
                        ),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: AppColors.borderMint,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.mint,
                              size: 19,
                            ),
                          ),

                          const SizedBox(width: 11),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your wellbeing insight',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Your facial expression appears '
                                      'positive right now.',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 11.5,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // MINDFUL NOTE
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderMint,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            color: AppColors.mint,
                            size: 19,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              'A smile can be a small moment '
                                  'worth noticing.',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 11.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // DONE BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }


  Widget _buildEmotionHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.mint,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Recent Emotion History',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._emotionHistory.map(
                (item) => _buildHistoryItem(item),
          ),
        ],
      ),
    );
  }
  void _showEmotionHistoryDetails(
      Map<String, dynamic> item,
      ) {
    final confidence =
    ((item['confidence'] as double) * 100).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMint,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item['emoji'],
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                item['emotion'],
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                item['time'],
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.55),
                  fontSize: 11.5,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.mint,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detection confidence',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$confidence%',
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightMint.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.mint,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Emotion results are private and should be treated as an estimate, not a diagnosis.',
                        style: TextStyle(
                          color: AppColors.navy.withValues(
                            alpha: 0.68,
                          ),
                          fontSize: 10.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final confidence =
    ((item['confidence'] as double) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showEmotionHistoryDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item['emoji'],
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['emotion'],
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['time'],
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.52),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$confidence%',
                  style: const TextStyle(
                    color: AppColors.mint,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.navy.withValues(alpha: 0.35),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  24,
                ),
                child: Column(
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 20),
                    _buildCameraCard(),
                    const SizedBox(height: 18),
                    _buildDetectButton(),

                    const SizedBox(height: 20),
                    _buildEmotionHistory(),

                    const SizedBox(height: 16),
                    _buildPrivacyCard(),
                    const SizedBox(height: 10),
                    _buildDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HEADER
  // ==============================================================
  Widget _buildCapturedImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ==========================================================
        // CAPTURED IMAGE
        // ==========================================================

        Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.cover,
        ),

        // ==========================================================
        // SOFT OVERLAY
        // ==========================================================

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.68),
              ],
              stops: const [
                0.0,
                0.48,
                1.0,
              ],
            ),
          ),
        ),

        // ==========================================================
        // TOP LABEL
        // ==========================================================

        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.mint,
                  size: 15,
                ),
                SizedBox(width: 7),
                Text(
                  'Face captured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ==========================================================
        // BOTTOM CONTENT
        // ==========================================================

        Positioned(
          left: 20,
          right: 20,
          bottom: 18,
          child: Column(
            children: [
              const Text(
                'Does this look good?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Your face is ready for emotion analysis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 11.5,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  // ------------------------------------------------
                  // RETAKE
                  // ------------------------------------------------

                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isCapturing
                            ? null
                            : _retakePhoto,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Retake',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(
                              alpha: 0.65,
                            ),
                          ),
                          backgroundColor:
                          Colors.black.withValues(alpha: 0.22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ------------------------------------------------
                  // CONTINUE
                  // ------------------------------------------------

                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _continueFromCapture,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _retakePhoto() async {
    if (!mounted) return;

    setState(() {
      _capturedImage = null;
    });
  }

  void _continueFromCapture() {
    if (_capturedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmotionResultScreen(
          emotion: 'Happy',
          confidence: 0.92,
        ),
      ),
    );
  }



  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        8,
      ),
      child: Row(
        children: [
          Material(
            color: AppColors.lightMint,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.navy,
                  size: 17,
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Facial Emotion',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'AI-powered expression insight',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INTRO
  // ==============================================================

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Take a moment.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Look at the camera naturally. MindMate will '
              'analyze your facial expression.',
          style: TextStyle(
            color: AppColors.textDark.withValues(alpha: 0.8),
            fontSize: 12.5,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // CAMERA CARD
  // ==============================================================

  Widget _buildCameraCard() {
    return Container(
      width: double.infinity,
      height: 410,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _buildCameraContent(),
    );
  }

  Widget _buildCameraContent() {
    if (_capturedImage != null) {
      return _buildCapturedImagePreview();
    }

    if (_isLoadingCamera) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.mint,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Starting camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_cameraError ||
        _cameraController == null ||
        !_isCameraInitialized) {
      return _buildCameraError();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ----------------------------------------------------------
        // CAMERA PREVIEW
        // ----------------------------------------------------------

        _buildCameraPreview(),

        // ----------------------------------------------------------
        // SOFT OVERLAY
        // ----------------------------------------------------------

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.38),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.38),
              ],
              stops: const [
                0.0,
                0.48,
                1.0,
              ],
            ),
          ),
        ),

        // ----------------------------------------------------------
        // TOP STATUS
        // ----------------------------------------------------------

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: AppColors.mint,
                      size: 8,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Ready to scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Material(
                color: Colors.black.withValues(alpha: 0.30),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _switchCamera,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ----------------------------------------------------------
        // FACE GUIDE
        // ----------------------------------------------------------

        Positioned(
          left: 42,
          right: 42,
          top: 65,
          bottom: 62,
          child: CustomPaint(
            painter: _FaceGuidePainter(),
          ),
        ),

        // ----------------------------------------------------------
        // FACE INSTRUCTION
        // ----------------------------------------------------------

        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.face_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Center your face in the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ----------------------------------------------------------
        // ANALYZING OVERLAY
        // ----------------------------------------------------------

        if (_isDetecting)
          Container(
            color: AppColors.navy.withValues(alpha: 0.58),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.mint,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Reading expression...',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==============================================================
  // CAMERA PREVIEW
  // ==============================================================

  Widget _buildCameraPreview() {
    final controller = _cameraController!;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize!.height,
        height: controller.value.previewSize!.width,
        child: CameraPreview(controller),
      ),
    );
  }

  // ==============================================================
  // CAMERA ERROR
  // ==============================================================

  Widget _buildCameraError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(height: 17),

            const Text(
              'Camera unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Please allow camera permission and '
                  'try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () {
                setState(() {
                  _cameraError = false;
                  _isLoadingCamera = true;
                });

                _initializeCamera();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // DETECT BUTTON
  // ==============================================================

  Widget _buildDetectButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
        _isCameraInitialized && !_isCapturing
            ? _captureFace
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          AppColors.mint.withValues(alpha: 0.45),
          disabledForegroundColor:
          Colors.white.withValues(alpha: 0.75),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isCapturing
              ? const Row(
            key: ValueKey('capturing'),
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
              SizedBox(width: 10),
              Text(
                'Capturing Face...',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
              : const Row(
            key: ValueKey('capture'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                size: 20,
              ),
              SizedBox(width: 9),
              Text(
                'Capture Face',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // PRIVACY
  // ==============================================================

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.borderMint,
        ),
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
              Icons.shield_outlined,
              color: AppColors.mint,
              size: 18,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy matters',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your facial data is not stored or uploaded '
                      'during this demo.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11,
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

  // ==============================================================
  // DISCLAIMER
  // ==============================================================

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        'Facial emotion detection is an AI-assisted '
            'feature and may not always be accurate.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textDark.withValues(alpha: 0.58),
          fontSize: 10.5,
          height: 1.45,
        ),
      ),
    );
  }
}

// ================================================================
// FACE GUIDE
// ================================================================

class _FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = AppColors.mint.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.mint.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final ovalRect = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2,
      ),
      width: size.width * 0.72,
      height: size.height * 0.78,
    );

    // Soft glow
    canvas.drawOval(
      ovalRect.inflate(12),
      glowPaint,
    );

    // Main face guide
    canvas.drawOval(
      ovalRect,
      borderPaint,
    );

    // Inner subtle guide
    canvas.drawOval(
      ovalRect.deflate(7),
      innerPaint,
    );

    // Small center marker
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final markerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(center.dx - 9, center.dy),
      Offset(center.dx + 9, center.dy),
      markerPaint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - 9),
      Offset(center.dx, center.dy + 9),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}