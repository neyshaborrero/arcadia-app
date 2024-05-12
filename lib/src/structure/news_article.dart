import 'package:flutter/material.dart';

class NewsArticle {
  final int id;
  final String title;
  final String subtitle;
  final Uri? url;
  final String imageComplete;
  final String imageIncomplete;
  final Icon? icon;

  NewsArticle(
      {required this.id,
      required this.title,
      required this.subtitle,
      this.url,
      required this.imageComplete,
      required this.imageIncomplete,
      this.icon});
}
