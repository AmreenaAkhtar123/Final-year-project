
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';
import '../core/config/api_config.dart';
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
  bool _isCapturing = false;

  XFile? _capturedImage;

  // Demo history. These entries are not yet saved model predictions.
  final List<Map<String, dynamic>> _emotionHistory = [
    {
      'emotion': 'Happy',
      'emoji': '😊',
      'confidence': 0.92,
      'time': 'Today, 4:20 PM',
    },
    {
      'emotion': 'Neutral',
      'emoji': '😐',
      'confidence': 0.87,
      'time': 'Yesterday, 8:15 PM',
    },
    {
      'emotion': 'Sad',
      'emoji': '😔',
      'confidence': 0.81,
      'time': 'Sep 15, 6:40 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ------------------------------------------------------------
  // CAMERA INITIALIZATION
  // ------------------------------------------------------------

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No camera is available on this device.');
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
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 ||
        _cameraController == null ||
        _isCapturing ||
        _isDetecting) {
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
    _cameraController = null;

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
        _isCameraInitialized = false;
      });
    }
  }

  // ------------------------------------------------------------
  // FRONT CAMERA MIRROR CORRECTION
  // ------------------------------------------------------------

  Future<XFile> _fixFrontCameraMirror(XFile original) async {
    final isFrontCamera =
        _cameraController?.description.lensDirection ==
            CameraLensDirection.front;

    if (!isFrontCamera) return original;

    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return original;

    final flipped = img.flipHorizontal(decoded);
    final flippedBytes = Uint8List.fromList(
      img.encodeJpg(flipped, quality: 92),
    );

    final originalFile = File(original.path);
    final newPath =
        '${originalFile.parent.path}${Platform.pathSeparator}'
        '${DateTime.now().microsecondsSinceEpoch}_flipped.jpg';

    final file = await File(newPath).writeAsBytes(flippedBytes);

    return XFile(file.path);
  }

  // ------------------------------------------------------------
  // CAPTURE PHOTO
  // ------------------------------------------------------------

  Future<void> _captureFace() async {
    final controller = _cameraController;

    if (!_isCameraInitialized ||
        controller == null ||
        _isCapturing ||
        _isDetecting) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final rawImage = await controller.takePicture();
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

      _showMessage(
        'Could not capture the image. Please try again.',
      );
    }
  }

  // ------------------------------------------------------------
  // REAL FACIAL EMOTION MODEL API
  // ------------------------------------------------------------


  Future<void> _continueFromCapture() async {
    if (_capturedImage == null || _isDetecting) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      // 1. Read the captured image.
      final originalBytes = await _capturedImage!.readAsBytes();

      // 2. Decode the image.
      final decodedImage = img.decodeImage(originalBytes);

      if (decodedImage == null) {
        throw Exception(
          'Could not read the captured image. Please retake the photo.',
        );
      }

      // 3. Convert it to a standard JPEG.
      final jpegBytes = Uint8List.fromList(
        img.encodeJpg(decodedImage, quality: 90),
      );

      if (jpegBytes.isEmpty) {
        throw Exception('The JPEG image could not be created.');
      }

      debugPrint('Original image size: ${originalBytes.length} bytes');
      debugPrint('JPEG image size: ${jpegBytes.length} bytes');
      debugPrint('Uploading image as image/jpeg');

      // 4. Create the multipart request.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.facialEmotionUrl),
      );

      // IMPORTANT: The backend expects the field name "file".
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          jpegBytes,
          filename: 'face.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 5. Send the image to the facial emotion API.
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 90),
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Facial API status: ${response.statusCode}');
      debugPrint('Facial API response: ${response.body}');

      // 6. Decode the API response.
      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'The server returned an invalid response: ${response.body}',
        );
      }

      // 7. Handle server errors without hiding the actual message.
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map
            ? decoded['detail'] ??
            decoded['error'] ??
            decoded['message']
            : null;

        throw Exception(
          message?.toString() ??
              'Facial analysis failed (${response.statusCode}).',
        );
      }

      if (decoded is! Map || decoded['success'] != true) {
        throw Exception(
          'The server did not return a successful prediction.',
        );
      }

      // 8. Read the predicted emotion.
      final rawEmotion =
      (decoded['predicted_emotion'] ?? decoded['emotion'])
          ?.toString()
          .trim()
          .toLowerCase();

      if (rawEmotion == null || rawEmotion.isEmpty) {
        throw Exception('The server did not return a predicted emotion.');
      }

      // 9. Read and validate the confidence score.
      final confidenceValue = decoded['confidence'];

      if (confidenceValue is! num) {
        throw Exception('The server did not return a valid confidence score.');
      }

      final confidence = confidenceValue.toDouble();

      if (!confidence.isFinite || confidence < 0 || confidence > 1) {
        throw Exception(
          'The confidence score must be between 0 and 1.',
        );
      }

      // 10. Convert model labels into display labels.
      final emotion = switch (rawEmotion) {
        'happy' => 'Happy',
        'sad' => 'Sad',
        'angry' => 'Angry',
        'fear' => 'Fear',
        'disgust' => 'Disgust',
        'surprise' => 'Surprise',
        'neutral' => 'Neutral',
        _ => throw Exception(
          'Unknown emotion returned by the model: $rawEmotion',
        ),
      };

      if (!mounted) return;

      // 11. Add the real prediction to the screen's history.
      final now = DateTime.now();
      final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'PM' : 'AM';

      setState(() {
        _emotionHistory.insert(0, {
          'emotion': emotion,
          'emoji': _emojiFor(emotion),
          'confidence': confidence,
          'time': 'Today, $hour:$minute $period',
        });

        if (_emotionHistory.length > 10) {
          _emotionHistory.removeLast();
        }
      });

      // 12. Navigate to the existing result screen.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmotionResultScreen(
            emotion: emotion,
            confidence: confidence,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Facial emotion analysis error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        'Could not analyze the face. '
            '${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }


  String _emojiFor(String emotion) {
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Future<void> _clearEmotionHistory() async {
    if (_emotionHistory.isEmpty) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Clear emotion history?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This will remove all emotion entries currently shown '
                'in your history. This action cannot be undone.',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB54747),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true && mounted) {
      setState(() {
        _emotionHistory.clear();
      });

      _showMessage('Emotion history cleared.');
    }
  }

  void _deleteEmotionHistoryItem(Map<String, dynamic> item) {
    if (!_emotionHistory.contains(item)) return;

    setState(() {
      _emotionHistory.remove(item);
    });

    _showMessage('${item['emotion']} entry deleted.');
  }





  Future<void> _retakePhoto() async {
    if (_isDetecting || _isCapturing || !mounted) return;

    setState(() {
      _capturedImage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
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

  // ------------------------------------------------------------
  // INTRO
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // CAMERA CARD
  // ------------------------------------------------------------

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
        _buildCameraPreview(),
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
              stops: const [0.0, 0.48, 1.0],
            ),
          ),
        ),
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
        Positioned(
          left: 42,
          right: 42,
          top: 65,
          bottom: 62,
          child: CustomPaint(
            painter: _FaceGuidePainter(),
          ),
        ),
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
      ],
    );
  }

  // ------------------------------------------------------------
  // CAPTURED PHOTO PREVIEW
  // ------------------------------------------------------------

  Widget _buildCapturedImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.72),
              ],
              stops: const [0.0, 0.40, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.38),
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
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Column(
            children: [
              const Text(
                'Ready to analyze?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Your photo will be sent to the AI model.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isDetecting || _isCapturing
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
                          disabledForegroundColor: Colors.white54,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.65),
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
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isDetecting
                            ? null
                            : _continueFromCapture,
                        icon: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Analyze',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          AppColors.mint.withValues(alpha: 0.5),
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
        if (_isDetecting)
          Container(
            color: AppColors.navy.withValues(alpha: 0.68),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
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
                    Flexible(
                      child: Text(
                        'Analyzing your expression...',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
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

  // ------------------------------------------------------------
  // CAMERA PREVIEW
  // ------------------------------------------------------------

  Widget _buildCameraPreview() {
    final controller = _cameraController!;
    final previewSize = controller.value.previewSize;

    if (previewSize == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.mint,
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    );
  }

  // ------------------------------------------------------------
  // CAMERA ERROR
  // ------------------------------------------------------------

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
              'Please allow camera permission and try again.',
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CAPTURE BUTTON
  // ------------------------------------------------------------

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
        onPressed: _isCameraInitialized &&
            !_isCapturing &&
            !_isDetecting &&
            _capturedImage == null
            ? _captureFace
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          AppColors.mint.withValues(alpha: 0.35),
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

  // ------------------------------------------------------------
  // EMOTION HISTORY
  // ------------------------------------------------------------


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
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: AppColors.mint,
                size: 21,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Recent Emotion History',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_emotionHistory.isNotEmpty)
                TextButton(
                  onPressed: _clearEmotionHistory,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB54747),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_sweep_outlined,
                        size: 17,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),

          if (_emotionHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 8,
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.lightMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_toggle_off_rounded,
                        color: AppColors.mint,
                        size: 31,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No emotion history yet',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Capture your face and analyze your expression '
                          'to see your results here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark.withValues(alpha: 0.65),
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._emotionHistory.map(_buildHistoryItem),
        ],
      ),
    );
  }


  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final confidence =
    ((item['confidence'] as num) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showEmotionHistoryDetails(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 6,
            ),
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
                      item['emoji'].toString(),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['emotion'].toString(),
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['time'].toString(),
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

                const SizedBox(width: 2),

                IconButton(
                  tooltip: 'Delete this entry',
                  onPressed: () => _deleteEmotionHistoryItem(item),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB54747),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showEmotionHistoryDetails(Map<String, dynamic> item) {
    final confidence = ((item['confidence'] as num) * 100).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                    item['emoji'].toString(),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item['emotion'].toString(),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['time'].toString(),
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
                        'This is an AI estimate of a facial expression, '
                            'not a diagnosis or a reliable measure of '
                            'someone’s actual feelings.',
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.68),
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
                  onPressed: () => Navigator.pop(sheetContext),
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

  // ------------------------------------------------------------
  // PRIVACY CARD
  // ------------------------------------------------------------

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
                  'The captured photo is sent to your configured '
                      'backend for analysis. Avoid using this feature '
                      'with sensitive images.',
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

  // ------------------------------------------------------------
  // DISCLAIMER
  // ------------------------------------------------------------

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        'Facial emotion detection is an AI-assisted estimate '
            'and may not accurately reflect how someone feels.',
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

// --------------------------------------------------------------
// FACE GUIDE PAINTER
// --------------------------------------------------------------

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
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.72,
      height: size.height * 0.78,
    );

    canvas.drawOval(ovalRect.inflate(12), glowPaint);
    canvas.drawOval(ovalRect, borderPaint);
    canvas.drawOval(ovalRect.deflate(7), innerPaint);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
