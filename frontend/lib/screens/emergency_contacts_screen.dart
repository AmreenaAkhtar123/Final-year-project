
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';

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
        final List<dynamic> items = decoded['contacts'] ?? [];

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
          borderRadius: BorderRadius.circular(20),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.navy,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      relationship,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.navy,
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
                        Icon(
                          Icons.edit_outlined,
                          size: 19,
                        ),
                        SizedBox(width: 9),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 19,
                        ),
                        SizedBox(width: 9),
                        Text('Remove'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: AppColors.mint,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phoneNumber,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: hasConsent
                  ? AppColors.lightMint
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  hasConsent
                      ? Icons.verified_user_outlined
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
                        ? 'Consent confirmed • Eligible for SOS'
                        : 'Consent not confirmed • Not eligible for SOS',
                    style: TextStyle(
                      color: hasConsent
                          ? AppColors.navy
                          : Colors.orange.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55),
        child: Column(
          children: [
            Container(
              height: 85,
              width: 85,
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
            const SizedBox(height: 18),
            const Text(
              'No Emergency Contacts Yet',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add someone you trust so they can be\n'
                  'available when you need support.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consentedCount = _contacts
        .where((contact) => contact['consentGiven'] == true)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
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
            fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.mint,
                    size: 27,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'People You Trust',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Add trusted people who may be contacted '
                              'when you need emergency support. Always '
                              'obtain their agreement before marking '
                              'their consent as confirmed.',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Contacts',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  '$consentedCount of ${_contacts.length} SOS eligible',
                  style: const TextStyle(
                    color: AppColors.mint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_contacts.isEmpty)
              _buildEmptyState()
            else
              ..._contacts.map(_buildContactCard),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showContactDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Emergency Contact'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(
                  color: AppColors.mint,
                  width: 1.3,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your contacts are associated with your account. '
                  'Only contacts with confirmed consent will be '
                  'available for SOS support.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Callback used by the emergency contact dialog.
typedef SaveEmergencyContact = Future<bool> Function({
String? contactId,
required String name,
required String relationship,
required String phoneNumber,
required bool consentGiven,
});

// Separate dialog widget owns its controllers and saving state.
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.mint,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: AppColors.borderMint,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: AppColors.borderMint,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: AppColors.mint,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          _isEditing
              ? 'Edit Emergency Contact'
              : 'Add Emergency Contact',
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.mint,
                        controlAffinity:
                        ListTileControlAffinity.leading,
                        title: const Text(
                          'Consent confirmed',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'I confirm that this person has personally '
                              'agreed to be contacted in an emergency.',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            height: 1.4,
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
                      const Text(
                        'Contacts without consent remain saved but '
                            'cannot be used for SOS.',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
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
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: Colors.white,
              elevation: 0,
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
                : Text(_isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }
}
