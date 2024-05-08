import 'package:flutter/material.dart';

class NewsArticle {
  final int id;
  final String title;
  final String subtitle;
  final Uri? url;
  final Icon? icon;

  NewsArticle(
      {required this.id,
      required this.title,
      required this.subtitle,
      this.url,
      this.icon});
}
