import 'package:arcadia_mobile/src/structure/survey_answers.dart';

class SurveyDetails {
  final String id;
  final String question;
  final String description;
  final String? subtitle;
  final String? sponsorBy;
  final String? rules;
  final int maxAnswers;
  final int tokensEarned;
  final String? pictureUrl;
  final String createdAt;
  final String expiresAt;
  final bool userHasAnswered;
  final List<SurveyAnswer> answers;
  final int maxVotesPerUser;
  final List<String> userSelectedAnswers; // Add this field
  final bool showResults;

  SurveyDetails(
      {required this.id,
      required this.question,
      required this.description,
      this.subtitle,
      this.sponsorBy,
      required this.maxAnswers,
      required this.tokensEarned,
      this.pictureUrl,
      required this.createdAt,
      required this.expiresAt,
      required this.userHasAnswered,
      required this.answers,
      required this.maxVotesPerUser,
      this.rules,
      required this.userSelectedAnswers,
      required this.showResults // Add this in the constructor
      });

  factory SurveyDetails.fromJson(String id, Map<String, dynamic> json) {
    var answersFromJson = json['answers'] as List;
    List<SurveyAnswer> answersList =
        answersFromJson.map((answer) => SurveyAnswer.fromJson(answer)).toList();

    return SurveyDetails(
      id: id,
      subtitle: json['subtitle'] ?? '',
      question: json['question'] ?? '',
      description: json['description'] ?? '',
      sponsorBy: json['sponsorBy'] ?? '',
      maxAnswers: json['maxAnswers'] ?? 1,
      tokensEarned: json['tokensEarned'] ?? 150,
      pictureUrl: json['pictureUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      userHasAnswered: json['userHasAnswered'] ?? false,
      answers: answersList,
      maxVotesPerUser: json['maxVotesPerUser'] ?? 1,
      rules: json['rules'] ?? '',
      showResults: json['showResults'] ?? true,
      userSelectedAnswers: List<String>.from(
          json['userSelectedAnswers'] ?? ''), // Convert to list of strings
    );
  }
}
