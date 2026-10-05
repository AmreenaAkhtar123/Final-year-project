import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/constants/app_colors.dart';

class EmailAddressScreen extends StatefulWidget {
  const EmailAddressScreen({super.key});

  @override
  State<EmailAddressScreen> createState() => _EmailAddressScreenState();
}

class _EmailAddressScreenState extends State<EmailAddressScreen> {
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('logged_in_email') ?? '';

      final baseUrl = dotenv.env['API_BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty || savedEmail.isEmpty) {
        if (mounted) {
          setState(() {
            _email = savedEmail;
            _isLoading = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/auth/profile?email=${Uri.encodeComponent(savedEmail)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _email = data['user']?['email'] ?? savedEmail;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _email = savedEmail;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('logged_in_email') ?? '';

      if (mounted) {
        setState(() {
          _email = savedEmail;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyEmail() async {
    if (_email.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: _email),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10),
            Text('Email address copied'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.mint,
                  strokeWidth: 2.5,
                ),
              )
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),
                    _buildEmailCard(),
                    const SizedBox(height: 24),
                    _buildSecurityCard(),
                    const SizedBox(height: 24),
                    _buildWhyEmailCard(),
                    const SizedBox(height: 20),
                    _buildPrivacyNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Email Address',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your account email',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'This email is connected to your MindMate account and helps keep your account secure.',
          style: TextStyle(
            color: AppColors.navy.withOpacity(0.62),
            fontSize: 14.5,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.13),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.mint.withOpacity(0.28),
                  ),
                ),
                child: const Icon(
                  Icons.alternate_email_rounded,
                  color: AppColors.mint,
                  size: 27,
                ),
              ),
              const Spacer(),
              _buildVerifiedBadge(),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'PRIMARY ACCOUNT EMAIL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _email.isEmpty ? 'No email available' : _email,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.10),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.mint,
                size: 18,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Used for account login and security',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copyEmail,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.mint.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.mint.withOpacity(0.25),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color: AppColors.mint,
            size: 15,
          ),
          SizedBox(width: 5),
          Text(
            'Verified',
            style: TextStyle(
              color: AppColors.mint,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return _buildSectionCard(
      title: 'Account Security',
      icon: Icons.security_rounded,
      child: Column(
        children: [
          _buildSecurityRow(
            icon: Icons.mark_email_read_outlined,
            title: 'Email verified',
            subtitle: 'Your account email is confirmed',
            trailing: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.mint,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.borderMint,
          ),
          const SizedBox(height: 16),
          _buildSecurityRow(
            icon: Icons.lock_outline_rounded,
            title: 'Login & security',
            subtitle: 'Your email helps protect your account',
            trailing: const Icon(
              Icons.shield_outlined,
              color: AppColors.mint,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: AppColors.navy,
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.55),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        trailing,
      ],
    );
  }

  Widget _buildWhyEmailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.mint,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why your email matters',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your email helps MindMate identify your account, protect your access, and keep your account information connected.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
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

  Widget _buildPrivacyNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_rounded,
          size: 15,
          color: AppColors.navy.withOpacity(0.42),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Your email is private and only used for your MindMate account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.48),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: AppColors.navy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          child,
        ],
      ),
    );
  }
}