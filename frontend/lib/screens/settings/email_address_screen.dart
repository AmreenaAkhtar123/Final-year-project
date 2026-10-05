import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

class EmailAddressScreen extends StatefulWidget {
  const EmailAddressScreen({super.key});

  @override
  State<EmailAddressScreen> createState() =>
      _EmailAddressScreenState();
}

class _EmailAddressScreenState extends State<EmailAddressScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final loggedInEmail =
      prefs.getString('logged_in_email');

      if (loggedInEmail == null || loggedInEmail.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final baseUrl = dotenv.env['API_BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        if (!mounted) return;

        setState(() {
          _emailController.text = loggedInEmail;
          _isLoading = false;
        });

        return;
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/auth/profile?email=${Uri.encodeComponent(loggedInEmail)}',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];

        setState(() {
          _emailController.text =
              user['email'] ?? loggedInEmail;
          _isLoading = false;
        });
      } else {
        setState(() {
          _emailController.text = loggedInEmail;
          _isLoading = false;
        });
      }
    } catch (error) {
      final prefs = await SharedPreferences.getInstance();

      final loggedInEmail =
          prefs.getString('logged_in_email') ?? '';

      if (!mounted) return;

      setState(() {
        _emailController.text = loggedInEmail;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),

              const SizedBox(height: 32),

              _buildHeader(),

              const SizedBox(height: 24),

              _buildEmailCard(),

              const SizedBox(height: 18),

              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    AppColors.navy.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.navy,
                size: 18,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Text(
            'Email Address',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: const Icon(
            Icons.email_outlined,
            color: AppColors.mint,
            size: 28,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Your email address',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'This email is connected to your MindMate account.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.48),
            fontSize: 11.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMAIL CARD
  // ============================================================

  Widget _buildEmailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EMAIL ADDRESS',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.45),
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mint,
                  ),
                ),
              ),
            )
                : TextField(
              controller: _emailController,
              keyboardType:
              TextInputType.emailAddress,
              enabled: false,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.mint,
                  size: 19,
                ),
                prefixIconConstraints:
                BoxConstraints(
                  minWidth: 32,
                  minHeight: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.45),
            size: 18,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'Your email address is used to identify your MindMate account and sign you in securely.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.52),
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}