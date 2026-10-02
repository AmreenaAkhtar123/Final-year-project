import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ProgressService {
  // =========================================================
  // GET PROGRESS
  // =========================================================

  static Future<ProgressData> getProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('logged_in_email');

    if (email == null || email.trim().isEmpty) {
      throw Exception('No logged-in user found.');
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/progress?email=${Uri.encodeComponent(email.trim())}',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);

        throw Exception(
          data['message'] ?? 'Failed to retrieve progress.',
        );
      } catch (_) {
        throw Exception(
          'Failed to retrieve progress.',
        );
      }
    }

    final responseData = jsonDecode(response.body);

    return ProgressData.fromJson(
      responseData['progress'],
    );
  }
}

// =============================================================
// PROGRESS DATA MODEL
// =============================================================

class ProgressData {
  final int journeyScore;

  final int totalCheckIns;
  final int currentStreak;
  final int longestStreak;

  final int reflectionsWritten;
  final int emotionsIdentified;
  final int factorsIdentified;

  final double reflectionRate;
  final double selfAwarenessRate;

  final List<int> weeklyCheckIns;

  final int mostActiveWeek;
  final int mostReflectiveWeek;

  final String? mostActiveMonth;

  final int aiInsightsReceived;

  final ProgressMilestones milestones;

  final String nextMilestone;
  final int nextMilestoneTarget;
  final int nextMilestoneCurrent;
  final double nextMilestoneProgress;

  final DateTime? journeyStartedAt;

  ProgressData({
    required this.journeyScore,
    required this.totalCheckIns,
    required this.currentStreak,
    required this.longestStreak,
    required this.reflectionsWritten,
    required this.emotionsIdentified,
    required this.factorsIdentified,
    required this.reflectionRate,
    required this.selfAwarenessRate,
    required this.weeklyCheckIns,
    required this.mostActiveWeek,
    required this.mostReflectiveWeek,
    required this.mostActiveMonth,
    required this.aiInsightsReceived,
    required this.milestones,
    required this.nextMilestone,
    required this.nextMilestoneTarget,
    required this.nextMilestoneCurrent,
    required this.nextMilestoneProgress,
    required this.journeyStartedAt,
  });

  factory ProgressData.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProgressData(
      journeyScore:
      (json['journeyScore'] ?? 0) as int,

      totalCheckIns:
      (json['totalCheckIns'] ?? 0) as int,

      currentStreak:
      (json['currentStreak'] ?? 0) as int,

      longestStreak:
      (json['longestStreak'] ?? 0) as int,

      reflectionsWritten:
      (json['reflectionsWritten'] ?? 0) as int,

      emotionsIdentified:
      (json['emotionsIdentified'] ?? 0) as int,

      factorsIdentified:
      (json['factorsIdentified'] ?? 0) as int,

      reflectionRate:
      (json['reflectionRate'] ?? 0).toDouble(),

      selfAwarenessRate:
      (json['selfAwarenessRate'] ?? 0).toDouble(),

      weeklyCheckIns:
      (json['weeklyCheckIns'] as List?)
          ?.map(
            (value) => (value as num).toInt(),
      )
          .toList() ??
          [0, 0, 0, 0, 0],

      mostActiveWeek:
      (json['mostActiveWeek'] ?? 0) as int,

      mostReflectiveWeek:
      (json['mostReflectiveWeek'] ?? 0) as int,

      mostActiveMonth:
      json['mostActiveMonth'] as String?,

      aiInsightsReceived:
      (json['aiInsightsReceived'] ?? 0) as int,

      milestones:
      ProgressMilestones.fromJson(
        json['milestones'] ??
            <String, dynamic>{},
      ),

      nextMilestone:
      json['nextMilestone'] ??
          'firstCheckIn',

      nextMilestoneTarget:
      (json['nextMilestoneTarget'] ?? 1) as int,

      nextMilestoneCurrent:
      (json['nextMilestoneCurrent'] ?? 0) as int,

      nextMilestoneProgress:
      (json['nextMilestoneProgress'] ?? 0)
          .toDouble(),

      journeyStartedAt:
      json['journeyStartedAt'] != null
          ? DateTime.tryParse(
        json['journeyStartedAt'].toString(),
      )
          : null,
    );
  }
}

// =============================================================
// MILESTONES
// =============================================================

class ProgressMilestones {
  final bool firstCheckIn;
  final bool sevenDayStreak;
  final bool tenReflections;
  final bool firstAssessment;
  final bool thirtyCheckIns;
  final bool thirtyDayConsistency;

  ProgressMilestones({
    required this.firstCheckIn,
    required this.sevenDayStreak,
    required this.tenReflections,
    required this.firstAssessment,
    required this.thirtyCheckIns,
    required this.thirtyDayConsistency,
  });

  factory ProgressMilestones.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProgressMilestones(
      firstCheckIn:
      json['firstCheckIn'] == true,

      sevenDayStreak:
      json['sevenDayStreak'] == true,

      tenReflections:
      json['tenReflections'] == true,

      firstAssessment:
      json['firstAssessment'] == true,

      thirtyCheckIns:
      json['thirtyCheckIns'] == true,

      thirtyDayConsistency:
      json['thirtyDayConsistency'] == true,
    );
  }
}