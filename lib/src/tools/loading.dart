import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildLoadingImageSkeleton(double width) {
  return Shimmer.fromColors(
    baseColor:
        const Color(0xFFD20E0D).withOpacity(0.85), // Red color from your app
    highlightColor:
        Colors.redAccent.withOpacity(0.6), // Lighter red as highlight
    child: Container(
      width: width,
      height: width, // Use width for both dimensions to make it circular
      decoration: BoxDecoration(
        color:
            const Color(0xFFD20E0D).withOpacity(0.85), // Same red color as base
        shape: BoxShape.circle, // Circular shape
      ),
    ),
  );
}

Widget buildShimmerSurveyContainer() {
  return Shimmer.fromColors(
    baseColor: const Color(0xFFD20E0D).withOpacity(0.8), // Red base color
    highlightColor:
        const Color(0xFFD20E0D).withOpacity(0.4), // Lighter red highlight color
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red[800], // Red base color
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color:
                  Colors.red[700], // Slightly lighter red for image placeholder
              shape: BoxShape.circle, // Make it circular
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.red[700],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 15,
            color: Colors.red[700],
          ),
        ],
      ),
    ),
  );
}

// Shimmer effect for the ad container
Widget buildShimmerAdContainer(double height, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: const Color(0xFFD20E0D).withOpacity(0.8), // Red base color
    highlightColor: const Color(0xFFD20E0D).withOpacity(0.4), // Lighter red
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      width: MediaQuery.of(context).size.width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.red[800], // Base color for shimmer
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

// Shimmer loading effect for news articles with padding
Widget buildShimmerNewsCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 18.0),
    child: Shimmer.fromColors(
      baseColor: const Color(0xFF2c2b2b).withOpacity(0.85),
      highlightColor: const Color(0xFF2c2b2b).withOpacity(0.55),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 20.0,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 10),
            Container(
              width: 100.0,
              height: 16.0,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    ),
  );
}
