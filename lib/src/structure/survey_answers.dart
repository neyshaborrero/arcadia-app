class SurveyAnswer {
  final String answerId;
  final String title;
  final String? pictureUrl;
  final double percentage;

  SurveyAnswer({
    required this.answerId,
    required this.title,
    required this.pictureUrl,
    required this.percentage,
  });

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      answerId: json['answerId'],
      title: json['title'],
      pictureUrl: json['pictureUrl'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
