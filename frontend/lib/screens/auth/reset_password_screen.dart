
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const double _desktopBreakpoint = 900;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your new password.';
    }

    if (password.trim().isEmpty) {
      return 'Password cannot contain only spaces.';
    }

    if (password.contains(' ')) {
      return 'Password cannot contain spaces.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    if (password.length > 64) {
      return 'Password cannot exceed 64 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least one number.';
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-\\/[\];+=~`]',
    ).hasMatch(password)) {
      return 'Include at least one special character.';
    }

    return null;
  }

  // ============================================================
  // CONFIRM PASSWORD VALIDATION
  // ============================================================

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ============================================================
  // RESET PASSWORD API
  // ============================================================

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
        Uri.parse(ApiConfig.resetPasswordUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email.trim().toLowerCase(),
          'newPassword': _passwordController.text,
          'confirmPassword': _confirmPasswordController.text,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      Map<String, dynamic> responseData = {};

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (_) {
        responseData = {};
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message']?.toString() ??
                  'Your password has been reset successfully.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.mint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
              (route) => false,
        );
      } else {
        final message = responseData['message']?.toString() ??
            'Unable to reset your password. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFC96F5C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Unable to connect to the server. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFC96F5C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _buildBackButton() {
    return InkWell(
      onTap: _isLoading ? null : () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
    );
  }

  // ============================================================
  // PASSWORD INPUT DECORATION
  // ============================================================

  InputDecoration _passwordDecoration({
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.navy.withValues(alpha: 0.40),
        fontSize: 14,
      ),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.mint,
        size: 21,
      ),
      suffixIcon: IconButton(
        onPressed: _isLoading ? null : onToggle,
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.navy.withValues(alpha: 0.55),
          size: 21,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.borderMint,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.borderMint,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.mint,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
      ),
    );
  }

  // ============================================================
  // DECORATIVE BACKGROUND
  // ============================================================

  Widget _buildBackground(double width, double height) {
    final size = width < 900 ? width : 900.0;

    Widget ring(double diameter) {
      return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderMint,
            width: 1.5,
          ),
        ),
      );
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -size * 0.62,
              left: -size * 0.48,
              child: ring(size * 1.3),
            ),
            Positioned(
              bottom: -size * 0.22,
              left: -size * 0.20,
              child: ring(size * 0.55),
            ),
            Positioned(
              right: -size * 0.22,
              bottom: -size * 0.22,
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(0.25, 0.15),
                    radius: 0.85,
                    colors: [
                      AppColors.mint.withValues(alpha: 0.42),
                      AppColors.lightMint.withValues(alpha: 0.28),
                      AppColors.lightMint.withValues(alpha: 0.08),
                      AppColors.lightMint.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 0.75, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mint.withValues(alpha: 0.12),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: height * 0.07,
              right: width * 0.05,
              child: const _ResetDotGrid(),
            ),
            Positioned(
              top: height * 0.10,
              left: width * 0.30,
              child: const _ResetDot(size: 12),
            ),
            Positioned(
              bottom: height * 0.14,
              left: width * 0.05,
              child: const _ResetDot(size: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP BRAND CONTENT
  // ============================================================

  Widget _buildBrandContent() {
    Widget step(
        String number,
        String title,
        String subtitle,
        ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.72),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 64,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 32,
                      color: AppColors.mint,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'A fresh start,\nwith a safer password',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'You have verified your email. Now choose a '
                          'strong password to protect your MindMate '
                          'account and continue your well-being journey.',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.78),
                        fontSize: 16,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    step(
                      '1',
                      'Create a strong password',
                      'Use uppercase, lowercase, numbers, and symbols.',
                    ),
                    step(
                      '2',
                      'Confirm your password',
                      'Enter the same password in both fields.',
                    ),
                    step(
                      '3',
                      'Sign in again',
                      'Your new password will be ready to use.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(64, 0, 64, 28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Keep your password private and secure.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.55),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PASSWORD FIELDS AND RESET BUTTON
  // ============================================================

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New Password',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: !_isLoading,
          textInputAction: TextInputAction.next,
          validator: _validatePassword,
          onChanged: (_) {
            if (_confirmPasswordController.text.isNotEmpty) {
              _formKey.currentState?.validate();
            }
          },
          decoration: _passwordDecoration(
            hintText: 'Enter new password',
            obscure: _obscurePassword,
            onToggle: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Confirm New Password',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          enabled: !_isLoading,
          textInputAction: TextInputAction.done,
          validator: _validateConfirmPassword,
          onFieldSubmitted: (_) {
            if (!_isLoading) {
              _resetPassword();
            }
          },
          decoration: _passwordDecoration(
            hintText: 'Re-enter new password',
            obscure: _obscureConfirmPassword,
            onToggle: () {
              setState(() {
                _obscureConfirmPassword =
                !_obscureConfirmPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              disabledBackgroundColor:
              AppColors.mint.withValues(alpha: 0.55),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 9),
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAGE FORM
  // ============================================================

  Widget _buildForm({
    required bool showBack,
    required bool innerCard,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack) ...[
            _buildBackButton(),
            const SizedBox(height: 24),
          ],

          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 155,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              'Create New Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Your email has been verified. Create a strong '
                    'new password for your MindMate account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.68),
                  fontSize: 14,
                  height: 1.65,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Verified email
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.mint,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Password form
          if (innerCard)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.045),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set your new password',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a password you have not used before.',
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.60),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildFormFields(),
                ],
              ),
            )
          else
            _buildFormFields(),

          const SizedBox(height: 20),

          // Password security note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 21,
                  color: AppColors.mint,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Use at least 8 characters, including an '
                        'uppercase letter, lowercase letter, number, '
                        'and special character.',
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Login navigation
          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.navy,
              ),
              child: const Text.rich(
                TextSpan(
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
  // RESPONSIVE FORM CARD
  // ============================================================

  Widget _formCard({
    required double maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 40,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderMint,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: _buildForm(
          showBack: false,
          innerCard: false,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final isDesktop = width >= _desktopBreakpoint;
          final isTablet = !isDesktop && width >= 600;

          Widget content;

          if (isDesktop) {
            content = Row(
              children: [
                Expanded(
                  flex: 10,
                  child: _buildBrandContent(),
                ),
                Expanded(
                  flex: 11,
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: _formCard(maxWidth: 600),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (isTablet) {
            content = SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _formCard(maxWidth: 560),
                ),
              ),
            );
          } else {
            content = SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 440,
                    ),
                    child: _buildForm(
                      showBack: true,
                      innerCard: true,
                    ),
                  ),
                ),
              ),
            );
          }

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
            ),
            child: Stack(
              children: [
                _buildBackground(width, height),
                Positioned.fill(child: content),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// DECORATIVE DOT
// ============================================================

class _ResetDot extends StatelessWidget {
  final double size;

  const _ResetDot({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ============================================================
// DECORATIVE DOT GRID
// ============================================================

class _ResetDotGrid extends StatelessWidget {
  const _ResetDotGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
            (_) => Row(
          children: List.generate(
            3,
                (_) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
