import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showTermsError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAME VALIDATION  (unchanged)
  // ============================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your name.';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters.';
    }

    if (name.length > 50) {
      return 'Name cannot exceed 50 characters.';
    }

    if (RegExp(r'\d').hasMatch(name)) {
      return 'Name cannot contain numbers.';
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`/\\[\];]')
        .hasMatch(name)) {
      return 'Name cannot contain special characters.';
    }

    return null;
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
  // DATE OF BIRTH VALIDATION  (unchanged)
  // ============================================================

  String? _validateDateOfBirth(String? value) {
    if (_selectedDate == null) {
      return 'Please select your date of birth.';
    }

    final today = DateTime.now();

    if (_selectedDate!.isAfter(today)) {
      return 'Date of birth cannot be in the future.';
    }

    final age = today.year -
        _selectedDate!.year -
        ((today.month < _selectedDate!.month ||
            (today.month == _selectedDate!.month &&
                today.day < _selectedDate!.day))
            ? 1
            : 0);

    if (age < 13) {
      return 'You must be at least 13 years old.';
    }

    if (age > 120) {
      return 'Please enter a valid date of birth.';
    }

    return null;
  }

  // ============================================================
  // PASSWORD VALIDATION  (unchanged)
  // ============================================================

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please create a password.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    if (password.length > 64) {
      return 'Password cannot exceed 64 characters.';
    }

    if (password.contains(' ')) {
      return 'Password cannot contain spaces.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];+=~`]')
        .hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }

    final weakPasswords = [
      'password',
      'password123',
      'password@123',
      'password@1',
      '12345678',
      '123456789',
      '1234567890',
      'qwerty123',
      'qwerty@123',
      'admin123',
      'welcome123',
      'letmein123',
    ];

    if (weakPasswords.contains(password.toLowerCase())) {
      return 'Please choose a stronger password.';
    }

    return null;
  }

  // ============================================================
  // CONFIRM PASSWORD VALIDATION  (unchanged)
  // ============================================================

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ============================================================
  // DATE PICKER  (unchanged)
  // ============================================================

  Future<void> _selectDateOfBirth() async {
    FocusScope.of(context).unfocus();

    final today = DateTime.now();

    final initialDate = _selectedDate ??
        DateTime(
          today.year - 18,
          today.month,
          today.day,
        );

    final firstDate = DateTime(
      today.year - 120,
      today.month,
      today.day,
    );

    final lastDate = DateTime(
      today.year - 13,
      today.month,
      today.day,
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select your date of birth',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mint,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
      _dobController.text =
      '${pickedDate.day.toString().padLeft(2, '0')}/'
          '${pickedDate.month.toString().padLeft(2, '0')}/'
          '${pickedDate.year}';
    });

    _formKey.currentState?.validate();
  }

  // ============================================================
  // SIGN UP  (unchanged)
  // ============================================================

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();

    if (!_agreeToTerms) {
      setState(() {
        _showTermsError = true;
      });
      return;
    }

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Server configuration is missing.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'dateOfBirth': _selectedDate!.toIso8601String(),
          'gender': _selectedGender,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Account created successfully.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.mint,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 4,
          ),
        );

        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });

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
                    responseData['message'] ??
                        'Unable to create your account.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFC96F5C),
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
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to the MindMate server.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  static const double _desktopBreakpoint = 900;

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.navy.withValues(alpha: 0.4),
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: AppColors.mint),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: border(AppColors.borderMint, 1),
      enabledBorder: border(AppColors.borderMint, 1),
      focusedBorder: border(AppColors.mint, 1.6),
      errorBorder: border(Colors.redAccent, 1),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  // ============================================================
  // BACKGROUND (same decorative theme as splash + login)
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
              child: const _SignUpDotGrid(),
            ),
            Positioned(
              top: h * 0.10,
              left: w * 0.30,
              child: const _SignUpDot(size: 12),
            ),
            Positioned(
              bottom: h * 0.14,
              left: w * 0.05,
              child: const _SignUpDot(size: 12),
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
    Widget point(IconData icon, String title, String subtitle) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderMint),
              ),
              child: Icon(icon, color: AppColors.mint, size: 22),
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
                      Icons.favorite_border_rounded,
                      size: 30,
                      color: AppColors.mint,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Begin your journey\ntoward a Better You',
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
                      'Create your account to track your mood, talk to your '
                          'AI companion, and understand your well-being, '
                          'privately and at your own pace.',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.78),
                        fontSize: 16,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    point(
                      Icons.school_outlined,
                      'Made for students',
                      'Support built around exams, deadlines, and burnout.',
                    ),
                    point(
                      Icons.chat_bubble_outline_rounded,
                      'AI companion',
                      'Talk through stress and worries whenever you need to.',
                    ),
                    point(
                      Icons.shield_outlined,
                      'Private and secure',
                      'Your personal data is protected and confidential.',
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
              'MindMate offers supportive guidance and is not a '
                  'substitute for professional care.',
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
  // SIGN UP FORM
  // ============================================================

  Widget _buildForm({required bool showBack}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BACK BUTTON (mobile only)
          if (showBack) ...[
            InkWell(
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
            ),
            const SizedBox(height: 5),
          ],

          // LOGO
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 28),

          // HEADING
          Center(
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 320,
                  child: Text(
                    'Create your personal MindMate account '
                        'and begin your journey toward a better you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.7),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // FULL NAME
          _fieldLabel('Full Name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.name,
            ],
            validator: _validateName,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hintText: 'Enter your full name',
              icon: Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 18),

          // EMAIL
          _fieldLabel('Email Address'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
            ],
            validator: _validateEmail,
            decoration: _inputDecoration(
              hintText: 'Enter your email address',
              icon: Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 18),

          // DATE OF BIRTH
          _fieldLabel('Date of Birth'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            validator: _validateDateOfBirth,
            onTap: _isLoading ? null : _selectDateOfBirth,
            decoration: _inputDecoration(
              hintText: 'Select your date of birth',
              icon: Icons.calendar_today_outlined,
              suffixIcon: IconButton(
                onPressed: _isLoading ? null : _selectDateOfBirth,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.navy.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // GENDER
          _fieldLabel('Gender'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: _inputDecoration(
              hintText: 'Select your gender (optional)',
              icon: Icons.person_outline_rounded,
            ),
            dropdownColor: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.mint,
            ),
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            menuMaxHeight: 250,
            items: const [
              DropdownMenuItem(
                value: 'Male',
                child: Text(
                  'Male',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'Female',
                child: Text(
                  'Female',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'Non-binary',
                child: Text(
                  'Non-binary',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'Prefer not to say',
                child: Text(
                  'Prefer not to say',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            onChanged: _isLoading
                ? null
                : (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),

          const SizedBox(height: 18),

          // PASSWORD
          _fieldLabel('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.newPassword,
            ],
            validator: _validatePassword,
            decoration: _inputDecoration(
              hintText: 'Create a strong password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.navy.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // CONFIRM PASSWORD
          _fieldLabel('Confirm Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [
              AutofillHints.newPassword,
            ],
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) {
              if (!_isLoading) {
                _signUp();
              }
            },
            decoration: _inputDecoration(
              hintText: 'Confirm your password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.navy.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // PASSWORD REQUIREMENTS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password requirements',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '• At least 8 characters\n'
                      '• One uppercase letter\n'
                      '• One lowercase letter\n'
                      '• One number\n'
                      '• One special character',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // TERMS & PRIVACY
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                activeColor: AppColors.mint,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;

                    if (_agreeToTerms) {
                      _showTermsError = false;
                    }
                  });
                },
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // TERMS ERROR
          if (!_agreeToTerms && _showTermsError)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                'You must agree to the Terms and Privacy Policy.',
                style: TextStyle(
                  color: Color(0xFFC96F5C),
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // CREATE ACCOUNT BUTTON
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                disabledBackgroundColor: AppColors.mint.withValues(
                  alpha: 0.55,
                ),
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
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // LOGIN LINK
          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                Navigator.pop(context);
              },
              child: const Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                    color: AppColors.navy,
                  ),
                  children: [
                    TextSpan(
                      text: 'Login',
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
    );
  }

  // White card used on tablet and desktop
  Widget _formCard({required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
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
        child: _buildForm(showBack: false),
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
                  child: _formCard(maxWidth: 600),
                ),
              ),
            );
          } else {
            content = SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 25,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _buildForm(showBack: true),
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
// DECORATIVE DOT (same as splash / login)
// ==========================================================================

class _SignUpDot extends StatelessWidget {
  final double size;

  const _SignUpDot({required this.size});

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
// 3 x 3 DOT GRID (same as splash / login)
// ==========================================================================

class _SignUpDotGrid extends StatelessWidget {
  const _SignUpDotGrid();

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
