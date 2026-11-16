
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';

const Color _mutedText = Color(0xFF78858D);
const Color _softBackground = Color(0xFFF6F9F7);

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _responseMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'];
      }
    } catch (_) {
      // Use the fallback message below.
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _loadContacts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your session has expired. Please log in again.',
        );
      }

      final response = await http.get(
        Uri.parse(ApiConfig.emergencyContactsUrl),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map || decoded['contacts'] is! List) {
          throw Exception('Unable to load emergency contacts.');
        }

        final List<dynamic> items = decoded['contacts'];

        if (!mounted) return;

        setState(() {
          _contacts = items
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          _isLoading = false;
        });
      } else {
        throw Exception(_responseMessage(response));
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red.shade700 : AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  Future<bool> _saveContact({
    String? contactId,
    required String name,
    required String relationship,
    required String phoneNumber,
    required bool consentGiven,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your session has expired. Please log in again.',
        );
      }

      final isEditing = contactId != null;

      final uri = isEditing
          ? Uri.parse(
        '${ApiConfig.emergencyContactsUrl}/$contactId',
      )
          : Uri.parse(ApiConfig.emergencyContactsUrl);

      final body = jsonEncode({
        'name': name.trim(),
        'relationship': relationship.trim(),
        'phoneNumber': phoneNumber.trim(),
        'consentGiven': consentGiven,
      });

      final response = isEditing
          ? await http.put(
        uri,
        headers: _headers(token),
        body: body,
      )
          : await http.post(
        uri,
        headers: _headers(token),
        body: body,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (!mounted) return false;

        _showMessage(
          isEditing
              ? 'Emergency contact updated successfully.'
              : 'Emergency contact added successfully.',
        );

        return true;
      }

      throw Exception(_responseMessage(response));
    } catch (error) {
      if (!mounted) return false;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );

      return false;
    }
  }

  Future<void> _showContactDialog({
    Map<String, dynamic>? contact,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _EmergencyContactDialog(
          contact: contact,
          onSave: _saveContact,
        );
      },
    );

    if (saved == true && mounted) {
      await _loadContacts();
    }
  }

  Future<void> _deleteContact(
      Map<String, dynamic> contact,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Remove Contact?',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${contact['name']} '
              'from your emergency contacts?',
          style: const TextStyle(
            color: AppColors.textDark,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.navy),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your session has expired. Please log in again.',
        );
      }

      final id = contact['_id']?.toString();

      if (id == null || id.isEmpty) {
        throw Exception('Contact ID is missing.');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.emergencyContactsUrl}/$id'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        _showMessage('Emergency contact removed.');
        await _loadContacts();
      } else {
        throw Exception(_responseMessage(response));
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
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
            height: 49,
            width: 49,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.mint,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Safety Circle',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Keep trusted people close. These are the '
                      'people you may contact when you need '
                      'emergency support.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTACT SECTION HEADER
  // ------------------------------------------------------------

  Widget _buildSectionHeader(int consentedCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Trusted People',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your emergency contacts',
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '$consentedCount/${_contacts.length}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'SOS eligible',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CONTACT CARD
  // ------------------------------------------------------------

  Widget _buildContactCard(
      Map<String, dynamic> contact,
      ) {
    final hasConsent = contact['consentGiven'] == true;

    final name = contact['name']?.toString() ?? 'Unknown';
    final relationship =
        contact['relationship']?.toString() ?? '';
    final phoneNumber =
        contact['phoneNumber']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 53,
                width: 53,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.mint,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      relationship,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Contact options',
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.navy,
                  size: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showContactDialog(contact: contact);
                  } else if (value == 'delete') {
                    _deleteContact(contact);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 10),
                        Text('Edit contact'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Remove contact'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _softBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: AppColors.mint,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phoneNumber,
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
          const SizedBox(height: 13),
          Row(
            children: [
              Icon(
                hasConsent
                    ? Icons.verified_user_rounded
                    : Icons.info_outline_rounded,
                color: hasConsent
                    ? AppColors.mint
                    : Colors.orange.shade800,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasConsent
                      ? 'Consent confirmed'
                      : 'Consent not confirmed',
                  style: TextStyle(
                    color: hasConsent
                        ? AppColors.navy
                        : Colors.orange.shade900,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasConsent
                      ? AppColors.lightMint
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasConsent ? 'SOS eligible' : 'Not eligible',
                  style: TextStyle(
                    color: hasConsent
                        ? AppColors.navy
                        : Colors.orange.shade900,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: AppColors.mint,
              size: 42,
            ),
          ),
          const SizedBox(height: 19),
          const Text(
            'Your Safety Circle Starts Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'You have not added any emergency contacts yet. '
                'Add someone you trust so they can be available '
                'when you need support.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedText,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ADD CONTACT BUTTON
  // ------------------------------------------------------------

  Widget _buildAddContactButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _showContactDialog(),
        icon: const Icon(
          Icons.add_rounded,
          size: 22,
        ),
        label: const Text(
          'Add Emergency Contact',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PRIVACY REMINDER
  // ------------------------------------------------------------

  Widget _buildPrivacyReminder() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.mint,
            size: 20,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Your contacts are associated with your account. '
                  'Only contacts with confirmed consent are eligible '
                  'for SOS support. Make sure each person has '
                  'personally agreed to be contacted.',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 11,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final consentedCount = _contacts
        .where((contact) => contact['consentGiven'] == true)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.navy,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.mint,
        ),
      )
          : RefreshIndicator(
        color: AppColors.mint,
        onRefresh: _loadContacts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            _buildSectionHeader(consentedCount),
            const SizedBox(height: 17),
            if (_contacts.isEmpty)
              _buildEmptyState()
            else
              ..._contacts.map(_buildContactCard),
            const SizedBox(height: 8),
            _buildAddContactButton(),
            const SizedBox(height: 18),
            _buildPrivacyReminder(),
            const SizedBox(height: 15),
            const Center(
              child: Text(
                'You deserve to feel safe and supported.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMERGENCY CONTACT SAVE CALLBACK
// ============================================================

typedef SaveEmergencyContact = Future<bool> Function({
String? contactId,
required String name,
required String relationship,
required String phoneNumber,
required bool consentGiven,
});

// ============================================================
// ADD / EDIT EMERGENCY CONTACT DIALOG
// ============================================================

class _EmergencyContactDialog extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final SaveEmergencyContact onSave;

  const _EmergencyContactDialog({
    required this.contact,
    required this.onSave,
  });

  @override
  State<_EmergencyContactDialog> createState() =>
      _EmergencyContactDialogState();
}

class _EmergencyContactDialogState
    extends State<_EmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _phoneController;

  late bool _consentGiven;

  bool _isSaving = false;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.contact?['name']?.toString() ?? '',
    );

    _relationshipController = TextEditingController(
      text: widget.contact?['relationship']?.toString() ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.contact?['phoneNumber']?.toString() ?? '',
    );

    _consentGiven =
        widget.contact?['consentGiven'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final success = await widget.onSave(
      contactId: widget.contact?['_id']?.toString(),
      name: _nameController.text,
      relationship: _relationshipController.text,
      phoneNumber: _phoneController.text,
      consentGiven: _consentGiven,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // ------------------------------------------------------------
  // DIALOG INPUT FIELD
  // ------------------------------------------------------------

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: !_isSaving,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: _mutedText,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.mint,
          size: 21,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
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
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONSENT SECTION
  // ------------------------------------------------------------

  Widget _buildConsentSection() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.mint,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Contact Consent',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.mint,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Consent confirmed',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              subtitle: const Text(
                'I confirm that this person has personally agreed '
                    'to be contacted in an emergency.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              value: _consentGiven,
              onChanged: _isSaving
                  ? null
                  : (value) {
                setState(() {
                  _consentGiven = value ?? false;
                });
              },
            ),
          ),
          const Text(
            'Contacts without consent remain saved but cannot '
                'be used for SOS.',
            style: TextStyle(
              color: _mutedText,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DIALOG UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          22,
          22,
          22,
          8,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          22,
          12,
          22,
          8,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          18,
        ),
        title: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isEditing
                    ? Icons.edit_rounded
                    : Icons.person_add_alt_1_rounded,
                color: AppColors.mint,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isEditing
                    ? 'Edit Contact'
                    : 'Add Contact',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter the details of someone you trust.',
                    style: TextStyle(
                      color: _mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _dialogField(
                  controller: _nameController,
                  label: 'Full name',
                  icon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 2 ||
                        value.trim().length > 50) {
                      return 'Enter a name (2–50 characters).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _dialogField(
                  controller: _relationshipController,
                  label: 'Relationship',
                  icon: Icons.people_outline_rounded,
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 2 ||
                        value.trim().length > 40) {
                      return 'Enter a valid relationship.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _dialogField(
                  controller: _phoneController,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^\+?[0-9\s()-]{7,20}$')
                            .hasMatch(value.trim())) {
                      return 'Enter a valid phone number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildConsentSection(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              _isEditing ? 'Update Contact' : 'Save Contact',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
