import 'package:flutter/material.dart';
import 'dart:math';

bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final diagonal = sqrt(size.width * size.width + size.height * size.height);
  return diagonal >
      1100.0; // Consider devices with diagonal size greater than 1100 pixels as tablets
}

bool isTabletCarouselAds(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final diagonal =
      sqrt((size.width * size.width) + (size.height * size.height));
  return diagonal >
      1100.0; // Consider devices with diagonal size greater than 1100 pixels as tablets
}
