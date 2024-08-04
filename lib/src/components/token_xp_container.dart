import 'package:arcadia_mobile/src/tools/is_tablet.dart';
import 'package:flutter/material.dart';
import 'token_info.dart';

class TokenXPContainer extends StatelessWidget {
  final int tokens;
  final VoidCallback onViewRewardsTap;

  const TokenXPContainer({
    super.key,
    required this.tokens,
    required this.onViewRewardsTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool tablet = isTablet(context);
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    // Define scaling factors
    final double scaleFactor =
        tablet ? screenSize.height / 1000 : screenSize.height / 900;
    final double containerHeight = 100 * scaleFactor;
    final double padding = 12 * scaleFactor;
    final double imageSize = 45 * scaleFactor;
    final double dividerHeight = 50 * scaleFactor;
    final double fontSize =
        Theme.of(context).textTheme.labelMedium!.fontSize! * scaleFactor;

    return Container(
      constraints: BoxConstraints(
        maxHeight:
            containerHeight, // Set the maximum height based on scaling factor
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD20E0D).withOpacity(0.85), // Dark red color start
            const Color(0xFF020202).withOpacity(0.85), // Lighter red color end
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [TokenInfo(tokens: tokens, scaleFactor: scaleFactor)],
          ),
          Container(
            height: dividerHeight, // Adjust the height according to your needs
            width: 2, // Width of the line
            color: Colors.white, // Color of the line
          ),
          GestureDetector(
            onTap: onViewRewardsTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'View Rewards',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(fontSize: fontSize),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Image.asset(
                      'assets/prize.png',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
