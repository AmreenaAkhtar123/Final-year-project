class StudentWellbeingResult {
  final double studentPulse;
  final double pressureIndex;
  final double focusReadiness;
  final double recoveryIndex;
  final double overloadIndex;

  final double academicHealth;
  final double mentalHealth;
  final double lifestyleHealth;

  final double stress;
  final double examPressure;
  final double burnout;
  final double sleep;
  final double energy;
  final double workload;
  final double socialConnection;
  final double motivation;

  const StudentWellbeingResult({
    required this.studentPulse,
    required this.pressureIndex,
    required this.focusReadiness,
    required this.recoveryIndex,
    required this.overloadIndex,
    required this.academicHealth,
    required this.mentalHealth,
    required this.lifestyleHealth,
    required this.stress,
    required this.examPressure,
    required this.burnout,
    required this.sleep,
    required this.energy,
    required this.workload,
    required this.socialConnection,
    required this.motivation,
  });
}

class StudentWellbeingCalculator {
  static double _clamp(
      double value,
      double min,
      double max,
      ) {
    return value.clamp(min, max).toDouble();
  }

  static StudentWellbeingResult calculate({
    required Set<String> struggles,
    required Set<String> effects,
    required Set<String> pressureSources,
  }) {
    final hasHighStress =
        effects.contains('stress') ||
            effects.contains('overwhelmed');

    final hasLowRecovery =
        effects.contains('exhausted') ||
            effects.contains('poor_sleep') ||
            effects.contains('emotionally_drained');

    final hasFocusIssue =
        effects.contains('cant_focus') ||
            struggles.contains('concentration');

    final hasMotivationIssue =
    effects.contains('low_motivation');

    final hasAcademicPressure =
        struggles.contains('assignments') ||
            struggles.contains('exams') ||
            struggles.contains('deadlines') ||
            struggles.contains('projects') ||
            struggles.contains('workload') ||
            pressureSources.contains('academic') ||
            pressureSources.contains('deadlines');

    int pressureAdjustment =
        pressureSources.length * 4 +
            struggles.length * 2;

    int pulseAdjustment = 0;
    int recoveryAdjustment = 0;
    int focusAdjustment = 0;

    if (hasHighStress) {
      pressureAdjustment += 8;
      pulseAdjustment -= 7;
    }

    if (hasLowRecovery) {
      recoveryAdjustment += 10;
      pulseAdjustment -= 6;
    }

    if (hasFocusIssue) {
      focusAdjustment += 12;
      pulseAdjustment -= 4;
    }

    if (hasMotivationIssue) {
      recoveryAdjustment += 5;
      pulseAdjustment -= 3;
    }

    if (effects.contains('okay')) {
      pulseAdjustment += 6;
    }

    final pressureIndex = _clamp(
      58 + pressureAdjustment.toDouble(),
      0,
      100,
    );

    final recoveryIndex = _clamp(
      55 - recoveryAdjustment.toDouble(),
      0,
      100,
    );

    final focusReadiness = _clamp(
      64 - focusAdjustment.toDouble(),
      0,
      100,
    );

    final overloadIndex = _clamp(
      46 + pressureAdjustment * 0.65,
      0,
      100,
    );

    final studentPulse = _clamp(
      72.0 + pulseAdjustment,
      0,
      100,
    );

    final stress = hasHighStress ? 7.5 : 6.0;
    final energy = hasLowRecovery ? 4.0 : 6.0;
    final sleep =
    effects.contains('poor_sleep') ? 3.5 : 5.0;
    final motivation =
    hasMotivationIssue ? 4.0 : 6.0;
    final workload =
    hasAcademicPressure ? 7.5 : 6.5;

    final burnout = _clamp(
      (stress + (10 - energy) + (10 - motivation)) / 3,
      0,
      10,
    );

    final academicHealth =
    hasAcademicPressure ? 6.2 : 6.7;

    final mentalHealth =
    hasHighStress || hasLowRecovery ? 6.4 : 7.2;

    final lifestyleHealth =
    hasLowRecovery ? 6.2 : 7.4;

    return StudentWellbeingResult(
      studentPulse: studentPulse,
      pressureIndex: pressureIndex,
      focusReadiness: focusReadiness,
      recoveryIndex: recoveryIndex,
      overloadIndex: overloadIndex,
      academicHealth: academicHealth,
      mentalHealth: mentalHealth,
      lifestyleHealth: lifestyleHealth,
      stress: stress,
      examPressure: 7,
      burnout: burnout,
      sleep: sleep,
      energy: energy,
      workload: workload,
      socialConnection: 6,
      motivation: motivation,
    );
  }
}