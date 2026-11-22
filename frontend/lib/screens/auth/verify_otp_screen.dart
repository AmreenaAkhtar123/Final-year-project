
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

  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

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

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

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

      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (!mounted) return;

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
            content: Text(
              responseData['message'] ??
                  'Unable to verify the code. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to the server. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'Enter 6-digit code',
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.mint,
      ),
      filled: true,
      fillColor: Colors.white,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 25,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.navy,
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 35),


                const Center(
                  child: Text(
                    'Verify Your Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'We have sent a 6-digit verification code '
                        'to your email address. Enter the code below '
                        'to continue resetting your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      height: 1.55,
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

                const SizedBox(height: 35),

                const Text(
                  'Verification Code',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
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

                const SizedBox(height: 25),

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
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
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
