
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/constants/app_colors.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  static const double _desktopBreakpoint = 900;

  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // OTP VALIDATION
  // ============================================================

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Please enter the verification code.';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Please enter a valid 6-digit code.';
    }

    return null;
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
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
        Uri.parse(ApiConfig.verifyResetOtpUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email.trim().toLowerCase(),
          'otp': _otpController.text.trim(),
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
          const SnackBar(
            content: Text('Email verified successfully.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.mint,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    responseData['message']?.toString() ??
                        'Unable to verify the code. Please try again.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC96F5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(
                color: Color(0xFFC96F5C),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 4,
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
          backgroundColor: AppColors.navy,
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
  // UI HELPERS
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'Enter 6-digit code',
      hintStyle: TextStyle(
        color: AppColors.navy.withValues(alpha: 0.40),
        fontSize: 14,
      ),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.mint,
        size: 21,
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
              child: const _OtpDotGrid(),
            ),
            Positioned(
              top: height * 0.10,
              left: width * 0.30,
              child: const _OtpDot(size: 12),
            ),
            Positioned(
              bottom: height * 0.14,
              left: width * 0.05,
              child: const _OtpDot(size: 12),
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
                      Icons.verified_user_outlined,
                      size: 32,
                      color: AppColors.mint,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'A quick check,\nthen you’re back',
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
                      'We want to make sure your account stays safe. '
                          'Verify your email with the code we sent you '
                          'and continue resetting your password.',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.78),
                        fontSize: 16,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    step(
                      '1',
                      'Check your inbox',
                      'Find the 6-digit code sent to your email.',
                    ),
                    step(
                      '2',
                      'Enter your code',
                      'Type the code carefully in the verification field.',
                    ),
                    step(
                      '3',
                      'Create a new password',
                      'After verification, choose a new password.',
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
              'Never share your verification code with anyone.',
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
  // OTP FIELD AND BUTTON
  // ============================================================

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          maxLength: 6,
          enabled: !_isLoading,
          validator: _validateOtp,
          onFieldSubmitted: (_) {
            if (!_isLoading) {
              _verifyOtp();
            }
          },
          decoration: _inputDecoration().copyWith(
            counterText: '',
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
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
                  'Verify Code',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 9),
                Icon(
                  Icons.arrow_forward_rounded,
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
              'Verify Your Email',
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
                'We have sent a 6-digit verification code '
                    'to your email address. Enter the code below '
                    'to continue resetting your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.68),
                  fontSize: 14,
                  height: 1.65,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              widget.email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mint,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 30),

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
              child: _buildFormFields(),
            )
          else
            _buildFormFields(),

          const SizedBox(height: 20),

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
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 19,
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your security matters',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your verification code expires after '
                            '5 minutes. Never share your code with anyone.',
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.70),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.navy,
              ),
              child: const Text.rich(
                TextSpan(
                  text: 'Back to ',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Forgot Password',
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

class _OtpDot extends StatelessWidget {
  final double size;

  const _OtpDot({
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

class _OtpDotGrid extends StatelessWidget {
  const _OtpDotGrid();

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
