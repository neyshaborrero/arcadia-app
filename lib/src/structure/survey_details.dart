import 'package:arcadia_mobile/src/structure/survey_answers.dart';

class SurveyDetails {
  final String id;
  final String question;
  final String description;
  final int maxAnswers;
  final int tokensEarned;
  final String? pictureUrl;
  final String createdAt;
  final String expiresAt;
  final bool userHasAnswered;
  final List<SurveyAnswer> answers;
  final int maxVotesPerUser;

  SurveyDetails(
      {required this.id,
      required this.question,
      required this.description,
      required this.maxAnswers,
      required this.tokensEarned,
      this.pictureUrl,
      required this.createdAt,
      required this.expiresAt,
      required this.userHasAnswered,
      required this.answers,
      required this.maxVotesPerUser});

  factory SurveyDetails.fromJson(String id, Map<String, dynamic> json) {
    var answersFromJson = json['answers'] as List;
    List<SurveyAnswer> answersList =
        answersFromJson.map((answer) => SurveyAnswer.fromJson(answer)).toList();

    return SurveyDetails(
      id: id,
      question: json['question'],
      description: json['description'],
      maxAnswers: json['maxAnswers'],
      tokensEarned: json['tokensEarned'],
      pictureUrl: json['pictureUrl'],
      createdAt: json['createdAt'],
      expiresAt: json['expiresAt'],
      userHasAnswered: json['userHasAnswered'],
      answers: answersList,
      maxVotesPerUser: json['maxVotesPerUser'],
    );
  }
}
