import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/services/profile_image_service.dart';
import '../core/services/check_in_service.dart';
import '../core/services/student_mode_service.dart';
import '../models/check_in.dart';
import 'ai_chat_screen.dart';
import 'assessments/assessments_screen.dart';
import 'check_in_screen.dart';
import 'emotion_screen.dart';
import 'exercise/calm_grounding_screen.dart';
import 'insights_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'voice_screen.dart';
import 'student_wellbeing_screen.dart';
import 'text_emotion_screen.dart';
import 'exercise/body_scan_screen.dart';
import 'exercise/thought_reset_screen.dart';
import 'exercise/exam_pressure_reset_screen.dart';
import 'exercise/sleep_wind_down_screen.dart';
import 'exercise/stress_release_screen.dart';
import 'exercise/self_compassion_pause_screen.dart';
import 'exercise/quick_reflection_screen.dart';
import 'exercise/focus_reset_screen.dart';
import 'exercise/mood_lift_screen.dart';
import 'exercise/grounding_screen.dart';
import 'exercise/box_breathing_screen.dart';
import 'exercise/digital_detox_screen.dart';

// ============================================================
// BREAKPOINTS (same as the login screen)
// ============================================================

const double _tabletBreakpoint = 600;
const double _desktopBreakpoint = 900;

// ============================================================
// NAVIGATION MODEL
// ============================================================

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

// ============================================================
// BRAND MARK (logo + "MindMate" wordmark)
// ============================================================

class _BrandMark extends StatelessWidget {
  final double logoHeight;
  final double fontSize;
  final bool showTagline;

  const _BrandMark({
    this.logoHeight = 40,
    this.fontSize = 22,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo1.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
        SizedBox(width: fontSize * 0.45),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wordmark(fontSize),
            if (showTagline) ...[
              const SizedBox(height: 2),
              Text(
                'MENTAL WELLBEING',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.45),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

Widget _wordmark(double fontSize) {
  return RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.05,
      ),
      children: const [
        TextSpan(
          text: 'Mind',
          style: TextStyle(color: AppColors.navy),
        ),
        TextSpan(
          text: 'Mate',
          style: TextStyle(color: AppColors.mint),
        ),
      ],
    ),
  );
}

// ============================================================
// HOME SCREEN (navigation shell)
//   Mobile  : bottom NavigationBar
//   Tablet  : NavigationRail
//   Desktop : branded sidebar
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _studentModeEnabled = true;

  // Keeps the page stack alive when the window is resized and the
  // layout switches between mobile / tablet / desktop.
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    StudentModeService.isEnabled.addListener(_onStudentModeChanged);

    ProfileImageService.initialize();

    _loadStudentMode();
  }

  Future<void> _loadStudentMode() async {
    await StudentModeService.load();

    if (!mounted) return;

    setState(() {
      _studentModeEnabled = StudentModeService.isEnabled.value;
    });
  }

  void _onStudentModeChanged() {
    if (!mounted) return;

    final enabled = StudentModeService.isEnabled.value;

    setState(() {
      if (_studentModeEnabled && !enabled) {
        if (_selectedIndex == 2) {
          _selectedIndex = 0;
        } else if (_selectedIndex > 2) {
          _selectedIndex--;
        }
      } else if (!_studentModeEnabled && enabled) {
        if (_selectedIndex >= 2) {
          _selectedIndex++;
        }
      }

      _studentModeEnabled = enabled;
    });
  }

  @override
  void dispose() {
    StudentModeService.isEnabled.removeListener(_onStudentModeChanged);
    super.dispose();
  }

  void _select(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goHome() => _select(0);

  List<_NavItem> get _navItems => [
    const _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    const _NavItem(
      Icons.favorite_outline_rounded,
      Icons.favorite_rounded,
      'Check-in',
    ),
    if (_studentModeEnabled)
      const _NavItem(
        Icons.school_outlined,
        Icons.school_rounded,
        'Student',
      ),
    const _NavItem(
      Icons.insights_outlined,
      Icons.insights_rounded,
      'Insights',
    ),
    const _NavItem(
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Profile',
    ),
  ];

  List<Widget> _pages(bool hasSideNav) {
    final profileIndex = _studentModeEnabled ? 4 : 3;

    return [
      _HomeFeed(
        // On wide layouts these switch tabs so the sidebar stays visible.
        // On mobile they are null and the feed pushes a route as before.
        onOpenCheckIn: hasSideNav ? () => _select(1) : null,
        onOpenProfile: hasSideNav ? () => _select(profileIndex) : null,
      ),
      CheckInScreen(onBackToHome: _goHome),
      if (_studentModeEnabled)
        StudentWellbeingScreen(onBackToHome: _goHome),
      InsightsScreen(onBackToHome: _goHome),
      ProfileScreen(onBackToHome: _goHome),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _navItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isDesktop = w >= _desktopBreakpoint;
        final isTablet = !isDesktop && w >= _tabletBreakpoint;
        final hasSideNav = isDesktop || isTablet;

        final content = KeyedSubtree(
          key: _contentKey,
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages(hasSideNav),
          ),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned.fill(
                child: hasSideNav
                    ? const _HomeBackground()
                    : const SizedBox.shrink(),
              ),
              Row(
                children: [
                  if (isDesktop)
                    _SideBar(
                      items: items,
                      selectedIndex: _selectedIndex,
                      onSelected: _select,
                    ),
                  if (isTablet) _buildRail(items),
                  Expanded(
                    child: SafeArea(child: content),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: hasSideNav
              ? null
              : NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _select,
            backgroundColor: Colors.white,
            elevation: 0,
            height: 72,
            indicatorColor: AppColors.lightMint,
            labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final item in items)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRail(List<_NavItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          right: BorderSide(color: AppColors.borderMint),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _select,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.lightMint,
          labelType: NavigationRailLabelType.all,
          minWidth: 92,
          selectedIconTheme: const IconThemeData(color: AppColors.mint),
          unselectedIconTheme: IconThemeData(
            color: AppColors.navy.withValues(alpha: 0.6),
          ),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.6),
            fontSize: 12,
          ),
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo1.png',
                  width: 48,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                _wordmark(13),
              ],
            ),
          ),
          destinations: [
            for (final item in items)
              NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DESKTOP SIDEBAR
// ============================================================

class _SideBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SideBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          right: BorderSide(color: AppColors.borderMint),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 28),
                child: _BrandMark(logoHeight: 42, fontSize: 24),
              ),

              Container(
                height: 1,
                margin: const EdgeInsets.only(bottom: 22),
                color: AppColors.borderMint,
              ),

              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 10),
                child: Text(
                  'MENU',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              for (int i = 0; i < items.length; i++)
                _SideBarTile(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightMint.withValues(alpha: 0.9),
                      AppColors.lightMint.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderMint),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: AppColors.mint,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Safe space',
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
                      'MindMate offers supportive guidance and is not a '
                          'substitute for professional care.',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.65),
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
      ),
    );
  }
}

class _SideBarTile extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SideBarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SideBarTile> createState() => _SideBarTileState();
}

class _SideBarTileState extends State<_SideBarTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.lightMint
                  : _hover
                  ? AppColors.lightMint.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.borderMint : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? widget.item.selectedIcon : widget.item.icon,
                  color: selected
                      ? AppColors.mint
                      : AppColors.navy.withValues(alpha: 0.6),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: AppColors.navy.withValues(
                        alpha: selected ? 1 : 0.7,
                      ),
                      fontSize: 14.5,
                      fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 6,
                  height: selected ? 6 : 0,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DECORATIVE BACKGROUND (tablet + desktop, same theme as login)
// ============================================================

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -260,
            right: -200,
            child: Container(
              width: 620,
              height: 620,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderMint, width: 1.5),
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: 120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lightMint.withValues(alpha: 0.5),
                    AppColors.lightMint.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -170,
            bottom: -170,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.mint.withValues(alpha: 0.28),
                    AppColors.lightMint.withValues(alpha: 0.16),
                    AppColors.lightMint.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME FEED
// ============================================================

enum _Size { compact, medium, wide }

class _Tool {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final Widget Function() screen;

  const _Tool(
      this.title,
      this.subtitle,
      this.icon,
      this.iconColor,
      this.background,
      this.screen,
      );
}

class _Exercise {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget Function() screen;

  const _Exercise(this.emoji, this.title, this.subtitle, this.screen);
}

class _HomeFeed extends StatefulWidget {
  final VoidCallback? onOpenCheckIn;
  final VoidCallback? onOpenProfile;

  const _HomeFeed({
    this.onOpenCheckIn,
    this.onOpenProfile,
  });

  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  File? _profileImage;

  CheckIn? _latestCheckIn;
  List<CheckIn> _checkIns = [];
  bool _isLoadingCheckIn = true;

  bool get _hasSideNav => widget.onOpenProfile != null;

  @override
  void initState() {
    super.initState();

    _profileImage = ProfileImageService.profileImageNotifier.value;

    ProfileImageService.profileImageNotifier.addListener(
      _onProfileImageChanged,
    );

    _loadLatestCheckIn();
  }

  Future<void> _loadLatestCheckIn() async {
    try {
      final checkIns = await CheckInService.getCheckIns();

      if (!mounted) return;

      setState(() {
        _checkIns = checkIns;
        _latestCheckIn = checkIns.isNotEmpty ? checkIns.first : null;
        _isLoadingCheckIn = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _checkIns = [];
        _latestCheckIn = null;
        _isLoadingCheckIn = false;
      });
    }
  }

  int _calculateStreak() {
    if (_checkIns.isEmpty) {
      return 0;
    }

    final dates = _checkIns
        .map(
          (checkIn) => DateTime(
        checkIn.createdAt.year,
        checkIn.createdAt.month,
        checkIn.createdAt.day,
      ),
    )
        .toSet();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    DateTime startDate = todayDate;

    // If there is no check-in today, allow the streak
    // to continue from yesterday.
    if (!dates.contains(todayDate)) {
      final yesterday = todayDate.subtract(const Duration(days: 1));

      if (!dates.contains(yesterday)) {
        return 0;
      }

      startDate = yesterday;
    }

    int streak = 0;

    for (int i = 0;; i++) {
      final day = startDate.subtract(Duration(days: i));

      if (dates.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  double _latestPulseScore() {
    final checkIn = _latestCheckIn;

    if (checkIn == null) {
      return 0;
    }

    final moodValue = {
      'Low': 2,
      'Okay': 4,
      'Neutral': 5,
      'Good': 7,
      'Great': 9,
    }[checkIn.mood] ??
        5;

    final average =
        (moodValue + checkIn.energyLevel + checkIn.sleepQuality) / 3;

    return average.clamp(0.0, 10.0);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _onProfileImageChanged() {
    if (!mounted) return;

    setState(() {
      _profileImage = ProfileImageService.profileImageNotifier.value;
    });
  }

  @override
  void dispose() {
    ProfileImageService.profileImageNotifier.removeListener(
      _onProfileImageChanged,
    );

    super.dispose();
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _goToCheckIn(BuildContext context) {
    final callback = widget.onOpenCheckIn;

    if (callback != null) {
      callback();
      return;
    }

    _open(
      context,
      CheckInScreen(onBackToHome: () => Navigator.pop(context)),
    );
  }

  void _goToProfile(BuildContext context) {
    final callback = widget.onOpenProfile;

    if (callback != null) {
      callback();
      return;
    }

    _open(context, const ProfileScreen());
  }

  String _greetingText() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon 👋';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening 👋';
    } else {
      return 'Good night 🌙';
    }
  }

  String _dateLabel() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Uses the width of the content area (screen minus sidebar).
        final w = constraints.maxWidth;
        final size = w >= 880
            ? _Size.wide
            : w >= _tabletBreakpoint
            ? _Size.medium
            : _Size.compact;

        final hPad = size == _Size.wide
            ? 40.0
            : size == _Size.medium
            ? 28.0
            : 20.0;

        final topPad = size == _Size.wide ? 32.0 : 18.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, 40),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasSideNav)
                          _buildGreetingRow(context, size)
                        else ...[
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildGreeting(size),
                        ],

                        SizedBox(height: size == _Size.wide ? 30 : 20),

                        if (size == _Size.wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT: pulse + featured reset
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _buildDailyPulse(context, size),
                                    const SizedBox(height: 24),
                                    _buildFeaturedReset(context),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 28),
                              // RIGHT: AI chat + toolkit
                              Expanded(
                                flex: 6,
                                child: _buildQuickOrbit(context, size),
                              ),
                            ],
                          )
                        else ...[
                          _buildDailyPulse(context, size),
                          const SizedBox(height: 28),
                          _buildQuickOrbit(context, size),
                        ],

                        SizedBox(height: size == _Size.wide ? 44 : 30),

                        _buildExerciseSection(
                          context,
                          size,
                          showFeatured: size != _Size.wide,
                        ),

                        const SizedBox(height: 28),

                        _buildPrivacyNote(),
                      ],
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

  // ==========================================================
  // HEADER / GREETING
  // ==========================================================

  // Mobile: logo + wordmark + profile button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _BrandMark(
              logoHeight: 38,
              fontSize: 21,
              showTagline: false,
            ),
          ),
        ),
        _profileButton(onTap: () => _goToProfile(context)),
      ],
    );
  }

  // Tablet / desktop: greeting + date + profile button
  Widget _buildGreetingRow(BuildContext context, _Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildGreeting(size)),
        const SizedBox(width: 16),
        if (size == _Size.wide) ...[
          _dateChip(),
          const SizedBox(width: 12),
        ],
        _profileButton(onTap: () => _goToProfile(context)),
      ],
    );
  }

  Widget _dateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderMint),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.mint,
            size: 15,
          ),
          const SizedBox(width: 8),
          Text(
            _dateLabel(),
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileButton({required VoidCallback onTap}) {
    // Image.file is not supported on Flutter web, so fall back to the icon.
    final showImage = _profileImage != null && !kIsWeb;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderMint, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: showImage
              ? ClipOval(
            child: Image.file(
              _profileImage!,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          )
              : const Icon(
            Icons.person_outline_rounded,
            color: AppColors.navy,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(_Size size) {
    final wide = size == _Size.wide;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingText(),
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.6),
            fontSize: wide ? 15 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your mind deserves a moment.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: wide ? 34 : 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.12,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DAILY PULSE
  // ==========================================================

  Widget _buildDailyPulse(BuildContext context, _Size size) {
    final checkIn = _latestCheckIn;

    final pulseScore = _latestPulseScore();
    final pulseValue = (pulseScore / 10).clamp(0.0, 1.0);
    final pulseNumber = pulseScore.round();

    final energy = checkIn != null ? '${checkIn.energyLevel}/10' : '--';

    final streak = _calculateStreak();

    final ringSize = size == _Size.compact ? 88.0 : 100.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.navy, Color(0xFF29495A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -55,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.mint.withValues(alpha: 0.13),
                      width: 24,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -35,
                bottom: -55,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mint.withValues(alpha: 0.035),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
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
                            color: AppColors.mint.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.mint,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'DAILY PULSE',
                                style: TextStyle(
                                  color: AppColors.mint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          checkIn == null
                              ? 'NO DATA'
                              : _isToday(checkIn.createdAt)
                              ? 'TODAY'
                              : 'LATEST',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        SizedBox(
                          width: ringSize,
                          height: ringSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: ringSize,
                                height: ringSize,
                                child: CircularProgressIndicator(
                                  value: _isLoadingCheckIn ? 0 : pulseValue,
                                  strokeWidth: 7,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    AppColors.mint,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isLoadingCheckIn || _latestCheckIn == null
                                        ? '--'
                                        : '$pulseNumber',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Text(
                                    'pulse',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 22),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                checkIn == null
                                    ? 'Your wellbeing snapshot starts with a check-in.'
                                    : 'Your latest wellbeing snapshot is ready.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                checkIn == null
                                    ? 'Complete your first check-in to start tracking your wellbeing.'
                                    : 'Keep checking in gently to build a clearer picture over time.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.68),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: _darkMetric(
                            'MOOD',
                            checkIn?.mood ?? '--',
                            Icons.mood_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _darkMetric(
                            'ENERGY',
                            energy,
                            Icons.bolt_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _darkMetric(
                            'STREAK',
                            streak == 0
                                ? '--'
                                : '$streak ${streak == 1 ? 'day' : 'days'}',
                            Icons.local_fire_department_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => _goToCheckIn(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(
                          Icons.favorite_outline_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Check in with yourself',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mint, size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MENTAL TOOLKIT
  // ==========================================================

  Widget _sectionTitle(String title, String subtitle, {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 38,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.58),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildQuickOrbit(BuildContext context, _Size size) {
    final wide = size == _Size.wide;

    final tools = <_Tool>[
      _Tool(
        'Mood',
        'Record a feeling',
        Icons.mood_outlined,
        const Color(0xFFE29A45),
        const Color(0xFFFFF5E9),
            () => const MoodScreen(),
      ),
      _Tool(
        'Emotion',
        'Scan expression',
        Icons.face_retouching_natural_outlined,
        const Color(0xFFAD76B5),
        const Color(0xFFF8EFF9),
            () => const EmotionScreen(),
      ),
      _Tool(
        'Voice',
        'Explore your voice',
        Icons.mic_none_rounded,
        const Color(0xFF6D9A72),
        const Color(0xFFEEF7EF),
            () => const VoiceScreen(),
      ),
      _Tool(
        'Assessment',
        'Reflect deeper',
        Icons.psychology_outlined,
        const Color(0xFF6B7FD7),
        const Color(0xFFF1F3FC),
            () => const AssessmentsScreen(),
      ),
      _Tool(
        'Progress',
        'See patterns',
        Icons.insights_outlined,
        const Color(0xFF5C8FA8),
        const Color(0xFFEDF5F8),
            () => const ProgressScreen(),
      ),
      _Tool(
        'Text Emotion',
        'Analyze your words',
        Icons.text_fields_rounded,
        AppColors.navy,
        const Color(0xFFEFF7F3),
            () => const TextEmotionScreen(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Your mental toolkit',
          'Choose the kind of support you need right now.',
        ),

        const SizedBox(height: 18),

        // FEATURED AI CHAT CARD
        _HoverLift(
          radius: 22,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _open(context, const AiChatScreen()),
              borderRadius: BorderRadius.circular(22),
              child: Ink(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: wide ? 20 : 15,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF2FAF6), Color(0xFFE6F4EC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderMint),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: AppColors.borderMint),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withValues(alpha: 0.14),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: AppColors.navy,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'AI COMPANION',
                                style: TextStyle(
                                  color: AppColors.mint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.mint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: AppColors.navy.withValues(alpha: 0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'AI Chat',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Talk it out, one moment at a time.',
                            style: TextStyle(
                              color: AppColors.navy.withValues(alpha: 0.65),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.navy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 430 ? 2 : 3;

            return GridView.builder(
              itemCount: tools.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                // Taller cards on wide screens so both columns line up.
                mainAxisExtent: wide ? 150 : 128,
              ),
              itemBuilder: (context, index) {
                final tool = tools[index];

                return _TapCard(
                  onTap: () => _open(context, tool.screen()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: wide ? 50 : 42,
                        height: wide ? 50 : 42,
                        decoration: BoxDecoration(
                          color: tool.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          tool.icon,
                          color: tool.iconColor,
                          size: wide ? 26 : 22,
                        ),
                      ),
                      SizedBox(height: wide ? 14 : 10),
                      Text(
                        tool.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: wide ? 14.5 : 13.5,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.subtitle,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.52),
                          fontSize: wide ? 11.5 : 11,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // EXERCISES
  // ==========================================================

  Widget _miniInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.mint, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedReset(BuildContext context) {
    return _HoverLift(
      radius: 26,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(context, const CalmGroundingScreen()),
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0F8F4), Color(0xFFE4F2EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.borderMint),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  Positioned(
                    right: -25,
                    top: -30,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mint.withValues(alpha: 0.055),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mint.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 31)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.mint,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Text(
                                      'FEATURED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: AppColors.mint,
                                    size: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                '60-Second Calm Reset',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Breathe, ground yourself, '
                                    'and reset after a difficult moment.',
                                style: TextStyle(
                                  color: AppColors.navy.withValues(alpha: 0.6),
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _miniInfo(Icons.timer_outlined, '1 min'),
                                  const SizedBox(width: 12),
                                  _miniInfo(
                                    Icons.self_improvement_outlined,
                                    'Guided',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSection(
      BuildContext context,
      _Size size, {
        required bool showFeatured,
      }) {
    final wide = size == _Size.wide;

    final exercises = <_Exercise>[
      _Exercise('🧘', 'Body Scan', 'Notice physical tension',
              () => const BodyScanScreen()),
      _Exercise('💭', 'Thought Reset', 'Challenge thoughts',
              () => const ThoughtResetScreen()),
      _Exercise('📚', 'Exam Pressure', 'Reduce study stress',
              () => const ExamPressureResetScreen()),
      _Exercise('🌙', 'Sleep Wind-Down', 'Prepare to rest',
              () => const SleepWindDownScreen()),
      _Exercise('⚡', 'Stress Release', 'Release tension',
              () => const StressReleaseScreen()),
      _Exercise('💚', 'Self-Compassion', 'Be kind to yourself',
              () => const SelfCompassionPauseScreen()),
      _Exercise('✍️', 'Quick Reflection', 'Pause and notice',
              () => const QuickReflectionScreen()),
      _Exercise('🎯', 'Focus Reset', 'Regain attention',
              () => const FocusResetScreen()),
      _Exercise('🌤️', 'Mood Lift', 'Shift your mood',
              () => const MoodLiftScreen()),
      _Exercise('🌿', 'Grounding', 'Reconnect now',
              () => const GroundingScreen()),
      _Exercise('🌬️', 'Box Breathing', 'Breathe with rhythm',
              () => const BoxBreathingScreen()),
      _Exercise('📵', 'Digital Detox', 'Take a screen break',
              () => const DigitalDetoxScreen()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'MindMate Reset',
          'Guided tools for the moment you are in.',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderMint),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.mint,
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  '12 TOOLS',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        if (showFeatured) ...[
          _buildFeaturedReset(context),
          const SizedBox(height: 22),
        ],

        // LIBRARY HEADER
        Row(
          children: [
            const Text(
              'EXPLORE',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(height: 1, color: AppColors.borderMint),
            ),
            const SizedBox(width: 10),
            Text(
              '12 guided exercises',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // RESPONSIVE EXERCISE GRID: 3 / 4 / 6 columns
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width < 430
                ? 3
                : width < 760
                ? 4
                : 6;
            final spacing = width < 430 ? 9.0 : 14.0;

            return GridView.builder(
              itemCount: exercises.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: wide ? 136 : 120,
              ),
              itemBuilder: (context, index) {
                final item = exercises[index];

                return _TapCard(
                  padding: const EdgeInsets.all(10),
                  onTap: () => _open(context, item.screen()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: wide ? 46 : 40,
                        height: wide ? 46 : 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            item.emoji,
                            style: TextStyle(fontSize: wide ? 23 : 20),
                          ),
                        ),
                      ),
                      SizedBox(height: wide ? 12 : 9),
                      Text(
                        item.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: wide ? 12.5 : 11.5,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.5),
                          fontSize: wide ? 10.5 : 9.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // PRIVACY
  // ==========================================================

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.45),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your wellbeing information is handled with care. MindMate provides supportive self-reflection tools, AI-powered features and wellbeing insights to help you better understand your patterns.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.55),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOVER LIFT (subtle raise + shadow on web/desktop hover)
// ============================================================

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double radius;

  const _HoverLift({required this.child, required this.radius});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withValues(alpha: _hover ? 0.2 : 0.07),
              blurRadius: _hover ? 26 : 16,
              offset: Offset(0, _hover ? 12 : 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// SHARED TAPPABLE CARD (ripple + hover lift on web/desktop)
// ============================================================

class _TapCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _TapCard({
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      radius: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: AppColors.lightMint.withValues(alpha: 0.35),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderMint),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
