import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/check_in.dart';

class CheckInService {
  // Save a new check-in to MongoDB
  static Future<void> saveCheckIn({
    required String mood,
    required int moodIntensity,
    required List<String> emotions,
    required int energyLevel,
    required int sleepQuality,
    required List<String> factors,
    required String reflection,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('logged_in_email');

    if (email == null || email.isEmpty) {
      throw Exception('No logged-in account found.');
    }

    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not configured.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/check-ins'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'mood': mood,
        'moodIntensity': moodIntensity,
        'emotions': emotions,
        'energyLevel': energyLevel,
        'sleepQuality': sleepQuality,
        'factors': factors,
        'reflection': reflection,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to save check-in: ${response.body}',
      );
    }
  }

  // Retrieve saved check-ins from MongoDB
  static Future<List<CheckIn>> getCheckIns() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('logged_in_email');

    if (email == null || email.isEmpty) {
      throw Exception('No logged-in account found.');
    }

    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not configured.');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/check-ins?email=${Uri.encodeComponent(email)}',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to retrieve check-ins.',
      );
    }

    final responseData = jsonDecode(response.body);

    final List<dynamic> checkInData =
        responseData['checkIns'] ?? [];

    return checkInData
        .map(
          (item) => CheckIn.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}