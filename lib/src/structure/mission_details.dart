import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MissionDetails {
  final String id;
  final String createdAt;
  final String title;
  final String description;
  final String earnings;
  final String imageComplete;
  final String imageIncomplete;
  // final String qrcode;
  final int value;
  final String type;
  final bool oneTimeRedemption;
  final int frequencyPerDay;
  final String expires;
  final bool completed;

  MissionDetails(
      {required this.id,
      required this.createdAt,
      required this.title,
      required this.description,
      required this.earnings,
      required this.imageComplete,
      required this.imageIncomplete,
      // required this.qrcode,
      required this.value,
      required this.type,
      required this.oneTimeRedemption,
      required this.frequencyPerDay,
      required this.expires,
      required this.completed});

  factory MissionDetails.fromJson(Map<String, dynamic> json, String id) {
    return MissionDetails(
        id: id,
        createdAt: json['createdAt'],
        description: json['description'],
        earnings: json['earnings'],
        imageComplete: json['imageComplete'],
        imageIncomplete: json['imageIncomplete'],
        // qrcode: json['qrcode'],
        title: json['title'],
        type: json['type'],
        value: json['value'],
        oneTimeRedemption: json['oneTimeRedemption'],
        frequencyPerDay: json['frequencyPerDay'],
        expires: json['expires'],
        completed: json['completed']);
  }

  String getFormattedDate() {
    final DateTime date = DateTime.parse(createdAt);
    final DateFormat formatter = DateFormat('M/d/yy');
    return formatter.format(date);
  }

  static List<MissionDetails> sortByCompletedAndTitle(
      List<MissionDetails> missions) {
    missions.sort((a, b) {
      if (a.completed != b.completed) {
        return b.completed ? 0 : -1;
      }
      return a.title.compareTo(b.title);
    });
    return missions;
  }
}
