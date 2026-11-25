import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/constants/app_colors.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL VALIDATION  (unchanged)
  // ============================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    if (email.contains(' ')) {
      return 'Email cannot contain spaces.';
    }

    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }

    if (email.split('@').length != 2) {
      return 'Please enter a valid email address.';
    }

    final parts = email.split('@');
    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty) {
      return 'Please enter the part before @.';
    }

    if (domain.isEmpty) {
      return 'Please enter an email domain.';
    }

    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Email cannot start or end with a dot.';
    }

    if (domain.startsWith('.') || domain.endsWith('.')) {
      return 'Email domain is invalid.';
    }

    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots.';
    }

    if (!domain.contains('.')) {
      return 'Please enter a valid email domain.';
    }

    final domainParts = domain.split('.');
    final extension = domainParts.last;

    if (extension.length < 2) {
      return 'Please enter a valid email domain.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  // ============================================================
  // SEND OTP  (unchanged)
  // ============================================================

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim().toLowerCase();

    try {
      final response = await http
          .post(
        Uri.parse(ApiConfig.forgotPasswordUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              email: email,
            ),
          ),
        );
      } else {
        final message = responseData['message']?.toString() ??
            'Unable to send the verification code. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.navy,
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

  static const double _desktopBreakpoint = 900;

  // BACK BUTTON
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

  // EMAIL INPUT DECORATION
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.navy.withValues(alpha: 0.40),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: const Icon(
        Icons.email_outlined,
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
  // BACKGROUND (same decorative theme as splash / login / signup)
  // ============================================================

  Widget _buildBackground(double w, double h) {
    final s = w < 900 ? w : 900.0;

    Widget ring(double size) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderMint, width: 1.5),
        ),
      );
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -s * 0.62,
              left: -s * 0.48,
              child: ring(s * 1.3),
            ),
            Positioned(
              bottom: -s * 0.22,
              left: -s * 0.20,
              child: ring(s * 0.55),
            ),
            Positioned(
              right: -s * 0.22,
              bottom: -s * 0.22,
              child: Container(
                width: s * 0.8,
                height: s * 0.8,
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
              top: h * 0.07,
              right: w * 0.05,
              child: const _ForgotDotGrid(),
            ),
            Positioned(
              top: h * 0.10,
              left: w * 0.30,
              child: const _ForgotDot(size: 12),
            ),
            Positioned(
              bottom: h * 0.14,
              left: w * 0.05,
              child: const _ForgotDot(size: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LEFT CONTENT (desktop / wide screens only)
  // ============================================================

  Widget _buildBrandContent() {
    // The recovery flow is a real sequence, so numbered steps fit here.
    Widget step(String number, String title, String subtitle) {
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
                border: Border.all(color: AppColors.borderMint),
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
                constraints: const BoxConstraints(maxWidth: 480),
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
                      'Get back into your\naccount, securely',
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
                      'Locked out? It happens to everyone. Follow three '
                          'quick steps and you will be back to your '
                          'well-being journey in no time.',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.78),
                        fontSize: 16,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    step(
                      '1',
                      'Enter your email',
                      'Use the address linked to your MindMate account.',
                    ),
                    step(
                      '2',
                      'Verify the code',
                      'We send a verification code to your inbox.',
                    ),
                    step(
                      '3',
                      'Set a new password',
                      'Choose a strong password and log back in.',
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
  // EMAIL FIELD + BUTTON
  // ============================================================

  Widget _buildFormFields({required bool showHeading}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          const Text(
            'Reset your password',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your registered email address below.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.60),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
        ],

        // Email label
        const Text(
          'Email Address',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 9),

        // Email field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [
            AutofillHints.email,
          ],
          enabled: !_isLoading,
          validator: _validateEmail,
          onFieldSubmitted: (_) {
            if (!_isLoading) {
              _sendOtp();
            }
          },
          decoration: _inputDecoration(
            hintText: 'Enter your email address',
            icon: Icons.email_outlined,
          ),
        ),

        const SizedBox(height: 22),

        // Send OTP button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
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
                  'Send Verification Code',
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
  // PAGE CONTENT
  //   innerCard = true  -> mobile (fields sit in their own card)
  //   innerCard = false -> tablet/desktop (outer card already exists)
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
          // TOP BACK BUTTON (mobile only)
          if (showBack) ...[
            _buildBackButton(),
            const SizedBox(height: 24),
          ],

          // APP LOGO
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 155,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          // HEADING
          const Center(
            child: Text(
              'Forgot Password?',
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

          // DESCRIPTION
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                'Don’t worry! It happens. Enter the email '
                    'address linked to your MindMate account '
                    'and we’ll send you a verification code '
                    'to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.68),
                  fontSize: 14,
                  height: 1.65,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // EMAIL FORM
          if (innerCard)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.borderMint,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.045),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildFormFields(showHeading: true),
            )
          else
            _buildFormFields(showHeading: false),

          const SizedBox(height: 20),

          // SECURITY INFORMATION
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
                        'Your verification code will expire after '
                            '5 minutes. Never share your code with anyone.',
                        style: TextStyle(
                          color: AppColors.navy.withValues(
                            alpha: 0.70,
                          ),
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

          // LOGIN NAVIGATION
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
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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

  // White card used on tablet and desktop
  Widget _formCard({required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderMint),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: _buildForm(showBack: false, innerCard: false),
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
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final isDesktop = w >= _desktopBreakpoint;
          final isTablet = !isDesktop && w >= 600;

          Widget content;

          if (isDesktop) {
            content = Row(
              children: [
                Expanded(flex: 10, child: _buildBrandContent()),
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
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _buildForm(showBack: true, innerCard: true),
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
                _buildBackground(w, h),
                Positioned.fill(child: content),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================================
// DECORATIVE DOT (same as splash / login / signup)
// ==========================================================================

class _ForgotDot extends StatelessWidget {
  final double size;

  const _ForgotDot({required this.size});

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

// ==========================================================================
// 3 x 3 DOT GRID (same as splash / login / signup)
// ==========================================================================

class _ForgotDotGrid extends StatelessWidget {
  const _ForgotDotGrid();

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
