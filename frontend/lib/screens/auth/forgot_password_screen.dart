
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
  // EMAIL VALIDATION
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
  // SEND OTP
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
  // EMAIL INPUT DECORATION
  // ============================================================

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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TOP BACK BUTTON
                // ==================================================

                _buildBackButton(),

                const SizedBox(height: 24),

                // ==================================================
                // APP LOGO
                // ==================================================

                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 155,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),



                // ==================================================
                // HEADING
                // ==================================================

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

                // ==================================================
                // DESCRIPTION
                // ==================================================

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

                // ==================================================
                // EMAIL FORM CARD
                // ==================================================

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form heading

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
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // SECURITY INFORMATION
                // ==================================================

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

                const SizedBox(height: 24),

                // ==================================================
                // LOGIN NAVIGATION
                // ==================================================

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

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
