class CheckIn {
  final String id;
  final String email;
  final String mood;
  final int moodIntensity;
  final List<String> emotions;
  final int energyLevel;
  final int sleepQuality;
  final List<String> factors;
  final String reflection;
  final DateTime createdAt;
  final DateTime updatedAt;

  CheckIn({
    required this.id,
    required this.email,
    required this.mood,
    required this.moodIntensity,
    required this.emotions,
    required this.energyLevel,
    required this.sleepQuality,
    required this.factors,
    required this.reflection,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mood: json['mood']?.toString() ?? '',
      moodIntensity: (json['moodIntensity'] as num?)?.toInt() ?? 0,
      emotions: List<String>.from(
        json['emotions'] ?? [],
      ),
      energyLevel: (json['energyLevel'] as num?)?.toInt() ?? 0,
      sleepQuality: (json['sleepQuality'] as num?)?.toInt() ?? 0,
      factors: List<String>.from(
        json['factors'] ?? [],
      ),
      reflection: json['reflection']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      ) ??
          DateTime.now(),
    );
  }
}