import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  ProfileImageService._();

  static const String _profileImagePathKey =
      'mindmate_profile_image_path';

  static final ValueNotifier<File?> profileImageNotifier =
  ValueNotifier<File?>(null);

  static bool _isInitialized = false;

  /// Initializes the shared profile image state.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;

    final image = await getProfileImage();

    profileImageNotifier.value = image;
  }

  /// Returns the currently saved profile image, if one exists.
  static Future<File?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPath = prefs.getString(_profileImagePathKey);

    if (savedPath == null || savedPath.isEmpty) {
      return null;
    }

    final file = File(savedPath);

    if (await file.exists()) {
      return file;
    }

    // Clean up an invalid/stale path.
    await prefs.remove(_profileImagePathKey);

    return null;
  }

  /// Saves the profile image path and immediately notifies listeners.
  static Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _profileImagePathKey,
      path,
    );

    final file = File(path);

    if (await file.exists()) {
      profileImageNotifier.value = file;
    }
  }

  /// Removes the profile image and immediately notifies listeners.
  static Future<void> removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPath = prefs.getString(_profileImagePathKey);

    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);

      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove(_profileImagePathKey);

    // Immediately tell every listening screen that there is no photo.
    profileImageNotifier.value = null;
  }
}