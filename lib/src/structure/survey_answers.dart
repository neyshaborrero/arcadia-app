class SurveyAnswer {
  final String answerId;
  final String title;
  final String? pictureUrl;
  final double percentage;
  final bool userVoted;

  SurveyAnswer({
    required this.answerId,
    required this.title,
    this.pictureUrl,
    required this.percentage,
    required this.userVoted,
  });

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      answerId: json['answerId'],
      title: json['title'],
      pictureUrl: json['pictureUrl'],
      percentage: json['percentage'].toDouble(), // Convert to double
      userVoted: json['userVoted'],
    );
  }
}
