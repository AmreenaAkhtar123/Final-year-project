
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

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];+=~`]')
        .hasMatch(password)) {
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
        setState(() {
          _isLoading = false;
        });

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
      if (mounted && _isLoading) {
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
        onPressed: onToggle,
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
                // BACK BUTTON

                _buildBackButton(),

                const SizedBox(height: 24),

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
                    'Create New Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // DESCRIPTION

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

                // VERIFIED EMAIL

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

                // PASSWORD CARD

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

                      // NEW PASSWORD LABEL

                      const Text(
                        'New Password',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // NEW PASSWORD FIELD

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

                      // CONFIRM PASSWORD LABEL

                      const Text(
                        'Confirm New Password',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // CONFIRM PASSWORD FIELD

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

                      // RESET BUTTON

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
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD SECURITY NOTE

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

                // LOGIN NAVIGATION

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

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
