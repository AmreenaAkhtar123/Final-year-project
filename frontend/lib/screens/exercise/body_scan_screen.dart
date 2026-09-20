import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  Timer? _timer;

  int _regionIndex = 0;
  int _activityIndex = 0;
  int _seconds = 8;

  bool _sessionStarted = false;
  bool _sessionComplete = false;
  bool _timerRunning = false;

  double _tensionBefore = 5;
  double _tensionAfter = 5;

  final Map<String, double> _beforeTension = {};
  final Map<String, double> _afterTension = {};

  final List<_ScanRegion> _regions = const [
    _ScanRegion(
      name: 'Face & Jaw',
      icon: Icons.face_retouching_natural_rounded,
      color: Color(0xFFEAF6F0),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Notice your face',
          instruction:
          'Bring your attention to your forehead, eyes, cheeks and jaw. Notice what is already there without trying to change it.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.breathe,
          title: 'Soften with your breath',
          instruction:
          'Take a slow breath in. As you breathe out, let your forehead and the muscles around your eyes soften.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Release your jaw',
          instruction:
          'Let your teeth separate slightly. Allow your tongue to rest naturally and let your jaw become heavy.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Neck & Shoulders',
      icon: Icons.accessibility_new_rounded,
      color: Color(0xFFEFF7F3),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Find the tension',
          instruction:
          'Notice your neck and shoulders. Are they heavy, raised, tight, warm or relaxed?',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.activate,
          title: 'Gently lift',
          instruction:
          'Slowly bring your shoulders toward your ears. Keep the movement gentle. Notice the feeling of tension.',
          duration: 6,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Let them drop',
          instruction:
          'Breathe out slowly and allow your shoulders to drop. Notice the difference between tension and release.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Chest & Breathing',
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFEAF6F0),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Observe your breathing',
          instruction:
          'Notice where you feel your breath most clearly. There is nothing you need to fix.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.breathe,
          title: 'Slow the exhale',
          instruction:
          'Breathe in gently. Then allow your exhale to become a little slower and longer.',
          duration: 10,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Create space',
          instruction:
          'Allow your chest and upper body to soften as you breathe out.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Arms & Hands',
      icon: Icons.pan_tool_alt_outlined,
      color: Color(0xFFEFF7F3),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Notice your hands',
          instruction:
          'Feel your palms, fingers, wrists and arms. Notice temperature, pressure or tingling.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.activate,
          title: 'Gentle fist',
          instruction:
          'Make a gentle fist with both hands. Notice the tension without squeezing too hard.',
          duration: 6,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Open and release',
          instruction:
          'Slowly open your hands. Let your fingers loosen and notice the feeling of release.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Abdomen',
      icon: Icons.circle_outlined,
      color: Color(0xFFEAF6F0),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Notice your abdomen',
          instruction:
          'Bring gentle attention to your abdomen. Notice movement as you breathe.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.breathe,
          title: 'Breathe into the belly',
          instruction:
          'Allow your abdomen to expand naturally as you breathe in and soften as you breathe out.',
          duration: 10,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Let your belly soften',
          instruction:
          'Release any unnecessary holding. Let your abdomen move naturally with each breath.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Back',
      icon: Icons.airline_seat_recline_normal_rounded,
      color: Color(0xFFEFF7F3),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Feel the support',
          instruction:
          'Notice where your back meets the chair, bed or floor. Feel the support underneath you.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.breathe,
          title: 'Breathe into the back',
          instruction:
          'Imagine your breath creating gentle space around your upper and lower back.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Allow support',
          instruction:
          'Let your back become a little heavier. You do not need to hold yourself up more than necessary.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Hips & Pelvis',
      icon: Icons.accessibility_rounded,
      color: Color(0xFFEAF6F0),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Notice your weight',
          instruction:
          'Bring awareness to your hips and pelvis. Notice pressure, weight and contact with the surface beneath you.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.breathe,
          title: 'Ground yourself',
          instruction:
          'Take a slow breath and imagine your weight settling downward into the surface beneath you.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Let yourself settle',
          instruction:
          'Allow your hips to become heavy and supported. There is nowhere else you need to be right now.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Legs',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFFEFF7F3),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Scan your legs',
          instruction:
          'Notice your thighs, knees and calves. Look for heaviness, tension, warmth or ease.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.activate,
          title: 'Gentle leg tension',
          instruction:
          'Gently press your feet or legs into the surface beneath you. Notice the muscles becoming active.',
          duration: 6,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Release completely',
          instruction:
          'Stop pressing and let your legs become heavy. Notice the contrast between effort and relaxation.',
          duration: 8,
        ),
      ],
    ),
    _ScanRegion(
      name: 'Feet',
      icon: Icons.directions_walk_outlined,
      color: Color(0xFFEAF6F0),
      activities: [
        _ScanActivity(
          type: _ActivityType.notice,
          title: 'Feel your feet',
          instruction:
          'Notice your ankles, heels, soles and toes. Feel the connection between your feet and the ground.',
          duration: 8,
        ),
        _ScanActivity(
          type: _ActivityType.activate,
          title: 'Feel the ground',
          instruction:
          'Gently press your feet into the ground. Notice the stability underneath you.',
          duration: 6,
        ),
        _ScanActivity(
          type: _ActivityType.release,
          title: 'Ground and release',
          instruction:
          'Relax your feet while keeping a gentle sense of connection with the ground.',
          duration: 8,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  _ScanRegion get _currentRegion => _regions[_regionIndex];

  _ScanActivity get _currentActivity =>
      _currentRegion.activities[_activityIndex];

  double get _overallProgress {
    final totalActivities = _regions.length * 3;
    final completedActivities = (_regionIndex * 3) + _activityIndex;

    return completedActivities / totalActivities;
  }

  String get _activityLabel {
    switch (_currentActivity.type) {
      case _ActivityType.notice:
        return 'NOTICE';
      case _ActivityType.breathe:
        return 'BREATHE';
      case _ActivityType.activate:
        return 'ACTIVATE';
      case _ActivityType.release:
        return 'RELEASE';
    }
  }

  IconData get _activityIcon {
    switch (_currentActivity.type) {
      case _ActivityType.notice:
        return Icons.visibility_outlined;
      case _ActivityType.breathe:
        return Icons.air_rounded;
      case _ActivityType.activate:
        return Icons.flash_on_rounded;
      case _ActivityType.release:
        return Icons.spa_outlined;
    }
  }

  void _startSession() {
    setState(() {
      _sessionStarted = true;
      _seconds = _currentActivity.duration;
      _timerRunning = true;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!_timerRunning) return;

        if (_seconds <= 1) {
          timer.cancel();

          if (mounted) {
            setState(() {
              _seconds = 0;
              _timerRunning = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _seconds--;
            });
          }
        }
      },
    );
  }

  void _toggleTimer() {
    if (_seconds == 0) {
      _moveForward();
      return;
    }

    setState(() {
      _timerRunning = !_timerRunning;
    });

    if (_timerRunning) {
      _startTimer();
    }
  }

  void _moveForward() {
    _timer?.cancel();

    if (_activityIndex < _currentRegion.activities.length - 1) {
      setState(() {
        _activityIndex++;
        _seconds = _currentRegion.activities[_activityIndex].duration;
        _timerRunning = false;
      });
      return;
    }

    _showTensionRating();
  }

  void _showTensionRating() {
    _timer?.cancel();

    final regionName = _currentRegion.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double value = _tensionAfter;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
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
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.lightMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.mint,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'How does your $regionName feel now?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Compare what you notice now with how it felt before.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0x871D2B3A),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      value.round().toString(),
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'tension / 10',
                      style: TextStyle(
                        color: Color(0x871D2B3A),
                        fontSize: 10,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.mint,
                        inactiveTrackColor: AppColors.lightMint,
                        thumbColor: AppColors.mint,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: value,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (newValue) {
                          setModalState(() {
                            value = newValue;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Relaxed',
                          style: TextStyle(
                            color: Color(0x871D2B3A),
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          'Very tense',
                          style: TextStyle(
                            color: Color(0x871D2B3A),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: () {
                          _afterTension[regionName] = value;
                          Navigator.pop(context);
                          _nextRegion();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
      },
    );
  }

  void _nextRegion() {
    if (_regionIndex < _regions.length - 1) {
      setState(() {
        _regionIndex++;
        _activityIndex = 0;
        _sessionStarted = true;
        _seconds = _currentRegion.activities[0].duration;
        _timerRunning = false;
      });
    } else {
      _completeScan();
    }
  }

  void _completeScan() {
    setState(() {
      _sessionComplete = true;
    });
  }

  void _restart() {
    _timer?.cancel();

    setState(() {
      _regionIndex = 0;
      _activityIndex = 0;
      _seconds = _regions[0].activities[0].duration;
      _sessionStarted = false;
      _sessionComplete = false;
      _timerRunning = false;
      _beforeTension.clear();
      _afterTension.clear();
    });
  }

  void _showBeforeRating() {
    final regionName = _currentRegion.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double value = _tensionBefore;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
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
                    const Text(
                      'Check in with your body',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'How much tension do you notice in your $regionName?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0x871D2B3A),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      value.round().toString(),
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'tension / 10',
                      style: TextStyle(
                        color: Color(0x871D2B3A),
                        fontSize: 10,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.mint,
                        inactiveTrackColor: AppColors.lightMint,
                        thumbColor: AppColors.mint,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: value,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (newValue) {
                          setModalState(() {
                            value = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: () {
                          _beforeTension[regionName] = value;
                          Navigator.pop(context);
                          _startSession();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'Begin Scan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionComplete) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _sessionStarted
                  ? _buildActiveSession()
                  : _buildWelcomeScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 19,
              color: AppColors.navy,
            ),
          ),
          const Expanded(
            child: Text(
              'Body Scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: _showHowItWorks,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
      child: Column(
        children: [
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1 + (_pulseController.value * 0.035);

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightMint,
                border: Border.all(
                  color: AppColors.borderMint,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  '🧘',
                  style: TextStyle(fontSize: 56),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Reconnect with your body',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'A guided journey through your body to notice tension, release unnecessary effort, and return to the present.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0x871D2B3A),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          _buildSessionInfo(),
          const SizedBox(height: 22),
          _buildBenefits(),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _showBeforeRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded),
                  SizedBox(width: 7),
                  Text(
                    'Begin Body Scan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 13),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.mint,
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'Private • No camera • No microphone',
                style: TextStyle(
                  color: Color(0x871D2B3A),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        children: [
          _infoItem(
            Icons.timer_outlined,
            '4–6 min',
            'Duration',
          ),
          _verticalDivider(),
          _infoItem(
            Icons.accessibility_new_rounded,
            '9 areas',
            'Body scan',
          ),
          _verticalDivider(),
          _infoItem(
            Icons.spa_outlined,
            'Guided',
            'Practice',
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
      IconData icon,
      String value,
      String label,
      ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 21,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0x871D2B3A),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 42,
      color: AppColors.borderMint,
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      ('Notice', 'Become aware of physical sensations.'),
      ('Release', 'Practice letting go of unnecessary tension.'),
      ('Reconnect', 'Return attention to the present moment.'),
    ];

    return Column(
      children: benefits.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.mint,
                  size: 18,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        color: Color(0x871D2B3A),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveSession() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
      child: Column(
        children: [
          _buildProgress(),
          const SizedBox(height: 22),
          _buildRegionIndicator(),
          const SizedBox(height: 17),
          _buildActivityCard(),
          const SizedBox(height: 18),
          _buildTimer(),
          const SizedBox(height: 18),
          _buildGuidanceCard(),
          const SizedBox(height: 24),
          _buildSessionButton(),
          const SizedBox(height: 12),
          Text(
            '${_regionIndex + 1} of ${_regions.length} body areas',
            style: const TextStyle(
              color: Color(0x871D2B3A),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'YOUR PROGRESS',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              '${(_overallProgress * 100).round()}%',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _overallProgress,
            minHeight: 6,
            backgroundColor: AppColors.lightMint,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.mint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionIndicator() {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: _currentRegion.color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _currentRegion.icon,
            color: AppColors.mint,
            size: 23,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BODY AREA ${_regionIndex + 1}',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _currentRegion.name,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${_activityIndex + 1}/3',
          style: const TextStyle(
            color: Color(0x871D2B3A),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(
          '${_regionIndex}_$_activityIndex',
        ),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.navy,
              const Color(0xFF263C4E),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.13),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                _activityIcon,
                color: AppColors.mint,
                size: 29,
              ),
            ),
            const SizedBox(height: 17),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _activityLabel,
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              _currentActivity.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              _currentActivity.instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 11.5,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final duration = _currentActivity.duration;
    final progress = duration == 0 ? 0.0 : _seconds / duration;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: AppColors.lightMint,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.mint,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_seconds',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'sec',
                    style: TextStyle(
                      color: Color(0x871D2B3A),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _seconds == 0
                ? 'Time complete'
                : _timerRunning
                ? 'Stay with the sensation'
                : 'Paused',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceCard() {
    String text;

    switch (_currentActivity.type) {
      case _ActivityType.notice:
        text =
        'You do not need to change anything. Simply observe.';
        break;
      case _ActivityType.breathe:
        text =
        'Keep the breath comfortable. Never force or hold your breath.';
        break;
      case _ActivityType.activate:
        text =
        'Use gentle effort only. Stop if anything feels painful.';
        break;
      case _ActivityType.release:
        text =
        'Let the release happen naturally. Notice the contrast.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.mint,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0x871D2B3A),
                fontSize: 9.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionButton() {
    final isComplete = _seconds == 0;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isComplete ? _moveForward : _toggleTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isComplete
                  ? Icons.arrow_forward_rounded
                  : _timerRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 20,
            ),
            const SizedBox(width: 7),
            Text(
              isComplete
                  ? (_activityIndex == 2
                  ? 'Rate This Area'
                  : 'Next Activity')
                  : _timerRunning
                  ? 'Pause'
                  : 'Resume',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final beforeAverage = _beforeTension.isEmpty
        ? 0.0
        : _beforeTension.values.reduce((a, b) => a + b) /
        _beforeTension.length;

    final afterAverage = _afterTension.isEmpty
        ? 0.0
        : _afterTension.values.reduce((a, b) => a + b) /
        _afterTension.length;

    final change = beforeAverage - afterAverage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
          child: Column(
            children: [
              _buildCompletionHeader(),
              const SizedBox(height: 25),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderMint,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.mint,
                  size: 49,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Body Scan Complete',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'You took a few minutes to slow down, notice and reconnect.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0x871D2B3A),
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 25),
              _buildComparisonCard(
                beforeAverage,
                afterAverage,
                change,
              ),
              const SizedBox(height: 18),
              _buildAreaSummary(),
              const SizedBox(height: 18),
              _buildCompletionInsight(change),
              const SizedBox(height: 27),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _restart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'Scan Again',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.navy,
          ),
        ),
        const Spacer(),
        const Text(
          'Your Session',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildComparisonCard(
      double before,
      double after,
      double change,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your body check-in',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _scoreColumn(
                  'Before',
                  before,
                  AppColors.navy,
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: AppColors.borderMint,
              ),
              Expanded(
                child: _scoreColumn(
                  'After',
                  after,
                  AppColors.mint,
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: AppColors.borderMint,
              ),
              Expanded(
                child: _scoreColumn(
                  'Change',
                  change.abs(),
                  change > 0
                      ? AppColors.mint
                      : const Color(0xFF9A8F72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreColumn(
      String label,
      double value,
      Color color,
      ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x871D2B3A),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          '/ 10',
          style: TextStyle(
            color: Color(0x871D2B3A),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAreaSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body awareness map',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          ..._regions.map((region) {
            final before = _beforeTension[region.name] ?? 0;
            final after = _afterTension[region.name] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      region.icon,
                      color: AppColors.mint,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      region.name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${before.round()} → ${after.round()}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompletionInsight(double change) {
    String message;

    if (change > 1) {
      message =
      'You noticed a meaningful change in overall tension during this session. Keep using body awareness as a short reset when you need it.';
    } else if (change > 0) {
      message =
      'You noticed some change in tension. Even small shifts in awareness can be useful. You can return to this practice whenever you need a pause.';
    } else {
      message =
      'Not every body scan produces an immediate change. The goal is awareness rather than forcing relaxation. You can simply notice and continue.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.mint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MindMate reflection',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0x871D2B3A),
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

  void _showHowItWorks() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(23, 15, 23, 28),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(31),
            ),
          ),
          child: SafeArea(
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
                const Text(
                  'Your Body Scan',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _howItem(
                  Icons.visibility_outlined,
                  'Notice',
                  'Observe sensations without judging them.',
                ),
                _howItem(
                  Icons.air_rounded,
                  'Breathe',
                  'Use comfortable, natural breathing.',
                ),
                _howItem(
                  Icons.flash_on_rounded,
                  'Activate',
                  'Gently create tension when instructed.',
                ),
                _howItem(
                  Icons.spa_outlined,
                  'Release',
                  'Let the muscles soften and notice the difference.',
                ),
                _howItem(
                  Icons.tune_rounded,
                  'Reflect',
                  'Rate the tension you notice before and after.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _howItem(
      IconData icon,
      String title,
      String description,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0x871D2B3A),
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ActivityType {
  notice,
  breathe,
  activate,
  release,
}

class _ScanActivity {
  final _ActivityType type;
  final String title;
  final String instruction;
  final int duration;

  const _ScanActivity({
    required this.type,
    required this.title,
    required this.instruction,
    required this.duration,
  });
}

class _ScanRegion {
  final String name;
  final IconData icon;
  final Color color;
  final List<_ScanActivity> activities;

  const _ScanRegion({
    required this.name,
    required this.icon,
    required this.color,
    required this.activities,
  });
}