import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static String get chatUrl => '$baseUrl/api/chat';

  // static String get moodAnalysisUrl =>
  //     '$baseUrl/api/mood/analyze';
}