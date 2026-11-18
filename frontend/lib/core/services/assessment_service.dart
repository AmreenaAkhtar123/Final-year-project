
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentService {
  static const Map<String, Map<String, int>> _assessmentRules = {
    'anxiety_stress': {'count': 20, 'maxAnswer': 3},
    'depression_mood': {'count': 20, 'maxAnswer': 3},
    'student_wellbeing': {'count': 20, 'maxAnswer': 3},
    'general_wellbeing': {'count': 20, 'maxAnswer': 3},
    'phq9': {'count': 9, 'maxAnswer': 3},
    'gad7': {'count': 7, 'maxAnswer': 3},
    'who5': {'count': 5, 'maxAnswer': 5},
  };

  // =========================================================
  // SAVE ASSESSMENT
  // =========================================================

  static Future<bool> saveAssessment({
    required String assessmentType,
    required List<int> answers,
  }) async {
    final rule = _assessmentRules[assessmentType];

    if (rule == null) {
      throw Exception('Invalid assessment type.');
    }

    final requiredCount = rule['count']!;
    final maxAnswer = rule['maxAnswer']!;

    if (answers.length != requiredCount ||
        answers.any((answer) => answer < 0 || answer > maxAnswer)) {
      throw Exception(
        'Please complete all $requiredCount assessment questions.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Your session has expired. Please log in again.',
      );
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

    try {
      final responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic>) {
        return responseData['crisisSupportRequired'] == true;
      }
    } catch (_) {
      // The assessment was saved; use the default value.
    }

    return false;
  }

  // =========================================================
  // FETCH ALL SEVEN ASSESSMENT RESULTS
  // =========================================================

  static Future<List<Map<String, dynamic>>>
  fetchAllAssessmentResults() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Your session has expired. Please log in again.',
      );
    }

    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not configured.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/assessments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      String message = 'Failed to retrieve assessment results.';

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

    final responseData = jsonDecode(response.body);

    if (responseData is List) {
      return responseData
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    if (responseData is Map<String, dynamic>) {
      final results = responseData['assessments'] ??
          responseData['results'];

      if (results is List) {
        return results
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }

    throw Exception('Invalid assessment history response.');
  }

  // =========================================================
  // FR-14: PREDICTIVE RISK ANALYSIS
  // =========================================================

  static Future<Map<String, dynamic>>
  fetchPredictiveRiskAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Your session has expired. Please log in again.',
      );
    }

    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not configured.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/assessments/predictive-risk'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      String message = 'Failed to retrieve predictive risk analysis.';

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

    final responseData = jsonDecode(response.body);

    if (responseData is! Map<String, dynamic> ||
        responseData['analysis'] is! Map<String, dynamic>) {
      throw Exception('Invalid predictive risk analysis response.');
    }

    return responseData['analysis'] as Map<String, dynamic>;
  }
}
