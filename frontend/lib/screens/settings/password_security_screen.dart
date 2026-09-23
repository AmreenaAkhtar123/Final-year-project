import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends State<PasswordSecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void initState() {
    super.initState();

    _newController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

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
                'Password updated successfully.',
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Use at least 8 characters.';
    }

    if (value.contains(' ')) {
      return 'Password cannot contain spaces.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter.';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Include at least one number.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) {
      return 'Include at least one special character.';
    }

    return null;
  }

  bool get _hasMinLength => _newController.text.length >= 8;

  bool get _hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_newController.text);

  bool get _hasLowercase =>
      RegExp(r'[a-z]').hasMatch(_newController.text);

  bool get _hasNumber =>
      RegExp(r'\d').hasMatch(_newController.text);

  bool get _hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]')
          .hasMatch(_newController.text);

  bool get _hasNoSpaces =>
      !_newController.text.contains(' ');

  int get _passwordScore {
    if (_newController.text.isEmpty) {
      return 0;
    }

    int score = 0;

    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecial) score++;
    if (_hasNoSpaces) score++;

    return score;
  }

  String get _strengthText {
    switch (_passwordScore) {
      case 0:
        return 'Not started';
      case 1:
      case 2:
        return 'Weak';
      case 3:
      case 4:
        return 'Good';
      case 5:
      case 6:
        return 'Strong';
      default:
        return 'Not started';
    }
  }

  Color _strengthColor() {
    switch (_passwordScore) {
      case 0:
        return AppColors.navy.withValues(alpha: 0.22);
      case 1:
      case 2:
        return const Color(0xFFD98B72);
      case 3:
      case 4:
        return const Color(0xFFD2A94A);
      case 5:
      case 6:
        return AppColors.mint;
      default:
        return AppColors.navy.withValues(alpha: 0.22);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                      _buildHero(),

                      const SizedBox(height: 22),

                      _buildSecurityNotice(),

                      const SizedBox(height: 28),

                      _buildSectionTitle(
                        'SECURITY DETAILS',
                        'Update your account password',
                      ),

                      const SizedBox(height: 12),

                      _buildPasswordCard(),

                      const SizedBox(height: 28),

                      _buildSectionTitle(
                        'PASSWORD CHECKLIST',
                        'Your new password should meet these requirements',
                      ),

                      const SizedBox(height: 12),

                      _buildRequirementsCard(),

                      const SizedBox(height: 28),

                      _buildUpdateButton(),

                      const SizedBox(height: 24),

                      _buildSecurityFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              'Password & Security',
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

  Widget _buildHero() {
    return Container(
      height: 178,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -35,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            bottom: -75,
            left: -40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.035),
              ),
            ),
          ),
          Positioned(
            top: 22,
            right: 22,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              65,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Stay protected.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Keep your MindMate account secure with a strong password.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 11.5,
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

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.mint,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your security matters',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a password that is unique to MindMate '
                      'and difficult for others to guess.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.62),
                    fontSize: 10.5,
                    height: 1.45,
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

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        17,
        16,
        17,
      ),
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
        children: [
          _buildPasswordField(
            label: 'Current Password',
            controller: _currentController,
            hidden: _hideCurrent,
            onToggle: () {
              setState(() {
                _hideCurrent = !_hideCurrent;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter your current password.';
              }
              return null;
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: AppColors.borderMint,
            ),
          ),

          _buildPasswordField(
            label: 'New Password',
            controller: _newController,
            hidden: _hideNew,
            onToggle: () {
              setState(() {
                _hideNew = !_hideNew;
              });
            },
            validator: _validatePassword,
          ),

          if (_newController.text.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildPasswordStrength(),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: AppColors.borderMint,
            ),
          ),

          _buildPasswordField(
            label: 'Confirm New Password',
            controller: _confirmController,
            hidden: _hideConfirm,
            onToggle: () {
              setState(() {
                _hideConfirm = !_hideConfirm;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm your new password.';
              }

              if (value != _newController.text) {
                return 'Passwords do not match.';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: hidden,
          validator: validator,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: AppColors.mint,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              splashRadius: 20,
              icon: Icon(
                hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.navy.withValues(alpha: 0.42),
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.mint,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFD98B72),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFD98B72),
                width: 1.4,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrength() {
    final int score = _passwordScore;
    final Color strengthColor = _strengthColor();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        13,
        12,
        13,
        11,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Password strength',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _strengthText,
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: List.generate(
              6,
                  (index) {
                final bool active = index < score;

                return Expanded(
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(
                      right: index == 5 ? 0 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? strengthColor
                          : AppColors.borderMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Wrap(
        spacing: 9,
        runSpacing: 9,
        children: [
          _buildRequirement(
            '8+ characters',
            _hasMinLength,
          ),
          _buildRequirement(
            'Uppercase',
            _hasUppercase,
          ),
          _buildRequirement(
            'Lowercase',
            _hasLowercase,
          ),
          _buildRequirement(
            'Number',
            _hasNumber,
          ),
          _buildRequirement(
            'Special character',
            _hasSpecial,
          ),
          _buildRequirement(
            'No spaces',
            _hasNoSpaces && _newController.text.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(
      String text,
      bool completed,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.lightMint
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed
              ? AppColors.mint.withValues(alpha: 0.45)
              : AppColors.borderMint,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: completed
                ? AppColors.mint
                : AppColors.navy.withValues(alpha: 0.25),
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: completed
                  ? AppColors.navy
                  : AppColors.navy.withValues(alpha: 0.48),
              fontSize: 10,
              fontWeight: completed
                  ? FontWeight.w700
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: _changePassword,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_reset_rounded,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'Update Password',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        15,
        16,
        15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
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
                  'A small step for your privacy',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Never reuse your MindMate password on other services.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.52),
                    fontSize: 9.8,
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
}