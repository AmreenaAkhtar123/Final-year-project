
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/painting.dart';

class ProfileImageService {
  ProfileImageService._();

  static final ValueNotifier<File?> profileImageNotifier =
  ValueNotifier<File?>(null);

  static String get _profileImageUrl {
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not configured.');
    }

    return '$baseUrl/api/profile/image';
  }

  static Future<Map<String, String>> _getAccountDetails() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');
    final email = prefs.getString('logged_in_email');

    if (token == null || token.isEmpty ||
        email == null || email.isEmpty) {
      throw Exception('No authenticated account found.');
    }

    return {
      'token': token,
      'email': email,
    };
  }

  static Future<File> _getAccountCacheFile(String email) async {
    final directory = await getApplicationDocumentsDirectory();

    final profileDirectory = Directory(
      '${directory.path}/mindmate_profile',
    );

    if (!await profileDirectory.exists()) {
      await profileDirectory.create(recursive: true);
    }

    final accountKey = base64Url.encode(
      utf8.encode(email.toLowerCase().trim()),
    );

    return File(
      '${profileDirectory.path}/profile_$accountKey.jpg',
    );
  }

  /// Loads the authenticated account's profile picture from the server.
  static Future<File?> getProfileImage() async {
    try {
      final account = await _getAccountDetails();

      final cacheFile = await _getAccountCacheFile(
        account['email']!,
      );

      final response = await http.get(
        Uri.parse(_profileImageUrl),
        headers: {
          'Authorization': 'Bearer ${account['token']}',
        },
      );

      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(
          response.bodyBytes,
          flush: true,
        );

        profileImageNotifier.value = cacheFile;

        return cacheFile;
      }

      if (response.statusCode == 404) {
        if (await cacheFile.exists()) {
          await cacheFile.delete();
        }

        profileImageNotifier.value = null;

        return null;
      }

      // Use this account's cached image if the server is temporarily
      // unavailable.
      if (await cacheFile.exists()) {
        profileImageNotifier.value = cacheFile;
        return cacheFile;
      }

      profileImageNotifier.value = null;
      return null;
    } catch (error) {
      // Do not display another account's image when authentication
      // or account information is unavailable.
      try {
        final account = await _getAccountDetails();

        final cacheFile = await _getAccountCacheFile(
          account['email']!,
        );

        if (await cacheFile.exists()) {
          profileImageNotifier.value = cacheFile;
          return cacheFile;
        }
      } catch (_) {
        // No authenticated account is available.
      }

      profileImageNotifier.value = null;
      return null;
    }
  }

  /// Initializes the shared profile image state.
  static Future<void> initialize() async {
    await getProfileImage();
  }

  /// Uploads a selected photo and updates this account's local cache.
  static Future<void> uploadProfileImage(File image) async {
    final account = await _getAccountDetails();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_profileImageUrl),
    );

    request.headers['Authorization'] =
    'Bearer ${account['token']}';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await image.readAsBytes(),
        filename: 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Profile picture upload failed: ${response.body}',
      );
    }

    final cacheFile = await _getAccountCacheFile(account['email']!);

// Remove the previous image from Flutter's image cache.
    await FileImage(cacheFile).evict();

// Save the newly uploaded image to the account cache.
    await image.copy(cacheFile.path);

// Notify all screens to display the updated image.
    profileImageNotifier.value = cacheFile;
  }

  /// Deletes the authenticated account's profile picture.
  static Future<void> removeProfileImage() async {
    final account = await _getAccountDetails();

    final response = await http.delete(
      Uri.parse(_profileImageUrl),
      headers: {
        'Authorization': 'Bearer ${account['token']}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Profile picture removal failed: ${response.body}',
      );
    }

    final cacheFile = await _getAccountCacheFile(
      account['email']!,
    );

    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }

    profileImageNotifier.value = null;
  }

  /// Clears the visible image when the current account logs out.
  /// It does not delete the account's server image or local cache.
  static void clearCurrentImage() {
    profileImageNotifier.value = null;
  }
}
