import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends State<PasswordSecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Use at least 8 characters.';
    }

    if (value.contains(' ')) {
      return 'Password cannot contain spaces.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter.';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Include at least one number.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) {
      return 'Include at least one special character.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.navy,
          ),
        ),
        title: const Text(
          'Password & Security',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            _buildSecurityHeader(),

            const SizedBox(height: 24),

            _buildPasswordField(
              label: 'Current Password',
              controller: _currentController,
              hidden: _hideCurrent,
              onToggle: () {
                setState(() {
                  _hideCurrent = !_hideCurrent;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your current password.';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildPasswordField(
              label: 'New Password',
              controller: _newController,
              hidden: _hideNew,
              onToggle: () {
                setState(() {
                  _hideNew = !_hideNew;
                });
              },
              validator: _validatePassword,
            ),

            const SizedBox(height: 18),

            _buildPasswordField(
              label: 'Confirm New Password',
              controller: _confirmController,
              hidden: _hideConfirm,
              onToggle: () {
                setState(() {
                  _hideConfirm = !_hideConfirm;
                });
              },
              validator: (value) {
                if (value != _newController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _changePassword,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.mint,
            size: 25,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Use a strong password that you do not reuse on other accounts.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: hidden,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• At least 8 characters\n'
                '• Uppercase and lowercase letters\n'
                '• At least one number\n'
                '• At least one special character\n'
                '• No spaces',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 10.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}