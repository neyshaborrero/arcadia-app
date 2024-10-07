import 'package:flutter/material.dart';

Widget buildNoActivityWidget() {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double screenHeight = constraints.maxHeight;
      double screenWidth = constraints.maxWidth;

      // Adjust sizes based on screen size
      double imageSize = screenWidth * 0.25;
      double paddingSize = screenHeight * 0.05;
      // double buttonPaddingHorizontal = screenWidth * 0.15;
      // double buttonPaddingVertical = screenHeight * 0.02;
      double textFontSize = screenHeight * 0.07;

      return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2B2B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/scan_activity.png', // Replace with your image asset path
                  width: imageSize,
                  height: imageSize,
                ),
                SizedBox(height: paddingSize),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Text(
                    'You have no recent activity.\nComplete daily quests and play to get started.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: textFontSize,
                        ),
                  ),
                ),
              ],
            ),
          ));
    },
  );
}
