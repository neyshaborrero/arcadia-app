import 'package:arcadia_mobile/src/routes/slide_right_route.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:flutter/material.dart';

void navigateWithSlideRightTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideRightRoute(page: page));
}

void navigateUpWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
}
