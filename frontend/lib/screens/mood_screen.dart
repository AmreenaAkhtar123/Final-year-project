import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/api_config.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;
  double? _intensity;

  String? _moodError;
  String? _intensityError;
  String? _reasonError;
  String? _commentError;

  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😄',
      'label': 'Very Happy',
      'color': Color(0xFFF5C96A),
    },
    {
      'emoji': '🙂',
      'label': 'Happy',
      'color': Color(0xFF8CCF9F),
    },
    {
      'emoji': '😐',
      'label': 'Okay',
      'color': Color(0xFF8DB3C7),
    },
    {
      'emoji': '😔',
      'label': 'Sad',
      'color': Color(0xFF8A9BD1),
    },
    {
      'emoji': '😞',
      'label': 'Very Sad',
      'color': Color(0xFF9A82B8),
    },
  ];

  final List<String> _factors = [
    'Studies',
    'Work',
    'Family',
    'Friends',
    'Sleep',
    'Health',
    'Relationships',
    'Other',
  ];

  final Set<String> _selectedFactors = {};

  final TextEditingController _noteController =
  TextEditingController();

  List<Map<String, dynamic>> _moodHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMood = index;
    });
  }

  void _toggleFactor(String factor) {
    setState(() {
      if (_selectedFactors.contains(factor)) {
        _selectedFactors.remove(factor);
      } else {
        _selectedFactors.add(factor);
      }

      if (_selectedFactors.isNotEmpty) {
        _reasonError = null;
      }
    });
  }

  Future<void> _saveMood() async {
    setState(() {
      _moodError = null;
      _intensityError = null;
      _reasonError = null;
      _commentError = null;

      if (_selectedMood == null) {
        _moodError = 'Please select your mood.';
      }

      if (_intensity == null) {
        _intensityError = 'Please select your mood intensity.';
      }

      if (_selectedFactors.isEmpty) {
        _reasonError = 'Please select at least one reason.';
      }

      if (_noteController.text.trim().isEmpty) {
        _commentError =
        'Write a short note about how you are feeling.';
      }
    });

    if (_moodError != null ||
        _intensityError != null ||
        _reasonError != null ||
        _commentError != null) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedEmail = prefs.getString('logged_in_email');

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to identify your account.'),
          ),
        );

        return;
      }

      final moodLabel = _moods[_selectedMood!]['label'];

      String mood;

      switch (moodLabel) {
        case 'Very Happy':
          mood = 'Great';
          break;
        case 'Happy':
          mood = 'Good';
          break;
        case 'Okay':
          mood = 'Okay';
          break;
        case 'Sad':
        case 'Very Sad':
          mood = 'Low';
          break;
        default:
          mood = 'Okay';
      }

      final response = await http.post(
        Uri.parse(ApiConfig.moodTrackerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': savedEmail.trim().toLowerCase(),
          'mood': mood,
          'moodIntensity': _intensity!.round(),
          'factors': _selectedFactors.toList(),
          'note': _noteController.text.trim(),
        }),
      );

      debugPrint(
        'Mood tracker response: ${response.statusCode}',
      );

      debugPrint(
        'Mood tracker body: ${response.body}',
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final selectedMoodLabel =
        _moods[_selectedMood!]['label'];

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                16,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderMint,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.mint,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Mood Check-In Complete',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Thank you for taking a moment to check in with yourself.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.55),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _moods[_selectedMood!]['emoji'],
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          selectedMoodLabel,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Intensity: ${_intensity!.round()} / 10',
                          style: TextStyle(
                            color: AppColors.navy.withValues(alpha: 0.55),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12.5,
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to save your mood. Please try again.',
            ),
          ),
        );
      }
    } catch (error) {
      debugPrint(
        'Save mood tracker error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save your mood. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _loadMoodHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedEmail = prefs.getString('logged_in_email');

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingHistory = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.moodTrackerUrl}'
              '?email=${Uri.encodeComponent(savedEmail.trim().toLowerCase())}',
        ),
      );

      debugPrint(
        'Mood history response: ${response.statusCode}',
      );

      debugPrint(
        'Mood history body: ${response.body}',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final moods = data['moods'];

        setState(() {
          _moodHistory = moods is List
              ? List<Map<String, dynamic>>.from(moods)
              : [];
          _isLoadingHistory = false;
        });
      } else {
        setState(() {
          _moodHistory = [];
          _isLoadingHistory = false;
        });
      }
    } catch (error) {
      debugPrint(
        'Load mood history error: $error',
      );

      if (!mounted) return;

      setState(() {
        _moodHistory = [];
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _deleteMood(String moodId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Mood Entry?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this mood entry? This action cannot be undone.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.60),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.moodTrackerUrl}/$moodId',
        ),
      );

      debugPrint(
        'Delete mood response: ${response.statusCode}',
      );

      debugPrint(
        'Delete mood body: ${response.body}',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _moodHistory.removeWhere(
                (entry) => entry['_id']?.toString() == moodId,
          );
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                16,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderMint,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.mint,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Mood Entry Deleted',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Your mood entry has been successfully deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.55),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12.5,
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to delete mood entry. Please try again.',
            ),
          ),
        );
      }
    } catch (error) {
      debugPrint(
        'Delete mood error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete mood entry. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
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
                        size: 15,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: const Text(
                      'Mood Tracker',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 34),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              const Text(
                'How are you feeling?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Choose the mood that best describes you right now.',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.52),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              _buildMoodSelector(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Mood intensity',
                'How strongly are you feeling this mood?',
              ),

              const SizedBox(height: 18),

              _buildIntensitySelector(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'What may be affecting your mood?',
                'Select all that apply.',
              ),

              const SizedBox(height: 15),

              _buildFactors(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Add a note',
                'Write anything you would like to remember.',
              ),

              const SizedBox(height: 15),

              _buildNoteField(),

              const SizedBox(height: 30),

              _buildSaveButton(),

              const SizedBox(height: 18),

              _buildMoodHistory(),

              const SizedBox(height: 18),

              _buildPrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood History',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Look back at how your mood has been changing over time.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.50),
            fontSize: 10.5,
          ),
        ),

        const SizedBox(height: 15),

        if (_isLoadingHistory)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.mint,
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (_moodHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.mint,
                    size: 27,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'No mood history yet',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Your saved mood entries will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.50),
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _moodHistory
                .map(
                  (entry) => _buildMoodHistoryCard(entry),
            )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildMoodHistoryCard(
      Map<String, dynamic> entry,
      ) {
    final mood = entry['mood']?.toString() ?? 'Okay';
    final intensity =
    (entry['moodIntensity'] ?? 0).toString();

    final factors = entry['factors'] is List
        ? List<String>.from(
      entry['factors'].map(
            (factor) => factor.toString(),
      ),
    )
        : <String>[];

    final note = entry['note']?.toString() ?? '';

    final createdAt =
    DateTime.tryParse(
      entry['createdAt']?.toString() ?? '',
    );

    final moodEmoji = _getMoodEmoji(mood);
    final moodColor = _getMoodColor(mood);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    moodEmoji,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayMood(mood),
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      createdAt != null
                          ? _formatMoodDate(createdAt)
                          : 'Date unavailable',
                      style: TextStyle(
                        color: AppColors.navy
                            .withValues(alpha: 0.48),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      final moodId = entry['_id']?.toString();

                      if (moodId != null && moodId.isNotEmpty) {
                        _deleteMood(moodId);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 17,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$intensity / 10',
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (factors.isNotEmpty) ...[
            const SizedBox(height: 14),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: factors.map(
                    (factor) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      factor,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],

          if (note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                note,
                style: TextStyle(
                  color: AppColors.navy
                      .withValues(alpha: 0.65),
                  fontSize: 10.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _displayMood(String mood) {
    switch (mood) {
      case 'Great':
        return 'Very Happy';
      case 'Good':
        return 'Happy';
      case 'Okay':
        return 'Okay';
      case 'Low':
        return 'Sad';
      default:
        return mood;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Great':
        return '😄';
      case 'Good':
        return '🙂';
      case 'Okay':
        return '😐';
      case 'Low':
        return '😔';
      default:
        return '😐';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Great':
        return const Color(0xFFF5C96A);
      case 'Good':
        return const Color(0xFF8CCF9F);
      case 'Okay':
        return const Color(0xFF8DB3C7);
      case 'Low':
        return const Color(0xFF8A9BD1);
      default:
        return AppColors.mint;
    }
  }

  String _formatMoodDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;

    final hour = localDate.hour == 0
        ? 12
        : localDate.hour > 12
        ? localDate.hour - 12
        : localDate.hour;

    final minute =
    localDate.minute.toString().padLeft(2, '0');

    final period =
    localDate.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF294253),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.mood_rounded,
              color: AppColors.mint,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Mood Check',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Take a moment to check in with yourself.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10.5,
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

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _moods.length,
                (index) {
              final selected = _selectedMood == index;
              final mood = _moods[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = index;
                    _moodError = null;
                  });
                },
                child: SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: selected
                              ? mood['color'].withValues(alpha: 0.20)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? mood['color']
                                : AppColors.borderMint,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            mood['emoji'],
                            style: const TextStyle(fontSize: 27),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_moodError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_moodError!),
        ],
      ],
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 14,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
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
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.50),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            14,
            16,
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _intensityError != null
                  ? Colors.red
                  : AppColors.borderMint,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '1',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _intensity ?? 5,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.mint,
                      inactiveColor: AppColors.lightMint,
                      onChanged: (value) {
                        setState(() {
                          _intensity = value;
                          _intensityError = null;
                        });
                      },
                    ),
                  ),
                  const Text(
                    '10',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                _intensity == null
                    ? 'Select intensity'
                    : 'Intensity: ${_intensity!.round()} / 10',
                style: TextStyle(
                  color: _intensityError != null
                      ? Colors.red
                      : AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        if (_intensityError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_intensityError!),
        ],
      ],
    );
  }

  Widget _buildFactors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: _factors.map(
                (factor) {
              final selected =
              _selectedFactors.contains(factor);

              return GestureDetector(
                onTap: () {
                  _toggleFactor(factor);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.lightMint
                        : Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: selected
                          ? AppColors.mint
                          : AppColors.borderMint,
                    ),
                  ),
                  child: Text(
                    factor,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 10.5,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),

        if (_reasonError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_reasonError!),
        ],
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _noteController,
          maxLines: 4,
          maxLength: 300,
          onChanged: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _commentError = null;
              });
            }
          },
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: 'How are you feeling today?',
            hintStyle: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 11,
            ),
            filled: true,
            fillColor: Colors.white,
            counterStyle: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 9,
            ),
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.mint,
                width: 1.4,
              ),
            ),
          ),
        ),

        if (_commentError != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(_commentError!),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _saveMood,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              size: 19,
            ),
            SizedBox(width: 7),
            Text(
              'Save Mood',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.mint,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your mood entries are private and are currently stored only for this session.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.60),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}