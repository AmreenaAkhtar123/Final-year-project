import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
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

    if (localPart.startsWith('.') ||
        localPart.endsWith('.')) {
      return 'Email cannot start or end with a dot.';
    }

    if (domain.startsWith('.') ||
        domain.endsWith('.')) {
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
  // SEND RESET LINK
  // ============================================================

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Temporary delay.
    // This will later be replaced with the backend API call.
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists with this email, '
              'a password reset link has been sent.',
        ),
        behavior: SnackBarBehavior.floating,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 25,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // BACK BUTTON
                // ==================================================

                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.navy,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // LOGO
                // ==================================================

                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // ICON
                // ==================================================

                Center(
                  child: Container(
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
                      Icons.lock_reset_rounded,
                      size: 36,
                      color: AppColors.mint,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // HEADING
                // ==================================================

                const Center(
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                const Center(
                  child: SizedBox(
                    width: 320,

                    child: Text(
                      'No worries. Enter the email address '
                          'associated with your MindMate account '
                          'and we will help you reset your password.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // ==================================================
                // EMAIL LABEL
                // ==================================================

                const Text(
                  'Email Address',

                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // EMAIL FIELD
                // ==================================================

                TextFormField(
                  controller: _emailController,

                  keyboardType:
                  TextInputType.emailAddress,

                  textInputAction:
                  TextInputAction.done,

                  autofillHints: const [
                    AutofillHints.email,
                  ],

                  validator: _validateEmail,

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _sendResetLink();
                    }
                  },

                  decoration: _inputDecoration(
                    hintText:
                    'Enter your email address',

                    icon:
                    Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // RESET BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed:
                    _isLoading
                        ? null
                        : _sendResetLink,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.mint,

                      disabledBackgroundColor:
                      AppColors.mint.withValues(
                        alpha: 0.55,
                      ),

                      foregroundColor:
                      Colors.white,

                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,

                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Send Reset Link',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // REMEMBER PASSWORD
                // ==================================================

                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      Navigator.pop(context);
                    },

                    child: const Text.rich(
                      TextSpan(
                        text:
                        'Remember your password? ',

                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                        ),

                        children: [
                          TextSpan(
                            text: 'Login',

                            style: TextStyle(
                              color: AppColors.mint,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // SECURITY NOTE
                // ==================================================

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: AppColors.lightMint,

                    borderRadius:
                    BorderRadius.circular(12),

                    border: Border.all(
                      color:
                      AppColors.borderMint,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.mint,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'For your security, we will not '
                              'confirm whether an email is linked '
                              'to an account.',
                          style: TextStyle(
                            color:
                            AppColors.navy
                                .withValues(
                              alpha: 0.75,
                            ),
                            fontSize: 12,
                            height: 1.45,
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
      ),
    );
  }

  // ============================================================
  // COMMON INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      prefixIcon: Icon(
        icon,
        color: AppColors.mint,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.mint,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }
}