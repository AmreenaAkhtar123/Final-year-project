import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class QuickReflectionScreen extends StatefulWidget {
  const QuickReflectionScreen({super.key});

  @override
  State<QuickReflectionScreen> createState() =>
      _QuickReflectionScreenState();
}

class _QuickReflectionScreenState extends State<QuickReflectionScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _isCompleted = false;

  late AnimationController _animationController;

  String? _selectedMoment;
  String? _selectedFeeling;
  String? _selectedNeed;
  String? _selectedPerspective;

  final TextEditingController _reflectionController =
  TextEditingController();

  final TextEditingController _takeawayController =
  TextEditingController();

  String? _momentError;
  String? _feelingError;
  String? _needError;
  String? _reflectionError;
  String? _perspectiveError;
  String? _takeawayError;

  final List<Map<String, dynamic>> _moments = [
    {
      'title': 'A small win',
      'subtitle': 'Something went better than expected',
      'emoji': '✨',
    },
    {
      'title': 'A difficult moment',
      'subtitle': 'Something that took more from you',
      'emoji': '🌧️',
    },
    {
      'title': 'Something on my mind',
      'subtitle': 'A thought I keep coming back to',
      'emoji': '💭',
    },
    {
      'title': 'Something I noticed',
      'subtitle': 'Something about myself or today',
      'emoji': '👀',
    },
  ];

  final List<Map<String, dynamic>> _feelings = [
    {
      'title': 'Relieved',
      'emoji': '😮‍💨',
    },
    {
      'title': 'Proud',
      'emoji': '🌟',
    },
    {
      'title': 'Worried',
      'emoji': '😟',
    },
    {
      'title': 'Frustrated',
      'emoji': '😤',
    },
    {
      'title': 'Confused',
      'emoji': '🤔',
    },
    {
      'title': 'Hopeful',
      'emoji': '🌱',
    },
  ];

  final List<Map<String, dynamic>> _needs = [
    {
      'title': 'A break',
      'subtitle': 'I need some space',
      'emoji': '🌿',
    },
    {
      'title': 'Clarity',
      'subtitle': 'I need to understand this',
      'emoji': '💡',
    },
    {
      'title': 'Support',
      'subtitle': 'I do not want to handle it alone',
      'emoji': '🤝',
    },
    {
      'title': 'A next step',
      'subtitle': 'I need to know what to do next',
      'emoji': '🪜',
    },
    {
      'title': 'Nothing right now',
      'subtitle': 'I just want to notice it',
      'emoji': '☁️',
    },
  ];

  final List<Map<String, dynamic>> _perspectives = [
    {
      'title': 'What can I learn from this?',
      'subtitle': 'Look for something useful.',
      'emoji': '🔎',
    },
    {
      'title': 'What is actually in my control?',
      'subtitle': 'Separate action from uncertainty.',
      'emoji': '🎯',
    },
    {
      'title': 'What would I tell someone I care about?',
      'subtitle': 'Step outside your own pressure.',
      'emoji': '💚',
    },
    {
      'title': 'What matters most right now?',
      'subtitle': 'Bring attention back to what counts.',
      'emoji': '🧭',
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reflectionController.dispose();
    _takeawayController.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateCurrentStep() {
    setState(() {
      _momentError = null;
      _feelingError = null;
      _needError = null;
      _reflectionError = null;
      _perspectiveError = null;
      _takeawayError = null;
    });

    if (_step == 0 && _selectedMoment == null) {
      setState(() {
        _momentError = 'Choose one moment to explore.';
      });
      return false;
    }

    if (_step == 1 && _selectedFeeling == null) {
      setState(() {
        _feelingError = 'Choose the feeling that fits best.';
      });
      return false;
    }

    if (_step == 2 && _selectedNeed == null) {
      setState(() {
        _needError = 'Choose what would help you most.';
      });
      return false;
    }

    if (_step == 3) {
      if (_reflectionController.text.trim().isEmpty) {
        setState(() {
          _reflectionError = 'Add a short reflection before continuing.';
        });
        return false;
      }

      if (_reflectionController.text.trim().length < 8) {
        setState(() {
          _reflectionError =
          'Try adding a little more detail to your reflection.';
        });
        return false;
      }
    }

    if (_step == 4 && _selectedPerspective == null) {
      setState(() {
        _perspectiveError = 'Choose the perspective that feels useful.';
      });
      return false;
    }

    if (_step == 5) {
      if (_takeawayController.text.trim().isEmpty) {
        setState(() {
          _takeawayError = 'Write one thing you want to remember.';
        });
        return false;
      }

      if (_takeawayController.text.trim().length < 8) {
        setState(() {
          _takeawayError =
          'Try turning your takeaway into one complete thought.';
        });
        return false;
      }
    }

    return true;
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    if (_step < 5) {
      setState(() {
        _step++;
      });

      _animationController.forward(from: 0);
    } else {
      _completeReflection();
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();

    if (_step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _step--;
    });

    _animationController.forward(from: 0);
  }

  void _completeReflection() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isCompleted = true;
    });
  }

  void _restart() {
    setState(() {
      _step = 0;
      _isCompleted = false;

      _selectedMoment = null;
      _selectedFeeling = null;
      _selectedNeed = null;
      _selectedPerspective = null;

      _reflectionController.clear();
      _takeawayController.clear();

      _momentError = null;
      _feelingError = null;
      _needError = null;
      _reflectionError = null;
      _perspectiveError = null;
      _takeawayError = null;
    });

    _animationController.forward(from: 0);
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionPage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgress(),

            Expanded(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildMomentStep();

      case 1:
        return _buildFeelingStep();

      case 2:
        return _buildNeedStep();

      case 3:
        return _buildReflectionStep();

      case 4:
        return _buildPerspectiveStep();

      case 5:
        return _buildTakeawayStep();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousStep,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 19,
            ),
            color: AppColors.navy,
          ),

          const Expanded(
            child: Column(
              children: [
                Text(
                  'Quick Reflection',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A few minutes for yourself',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          6,
              (index) {
            final active = index <= _step;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 5,
                margin: EdgeInsets.only(
                  right: index == 5 ? 0 : 5,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.mint
                      : AppColors.borderMint,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STEP 1 — MOMENT
  // ============================================================

  Widget _buildMomentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepLabel('START HERE'),

        const SizedBox(height: 14),

        const Text(
          'What is worth noticing?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 29,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'You do not need to reflect on your whole day. '
              'Just pick one moment that stands out.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 25),

        ..._moments.map(
              (moment) {
            final selected =
                _selectedMoment == moment['title'];

            return _choiceCard(
              emoji: moment['emoji'],
              title: moment['title'],
              subtitle: moment['subtitle'],
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedMoment = moment['title'];
                  _momentError = null;
                });
              },
            );
          },
        ),

        if (_momentError != null)
          _buildError(_momentError!),
      ],
    );
  }

  // ============================================================
  // STEP 2 — FEELING
  // ============================================================

  Widget _buildFeelingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepLabel('NOTICE'),

        const SizedBox(height: 14),

        const Text(
          'What feeling is sitting underneath it?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'There can be more than one feeling. Choose the one '
              'that feels closest right now.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _feelings.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final feeling = _feelings[index];

            final selected =
                _selectedFeeling == feeling['title'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFeeling = feeling['title'];
                  _feelingError = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.lightMint
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.mint
                        : AppColors.borderMint,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feeling['emoji'],
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      feeling['title'],
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (_feelingError != null)
          _buildError(_feelingError!),

        const SizedBox(height: 24),

        _buildInsightTip(
          'Naming a feeling can make an unclear experience '
              'feel a little easier to understand.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3 — NEED
  // ============================================================

  Widget _buildNeedStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepLabel('CHECK IN'),

        const SizedBox(height: 14),

        const Text(
          'What might you need right now?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 29,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Instead of trying to fix everything, pause and '
              'identify what would actually help.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 25),

        ..._needs.map(
              (need) {
            final selected =
                _selectedNeed == need['title'];

            return _choiceCard(
              emoji: need['emoji'],
              title: need['title'],
              subtitle: need['subtitle'],
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedNeed = need['title'];
                  _needError = null;
                });
              },
            );
          },
        ),

        if (_needError != null)
          _buildError(_needError!),
      ],
    );
  }

  // ============================================================
  // STEP 4 — REFLECTION
  // ============================================================

  Widget _buildReflectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepLabel('EXPLORE'),

        const SizedBox(height: 14),

        const Text(
          'What is this moment trying to tell you?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'There is no perfect answer. Follow the first '
              'thought that feels meaningful.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.navy,
                Color(0xFF30475A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💭',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _reflectionPrompt(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: TextField(
            controller: _reflectionController,
            maxLines: 8,
            textCapitalization:
            TextCapitalization.sentences,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText:
              'What comes to mind?',
              hintStyle: TextStyle(
                color: Colors.black38,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),

        if (_reflectionError != null)
          _buildError(_reflectionError!),

        const SizedBox(height: 14),

        _buildSmallNote(
          Icons.lock_outline_rounded,
          'Take your time. There is no right or wrong response.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 5 — PERSPECTIVE
  // ============================================================

  Widget _buildPerspectiveStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepLabel('LOOK AGAIN'),

        const SizedBox(height: 14),

        const Text(
          'Which perspective would help you most?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'You are not changing what happened. You are simply '
              'choosing another way to look at it.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 25),

        ..._perspectives.map(
              (perspective) {
            final selected =
                _selectedPerspective == perspective['title'];

            return _choiceCard(
              emoji: perspective['emoji'],
              title: perspective['title'],
              subtitle: perspective['subtitle'],
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedPerspective =
                  perspective['title'];
                  _perspectiveError = null;
                });
              },
            );
          },
        ),

        if (_perspectiveError != null)
          _buildError(_perspectiveError!),
      ],
    );
  }

  // ============================================================
  // STEP 6 — TAKEAWAY
  // ============================================================

  Widget _buildTakeawayStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepLabel('TAKEAWAY'),

        const SizedBox(height: 14),

        const Text(
          'What do you want to carry forward?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 29,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Finish with one small thought, intention, or reminder '
              'you can take into the rest of your day.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              '🌱',
              style: TextStyle(fontSize: 42),
            ),
          ),
        ),

        const SizedBox(height: 22),

        const Center(
          child: Text(
            'One useful thought is enough.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: TextField(
            controller: _takeawayController,
            maxLines: 6,
            textCapitalization:
            TextCapitalization.sentences,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText:
              'For the rest of today, I want to remember...',
              hintStyle: TextStyle(
                color: Colors.black38,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),

        if (_takeawayError != null)
          _buildError(_takeawayError!),
      ],
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 13, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.borderMint.withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_step > 0)
            SizedBox(
              width: 58,
              height: 54,
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(
                    color: AppColors.borderMint,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.navy,
                ),
              ),
            ),

          if (_step > 0)
            const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _step == 5
                    ? 'Finish Reflection'
                    : 'Continue',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETION
  // ============================================================

  Widget _buildCompletionPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          child: Column(
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: const BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '🌱',
                  style: TextStyle(fontSize: 46),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Reflection Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'You paused, looked a little deeper, '
                    'and found something worth carrying forward.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              _buildSummaryCard(
                number: '01',
                title: 'The moment',
                value: _selectedMoment ?? '',
              ),

              _buildSummaryCard(
                number: '02',
                title: 'What you noticed',
                value: _selectedFeeling ?? '',
              ),

              _buildSummaryCard(
                number: '03',
                title: 'What you might need',
                value: _selectedNeed ?? '',
              ),

              _buildSummaryCard(
                number: '04',
                title: 'Your reflection',
                value: _reflectionController.text.trim(),
              ),

              _buildSummaryCard(
                number: '05',
                title: 'Your perspective',
                value: _selectedPerspective ?? '',
              ),

              _buildSummaryCard(
                number: '06',
                title: 'Your takeaway',
                value: _takeawayController.text.trim(),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.navy,
                      Color(0xFF30475A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.mint,
                      size: 27,
                    ),
                    SizedBox(height: 13),
                    Text(
                      'A moment of awareness matters.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You do not always need to solve a problem. '
                          'Sometimes understanding what is happening '
                          'is already a meaningful step.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 11),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _restart,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    side: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Reflect Again',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
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

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _stepLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.mint,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _choiceCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : AppColors.borderMint,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : AppColors.lightMint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 25),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: selected
                  ? AppColors.mint
                  : AppColors.borderMint,
              size: selected ? 22 : 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTip(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallNote(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.mint,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String number,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
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
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.lightMint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.mint,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
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

  String _reflectionPrompt() {
    if (_selectedMoment == 'A small win') {
      return 'What did this moment show you about your effort, progress, or ability?';
    }

    if (_selectedMoment == 'A difficult moment') {
      return 'What do you think made this moment difficult for you?';
    }

    if (_selectedMoment == 'Something on my mind') {
      return 'Why do you think your mind keeps returning to this?';
    }

    return 'What did you notice about yourself that you might normally overlook?';
  }
}