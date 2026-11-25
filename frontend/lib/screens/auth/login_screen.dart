import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // EMAIL VALIDATION  (unchanged)
  // =========================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    // Spaces are never valid inside an email.
    if (email.contains(' ')) {
      return 'Email cannot contain spaces.';
    }

    // Basic structural checks.
    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }

    // Must contain exactly one @.
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

    // Prevent dots at invalid positions.
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Email cannot start or end with a dot.';
    }

    if (domain.startsWith('.') || domain.endsWith('.')) {
      return 'Email domain is invalid.';
    }

    // Prevent consecutive dots.
    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots.';
    }

    // Domain must contain a dot.
    if (!domain.contains('.')) {
      return 'Please enter a valid email domain.';
    }

    // Domain extension should have at least 2 characters.
    final domainParts = domain.split('.');
    final extension = domainParts.last;

    if (extension.length < 2) {
      return 'Please enter a valid email domain.';
    }

    // Allowed characters for a practical email validation.
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

  // =========================================================
  // PASSWORD VALIDATION  (unchanged)
  // =========================================================

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password.';
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
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];+=~`]').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  // =========================================================
  // LOGIN  (unchanged)
  // =========================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text;

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
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': enteredEmail,
          'password': enteredPassword,
        }),
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];

        // Make sure the backend returned an authentication token.
        if (token == null || token is! String || token.isEmpty) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Authentication token was not received. Please try again.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

          return;
        }

        final prefs = await SharedPreferences.getInstance();

        // Store the JWT for authenticated API requests.
        await prefs.setString(
          'auth_token',
          token,
        );

        // Preserve existing email storage.
        await prefs.setString(
          'logged_in_email',
          enteredEmail,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  'Incorrect email or password.',
            ),
            behavior: SnackBarBehavior.floating,
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

  // =========================================================
  // UI HELPERS
  // =========================================================

  static const double _desktopBreakpoint = 900;

  InputDecoration _inputDecoration({
    required String hint,
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
      hintText: hint,
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

  // =========================================================
  // BACKGROUND (same decorative theme as the splash screen)
  // =========================================================

  Widget _buildBackground(double w, double h) {
    // Keep shapes a sensible size on very wide screens.
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
            // Large outline circle (top left)
            Positioned(
              top: -s * 0.62,
              left: -s * 0.48,
              child: ring(s * 1.3),
            ),

            // Mid outline circle (bottom left)
            Positioned(
              bottom: -s * 0.22,
              left: -s * 0.20,
              child: ring(s * 0.55),
            ),

            // Soft mint circle (bottom right)
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

            // Dot grid (top right)
            Positioned(
              top: h * 0.07,
              right: w * 0.05,
              child: const _LoginDotGrid(),
            ),

            // Solid dots
            Positioned(
              top: h * 0.10,
              left: w * 0.30,
              child: const _LoginDot(size: 12),
            ),
            Positioned(
              bottom: h * 0.14,
              left: w * 0.05,
              child: const _LoginDot(size: 12),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LEFT CONTENT (desktop / wide screens only)
  // =========================================================

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
                      'AI Companion for\na Better You',
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
                      'MindMate helps you understand how you feel, '
                          'spot patterns early, and build healthier '
                          'habits, privately and at your own pace.',
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.78),
                        fontSize: 16,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    point(
                      Icons.chat_bubble_outline_rounded,
                      'AI companion',
                      'Talk through stress and worries whenever you need to.',
                    ),
                    point(
                      Icons.show_chart_rounded,
                      'Mood insights',
                      'See how your mood changes over days and weeks.',
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

  // =========================================================
  // LOGIN FORM
  // =========================================================

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOGO (above the title on every screen size)
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 28),

          // TITLE
          Center(
            child: Column(
              children: [
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Continue your journey toward a better you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.7),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // EMAIL
          _fieldLabel('Email'),
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
              hint: 'Enter your email',
              icon: Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 20),

          // PASSWORD
          _fieldLabel('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [
              AutofillHints.password,
            ],
            validator: _validatePassword,
            onFieldSubmitted: (_) {
              if (!_isLoading) {
                _login();
              }
            },
            decoration: _inputDecoration(
              hint: 'Enter your password',
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

          const SizedBox(height: 8),

          // FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
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
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // SIGN UP
          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    color: AppColors.navy,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
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
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
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
        child: _buildForm(),
      ),
    );
  }

  // =========================================================
  // UI
  // =========================================================

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
            // Desktop / wide web: message on the left, form card on the right
            content = Row(
              children: [
                Expanded(flex: 11, child: _buildBrandContent()),
                Expanded(
                  flex: 10,
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: _formCard(maxWidth: 480),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (isTablet) {
            // Tablet: centered card
            content = SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _formCard(maxWidth: 500),
                ),
              ),
            );
          } else {
            // Mobile
            content = SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _buildForm(),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              _buildBackground(w, h),
              Positioned.fill(child: content),
            ],
          );
        },
      ),
    );
  }
}

// ==========================================================================
// DECORATIVE DOT (same as splash screen)
// ==========================================================================

class _LoginDot extends StatelessWidget {
  final double size;

  const _LoginDot({required this.size});

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
// 3 x 3 DOT GRID (same as splash screen)
// ==========================================================================

class _LoginDotGrid extends StatelessWidget {
  const _LoginDotGrid();

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
