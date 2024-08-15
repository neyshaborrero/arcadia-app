import 'package:intl/intl.dart';

class UserActivity {
  final String id;
  final String createdAt;
  final String title;
  final String description;
  final String earnings;
  final String imageComplete;
  final String imageIncomplete;
  final String qrcode;
  final int value;
  final String type;
  final int? streak;

  UserActivity({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.earnings,
    required this.imageComplete,
    required this.imageIncomplete,
    required this.qrcode,
    required this.value,
    required this.type,
    this.streak,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json, String id) {
    return UserActivity(
      id: id,
      createdAt: json['createdAt'],
      description: json['description'],
      earnings: json['earnings'],
      imageComplete: json['imageComplete'],
      imageIncomplete: json['imageIncomplete'],
      qrcode: json['qrcode'],
      title: json['title'],
      type: json['type'],
      value: json['value'],
      streak: json['streak'] ?? 1,
    );
  }

  String getFormattedDate() {
    final DateTime date = DateTime.parse(createdAt);
    final DateFormat formatter = DateFormat('M/d/yy');
    return formatter.format(date);
  }
}
