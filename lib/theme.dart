import 'package:flutter/material.dart';

ThemeData buildThemeData(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth >= 600;
  final bool isLargePhone = screenWidth >= 380 && screenWidth < 600;

  double titleFontSize;
  double labelSmallFontSize;
  double labelMediumFontSize;
  double labelLargeFontSize;

  if (isTablet) {
    titleFontSize = 26.0;
    labelSmallFontSize = 16.0;
    labelMediumFontSize = 18.0;
    labelLargeFontSize = 20.0;
  } else if (isLargePhone) {
    titleFontSize = 22.0;
    labelSmallFontSize = 14.0;
    labelMediumFontSize = 16.0;
    labelLargeFontSize = 18.0;
  } else {
    titleFontSize = 20.0;
    labelSmallFontSize = 12.0;
    labelMediumFontSize = 14.0;
    labelLargeFontSize = 16.0;
  }

  return ThemeData(
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: titleFontSize,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        fontSize: labelSmallFontSize,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: labelMediumFontSize,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontSize: labelLargeFontSize,
        fontWeight: FontWeight.w700,
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF000000),
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFD20E0D),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFD20E0D)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF313131)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelStyle: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 20.0,
      ),
      labelColor: Color(0xFFD20E0D),
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD20E0D),
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}
