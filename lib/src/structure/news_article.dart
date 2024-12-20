import 'package:intl/intl.dart';

class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String createdAt;
  final Uri? url;
  final String qrId;

  NewsArticle(
      {required this.id,
      required this.title,
      required this.description,
      required this.createdAt,
      this.url,
      required this.qrId});

  factory NewsArticle.fromJson(Map<String, dynamic> json, String id) {
    return NewsArticle(
      id: id,
      createdAt: json['createdAt'],
      description: json['description'],
      url: Uri.parse((json['url'])),
      title: json['title'],
      qrId: json['qrid'],
    );
  }

  String getFormattedDate() {
    final DateTime date = DateTime.parse(createdAt);
    final DateFormat formatter = DateFormat('M/d/yy');
    return formatter.format(date);
  }
}
