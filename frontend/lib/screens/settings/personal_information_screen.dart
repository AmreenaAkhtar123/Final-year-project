import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/profile_image_service.dart';


class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================
  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;

  bool _isLoadingProfileImage = true;
  bool _isSavingProfileImage = false;


  final TextEditingController _nameController =
  TextEditingController(text: 'Demo User');

  final TextEditingController _emailController =
  TextEditingController(text: 'demo@mindmate.com');

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _bioController =
  TextEditingController();

  // ===========================================================================
  // PROFILE INFORMATION
  // ===========================================================================

  DateTime? _dateOfBirth;

  String? _gender;
  String? _occupation;
  String? _educationLevel;


  // ===========================================================================
  // SCREEN STATE
  // ===========================================================================

  bool _isSaving = false;
  bool _hasChanges = false;

  // ===========================================================================
  // OPTIONS
  // ===========================================================================

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  final List<String> _occupationOptions = [
    'Student',
    'Working professional',
    'Self-employed',
    'Looking for work',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _educationOptions = [
    'High school',
    'College',
    'Undergraduate',
    'Postgraduate',
    'Other',
    'Prefer not to say',
  ];

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadSavedProfileImage();

    _nameController.addListener(_markChanged);
    _emailController.addListener(_markChanged);
    _phoneController.addListener(_markChanged);
    _bioController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges && mounted) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // PROFILE PHOTO
  // ===========================================================================

  Future<void> _showProfilePhotoOptions() async {
    FocusScope.of(context).unfocus();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightMint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderMint,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: AppColors.mint,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Photo',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Choose how you want to update your photo',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildPhotoOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take a Photo',
                  subtitle: 'Use your device camera',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickProfileImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                _buildPhotoOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  subtitle: 'Select a photo from your device',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickProfileImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null) ...[
                  const SizedBox(height: 10),
                  _buildPhotoOption(
                    icon: Icons.delete_outline_rounded,
                    title: 'Remove Photo',
                    subtitle: 'Return to the default profile icon',
                    iconColor: const Color(0xFFB85C5C),
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfileImage();
                    },
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(
                        color: AppColors.borderMint,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _loadSavedProfileImage() async {
    final File? savedImage =
    await ProfileImageService.getProfileImage();

    if (!mounted) return;

    setState(() {
      _profileImage = savedImage;
      _isLoadingProfileImage = false;
    });
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final Color resolvedIconColor = iconColor ?? AppColors.mint;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: resolvedIconColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
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
                        color: AppColors.navy.withValues(alpha: 0.50),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.navy.withValues(alpha: 0.35),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _isSavingProfileImage = true;
      });

      final Directory appDirectory =
      await getApplicationDocumentsDirectory();

      final Directory profileDirectory = Directory(
        '${appDirectory.path}/mindmate_profile',
      );

      if (!await profileDirectory.exists()) {
        await profileDirectory.create(recursive: true);
      }

      // Use a unique filename for every newly selected photo.
      final String fileName =
          'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File savedFile = File(
        '${profileDirectory.path}/$fileName',
      );

      await File(pickedFile.path).copy(savedFile.path);

      await ProfileImageService.saveProfileImagePath(
        savedFile.path,
      );

      if (!mounted) return;

      setState(() {
        _profileImage = savedFile;
        _isSavingProfileImage = false;
        _hasChanges = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSavingProfileImage = false;
      });

      _showPhotoError(
        'We could not access the selected photo. Please try again.',
      );
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      // This handles deleting the saved file, removing the saved path,
      // and notifying every listener immediately.
      await ProfileImageService.removeProfileImage();

      if (!mounted) return;

      setState(() {
        _profileImage = null;
        _hasChanges = true;
      });
    } catch (e) {
      // Keep the UI stable if local cleanup fails.
    }
  }

  void _showPhotoError(String message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEEEE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB85C5C),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // DATE OF BIRTH
  // ===========================================================================

  Future<void> _selectDateOfBirth() async {
    FocusScope.of(context).unfocus();

    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
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

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _dateOfBirth = selectedDate;
      _hasChanges = true;
    });
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  int? get _age {
    if (_dateOfBirth == null) {
      return null;
    }

    final DateTime today = DateTime.now();

    int age = today.year - _dateOfBirth!.year;

    if (today.month < _dateOfBirth!.month ||
        (today.month == _dateOfBirth!.month &&
            today.day < _dateOfBirth!.day)) {
      age--;
    }

    return age;
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Local/demo save for now.
    // Backend/database integration can be added later.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });

    _showSaveSuccess();
  }

  void _showSaveSuccess() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mint,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Profile Updated',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your personal information has been updated locally.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MAIN BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 22),

                    _buildProfileOverview(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'Basic Information',
                      'Keep your core account details up to date',
                    ),

                    const SizedBox(height: 12),

                    _buildBasicInformationCard(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'About You',
                      'Optional details that help personalize MindMate',
                    ),

                    const SizedBox(height: 12),

                    _buildAboutYouCard(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'Education & Lifestyle',
                      'Tell MindMate a little about your daily context',
                    ),

                    const SizedBox(height: 12),

                    _buildEducationCard(),

                    const SizedBox(height: 24),

                    _buildPrivacyCard(),

                    const SizedBox(height: 22),

                    _buildSaveButton(),

                    const SizedBox(height: 18),

                    _buildLocalDataNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
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
                    color: AppColors.navy.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.navy,
                size: 21,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your personal profile',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: Image.asset(
            'assets/images/logo1.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PROFILE OVERVIEW
  // ===========================================================================

  Widget _buildProfileOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF29495A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.13),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(
            size: 70,
            showEditBadge: true,
            onTap: _showProfilePhotoOptions,
            borderWidth: 2.5,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.trim().isEmpty
                      ? 'Your Name'
                      : _nameController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF9ED7BC),
                        size: 13,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'MindMate Member',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required double size,
    required bool showEditBadge,
    required VoidCallback onTap,
    double borderWidth = 2,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _profileImage != null
                  ? Image.file(
                _profileImage!,
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.person_rounded,
                color: AppColors.mint,
                size: 36,
              ),
            ),
          ),
          if (showEditBadge)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.navy,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE PHOTO SECTION
  // ===========================================================================

  Widget _buildProfilePhotoSection() {
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
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(
            size: 76,
            showEditBadge: false,
            onTap: _showProfilePhotoOptions,
            borderWidth: 2,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileImage == null
                      ? 'Add a profile photo'
                      : 'Profile photo added',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _profileImage == null
                      ? 'Add a photo so your profile feels more personal.'
                      : 'You can replace or remove your current photo anytime.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.52),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: _showProfilePhotoOptions,
                        icon: Icon(
                          _profileImage == null
                              ? Icons.add_a_photo_outlined
                              : Icons.edit_outlined,
                          size: 15,
                        ),
                        label: Text(
                          _profileImage == null
                              ? 'Add Photo'
                              : 'Change Photo',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(
                            color: AppColors.borderMint,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (_profileImage != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _removeProfileImage,
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCEEEE),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFB85C5C),
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BASIC INFORMATION
  // ===========================================================================

  Widget _buildBasicInformationCard() {
    return _buildCard(
      children: [
        _buildTextField(
          label: 'Full Name',
          controller: _nameController,
          icon: Icons.person_outline_rounded,
          hint: 'Enter your full name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email Address',
          controller: _emailController,
          icon: Icons.email_outlined,
          hint: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
          helperText: 'Email is linked to your account',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Phone Number',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          hint: 'Optional',
          keyboardType: TextInputType.phone,
          optional: true,
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        if (_age != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Age: $_age years',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.48),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Gender',
          value: _gender,
          hint: 'Select gender',
          icon: Icons.wc_outlined,
          items: _genderOptions,
          onChanged: (value) {
            setState(() {
              _gender = value;
              _hasChanges = true;
            });
          },
          optional: true,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          'Date of Birth',
          optional: true,
        ),
        const SizedBox(height: 7),
        InkWell(
          onTap: _selectDateOfBirth,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.mint,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select your date of birth'
                        : _formatDate(_dateOfBirth!),
                    style: TextStyle(
                      color: _dateOfBirth == null
                          ? AppColors.navy.withValues(alpha: 0.40)
                          : AppColors.navy,
                      fontSize: 13,
                      fontWeight: _dateOfBirth == null
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.navy.withValues(alpha: 0.30),
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ABOUT YOU
  // ===========================================================================

  Widget _buildAboutYouCard() {
    return _buildCard(
      children: [
        _buildTextField(
          label: 'About You',
          controller: _bioController,
          icon: Icons.edit_note_outlined,
          hint: 'Write a short introduction about yourself',
          maxLines: 4,
          maxLength: 300,
          optional: true,
          alignIconToTop: true,
        ),
      ],
    );
  }

  // ===========================================================================
  // EDUCATION
  // ===========================================================================

  Widget _buildEducationCard() {
    return _buildCard(
      children: [
        _buildDropdownField(
          label: 'Education Level',
          value: _educationLevel,
          hint: 'Select education level',
          icon: Icons.school_outlined,
          items: _educationOptions,
          onChanged: (value) {
            setState(() {
              _educationLevel = value;
              _hasChanges = true;
            });
          },
          optional: true,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Current Role',
          value: _occupation,
          hint: 'Select your current role',
          icon: Icons.work_outline_rounded,
          items: _occupationOptions,
          onChanged: (value) {
            setState(() {
              _occupation = value;
              _hasChanges = true;
            });
          },
          optional: true,
        ),
      ],
    );
  }

  // ===========================================================================
  // CARD
  // ===========================================================================

  Widget _buildCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool optional = false,
    String? helperText,
    int maxLines = 1,
    int? maxLength,
    bool alignIconToTop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          label,
          optional: optional,
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            counterText: '',
            filled: true,
            fillColor: readOnly
                ? AppColors.lightMint.withValues(alpha: 0.55)
                : AppColors.background,
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 8,
                top: alignIconToTop ? 13 : 0,
              ),
              child: Icon(
                icon,
                color: AppColors.mint,
                size: 20,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 42,
              minHeight: alignIconToTop ? 42 : 48,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.mint,
                width: 1.4,
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText,
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.42),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // DROPDOWN
  // ===========================================================================

  // ===========================================================================
// DROPDOWN
// ===========================================================================

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          label,
          optional: optional,
        ),

        const SizedBox(height: 7),

        InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus();

            final String? selectedValue =
            await showModalBottomSheet<String>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) {
                return SafeArea(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top handle
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderMint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Header
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.lightMint,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: AppColors.borderMint,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: AppColors.mint,
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      color: AppColors.navy,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Select an option',
                                    style: TextStyle(
                                      color: AppColors.navy
                                          .withValues(alpha: 0.45),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Options
                        ...items.map(
                              (item) {
                            final bool isSelected = item == value;

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      item,
                                    );
                                  },
                                  borderRadius:
                                  BorderRadius.circular(15),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.lightMint
                                          : Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.mint
                                            : AppColors.borderMint,
                                        width: isSelected ? 1.2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: AppColors.navy,
                                              fontSize: 13,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        if (isSelected)
                                          Container(
                                            width: 25,
                                            height: 25,
                                            decoration:
                                            const BoxDecoration(
                                              color: AppColors.mint,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 4),

                        // Cancel
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: const BorderSide(
                                color: AppColors.borderMint,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (selectedValue != null) {
              onChanged(selectedValue);
            }
          },

          borderRadius: BorderRadius.circular(16),

          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,

              prefixIcon: Icon(
                icon,
                color: AppColors.mint,
                size: 20,
              ),

              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.navy.withValues(alpha: 0.35),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),

            child: Text(
              value ?? hint,
              style: TextStyle(
                color: value == null
                    ? AppColors.navy.withValues(alpha: 0.35)
                    : AppColors.navy,
                fontSize: 13,
                fontWeight: value == null
                    ? FontWeight.w500
                    : FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ===========================================================================
  // FIELD LABEL
  // ===========================================================================

  Widget _buildFieldLabel(
      String label, {
        bool optional = false,
      }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          Text(
            'Optional',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.35),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // SECTION HEADER
  // ===========================================================================

  Widget _buildSectionHeader(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.48),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PRIVACY CARD
  // ===========================================================================

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mint,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your information stays private',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Personal details are only used to personalize your MindMate experience. You control what you choose to provide.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SAVE BUTTON
  // ===========================================================================

  Widget _buildSaveButton() {
    final bool enabled = _hasChanges && !_isSaving;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? _saveChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          disabledBackgroundColor: AppColors.borderMint,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.navy.withValues(alpha: 0.35),
          elevation: enabled ? 4 : 0,
          shadowColor: AppColors.navy.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              enabled
                  ? Icons.check_rounded
                  : Icons.check_circle_outline_rounded,
              size: 19,
            ),
            const SizedBox(width: 8),
            Text(
              enabled ? 'Save Changes' : 'No Changes to Save',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LOCAL DATA NOTE
  // ===========================================================================

  Widget _buildLocalDataNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: AppColors.navy.withValues(alpha: 0.30),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'Profile changes are currently stored locally for this demo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.38),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}