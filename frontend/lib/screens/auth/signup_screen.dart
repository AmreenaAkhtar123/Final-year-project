import 'package:flutter/material.dart';

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
  // NAME VALIDATION
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
  // DATE OF BIRTH VALIDATION
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
  // PASSWORD VALIDATION
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
  // CONFIRM PASSWORD VALIDATION
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
  // DATE PICKER
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
  // SIGN UP
  // ============================================================

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();

    if (!_agreeToTerms) {
      setState(() {});
      return;
    }

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
          'Account information is valid.',
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

                const SizedBox(height: 5),

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

                const SizedBox(height: 28),

                // ==================================================
                // HEADING
                // ==================================================

                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 8),

                      SizedBox(
                        width: 300,
                        child: Text(
                          'Create your personal MindMate account '
                              'and begin your journey toward a better you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // FULL NAME
                // ==================================================

                const Text(
                  'Full Name',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

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

                // ==================================================
                // EMAIL
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

                // ==================================================
                // DATE OF BIRTH
                // ==================================================

                const Text(
                  'Date of Birth',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  validator: _validateDateOfBirth,

                  onTap: _isLoading
                      ? null
                      : _selectDateOfBirth,

                  decoration: _inputDecoration(
                    hintText: 'Select your date of birth',
                    icon: Icons.calendar_today_outlined,

                    suffixIcon: IconButton(
                      onPressed:
                      _isLoading ? null : _selectDateOfBirth,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // GENDER
                // ==================================================
                const Text(
                  'Gender',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

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
                // ==================================================
                // PASSWORD
                // ==================================================

                const Text(
                  'Password',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

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
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

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
                          _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // PASSWORD REQUIREMENTS
                // ==================================================

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

                // ==================================================
                // TERMS & PRIVACY
                // ==================================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Checkbox(
                      value: _agreeToTerms,

                      activeColor: AppColors.mint,

                      onChanged: _isLoading
                          ? null
                          : (value) {
                        setState(() {
                          _agreeToTerms =
                              value ?? false;
                        });
                      },
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                        ),

                        child: Text.rich(
                          TextSpan(
                            text:
                            'I agree to the ',

                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 12,
                              height: 1.4,
                            ),

                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: AppColors.mint,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),

                              const TextSpan(
                                  text: ' and '),


                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppColors.mint,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),

                              const TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ==================================================
                // TERMS ERROR
                // ==================================================

                if (!_agreeToTerms)
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                    ),

                    child: Text(
                      'You must agree to the Terms and Privacy Policy.',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // ==================================================
                // CREATE ACCOUNT BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed:
                    _isLoading ? null : _signUp,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,

                      disabledBackgroundColor:
                      AppColors.mint.withValues(
                        alpha: 0.55,
                      ),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // LOGIN LINK
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
                        'Already have an account? ',

                        style: TextStyle(
                          color: AppColors.navy,
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

                const SizedBox(height: 15),
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
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
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
          width: 1,
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
}