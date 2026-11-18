
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentService {
  static Future<void> saveAssessment({
    required String assessmentType,
    required List<int> answers,
  }) async {
    if (answers.length != 20 ||
        answers.any((answer) => answer < 0 || answer > 3)) {
      throw Exception('Please complete all 20 assessment questions.');
    }

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Your session has expired. Please log in again.');
    }

    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not configured.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/assessments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'assessmentType': assessmentType,
        'answers': answers,
      }),
    );

    if (response.statusCode != 201) {
      String message = 'Failed to save assessment result.';

      try {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['message'] is String) {
          message = responseData['message'] as String;
        }
      } catch (_) {
        // Keep the default error message.
      }

      throw Exception(message);
    }
  }
}
