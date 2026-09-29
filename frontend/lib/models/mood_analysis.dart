class MoodAnalysis {
  final String primaryEmotion;
  final String intensity;
  final String summary;
  final List<String> suggestions;

  const MoodAnalysis({
    required this.primaryEmotion,
    required this.intensity,
    required this.summary,
    required this.suggestions,
  });

  factory MoodAnalysis.fromJson(Map<String, dynamic> json) {
    return MoodAnalysis(
      primaryEmotion: json['primaryEmotion']?.toString() ?? '',
      intensity: json['intensity']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      suggestions: (json['suggestions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}