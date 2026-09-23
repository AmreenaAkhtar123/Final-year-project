import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _analyticsEnabled = false;
  bool _cameraPermission = true;
  bool _microphonePermission = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopBar(),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                36,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildPrivacyHeader(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      'DATA PREFERENCES',
                      'Choose what you are comfortable sharing.',
                    ),

                    const SizedBox(height: 12),

                    _buildDataPreferencesCard(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'DEVICE PERMISSIONS',
                      'Manage access used by MindMate features.',
                    ),

                    const SizedBox(height: 12),

                    _buildPermissionsCard(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'YOUR DATA',
                      'Manage information created inside MindMate.',
                    ),

                    const SizedBox(height: 12),

                    _buildDataActionsCard(),

                    const SizedBox(height: 24),

                    _buildLocalDataNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        20,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Privacy & Data',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------

  Widget _buildPrivacyHeader() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -55,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.10),
              ),
            ),
          ),

          Positioned(
            right: 28,
            bottom: -60,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.045),
                  width: 16,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const Spacer(),

                const Text(
                  'Your privacy matters.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Choose what MindMate can access and keep '
                      'your personal information under your control.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.075),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.mint,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'You are in control',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.55),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.48),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATA PREFERENCES
  // ---------------------------------------------------------------------------

  Widget _buildDataPreferencesCard() {
    return _buildCard(
      children: [
        _buildSwitchTile(
          icon: Icons.analytics_outlined,
          title: 'Anonymous analytics',
          subtitle:
          'Help improve MindMate using non-personal usage information.',
          value: _analyticsEnabled,
          onChanged: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PERMISSIONS
  // ---------------------------------------------------------------------------

  Widget _buildPermissionsCard() {
    return _buildCard(
      children: [
        _buildPermissionTile(
          icon: Icons.camera_alt_outlined,
          title: 'Camera',
          subtitle: 'Used when you choose facial emotion features.',
          enabled: _cameraPermission,
          onTap: () {
            setState(() {
              _cameraPermission = !_cameraPermission;
            });
          },
        ),

        _divider(),

        _buildPermissionTile(
          icon: Icons.mic_none_rounded,
          title: 'Microphone',
          subtitle: 'Used when you choose voice-based mood features.',
          enabled: _microphonePermission,
          onTap: () {
            setState(() {
              _microphonePermission = !_microphonePermission;
            });
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATA ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildDataActionsCard() {
    return _buildCard(
      children: [
        _buildActionTile(
          icon: Icons.download_outlined,
          title: 'Export My Data',
          subtitle:
          'Prepare a copy of the information stored by MindMate.',
          onTap: _exportData,
        ),

        _divider(),

        _buildActionTile(
          icon: Icons.delete_outline_rounded,
          title: 'Delete Local Data',
          subtitle:
          'Remove locally stored demo information from this app.',
          destructive: true,
          onTap: _deleteData,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // GENERIC CARD
  // ---------------------------------------------------------------------------

  Widget _buildCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SWITCH TILE
  // ---------------------------------------------------------------------------

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        15,
        14,
        13,
        14,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.lightMint
                  : AppColors.background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: value
                    ? AppColors.mint.withValues(alpha: 0.30)
                    : AppColors.borderMint,
              ),
            ),
            child: Icon(
              icon,
              color: value
                  ? AppColors.mint
                  : AppColors.navy.withValues(alpha: 0.38),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.44),
                    fontSize: 9.8,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _buildCustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CUSTOM SWITCH
  // ---------------------------------------------------------------------------

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 49,
        height: 29,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? AppColors.mint
              : AppColors.navy.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? AppColors.mint
                : AppColors.borderMint,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PERMISSION TILE
  // ---------------------------------------------------------------------------

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            14,
            14,
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.lightMint
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: enabled
                        ? AppColors.mint.withValues(alpha: 0.30)
                        : AppColors.borderMint,
                  ),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? AppColors.mint
                      : AppColors.navy.withValues(alpha: 0.38),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.44),
                        fontSize: 9.8,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.lightMint
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: enabled
                        ? AppColors.mint.withValues(alpha: 0.25)
                        : AppColors.borderMint,
                  ),
                ),
                child: Text(
                  enabled ? 'On' : 'Off',
                  style: TextStyle(
                    color: enabled
                        ? AppColors.mint
                        : AppColors.navy.withValues(alpha: 0.38),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION TILE
  // ---------------------------------------------------------------------------

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final Color actionColor = destructive
        ? const Color(0xFFC96F5C)
        : AppColors.mint;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            14,
            14,
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: destructive
                      ? const Color(0xFFFFF2EE)
                      : AppColors.lightMint,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: destructive
                        ? const Color(0xFFF1D3CB)
                        : AppColors.borderMint,
                  ),
                ),
                child: Icon(
                  icon,
                  color: actionColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: destructive
                            ? const Color(0xFFC96F5C)
                            : AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.44),
                        fontSize: 9.8,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: destructive
                      ? const Color(0xFFC96F5C)
                      : AppColors.navy,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DIVIDER
  // ---------------------------------------------------------------------------

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.borderMint.withValues(alpha: 0.7),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOCAL DATA NOTE
  // ---------------------------------------------------------------------------

  Widget _buildLocalDataNote() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        15,
        14,
        15,
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.65),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.mint,
              size: 17,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Local demo data',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'MindMate is currently using local/demo data. '
                      'Full account and data controls will be connected '
                      'when the backend is implemented.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.50),
                    fontSize: 9.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXPORT DATA
  // ---------------------------------------------------------------------------

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Export Data',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Your demo wellbeing information is ready to be exported. '
              'Actual file export will be connected with the backend later.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.60),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.navy,
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE DATA
  // ---------------------------------------------------------------------------

  void _deleteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Delete Local Data?',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'This will remove locally stored demo information '
              'from this feature.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.60),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.navy,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Local demo data cleared.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  margin: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    18,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC96F5C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}