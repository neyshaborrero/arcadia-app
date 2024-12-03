import 'package:flutter/material.dart';

class TokenEntriesWidget extends StatelessWidget {
  final int tokens;
  final String entries;
  final ValueChanged<int> onTokensUpdated; // Callback to update tokens

  const TokenEntriesWidget({
    super.key,
    required this.tokens,
    required this.entries,
    required this.onTokensUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 70.0, // Reduced maximum height
                  ),
                  padding: const EdgeInsets.all(8.0), // Reduced padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFD20E0D).withOpacity(0.85), // Dark red
                        const Color(0xFF020202).withOpacity(0.85), // Light red
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8), // Smaller radius
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Tokens Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Tokens',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall, // Smaller text
                          ),
                          const SizedBox(height: 4), // Reduced spacing
                          Row(children: [
                            Image.asset(
                              'assets/tokenization.png',
                              width: 30, // Reduced width
                              height: 30, // Reduced height
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 15), // Reduced spacing
                            Text(
                              tokens.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge, // Smaller text
                            ),
                          ]),
                        ],
                      ),
                      // Divider
                      Container(
                        height: 40, // Reduced height
                        width: 1.5, // Slightly smaller width
                        color: Colors.white,
                      ),
                      // Entries Section
                      GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Entries',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall, // Smaller text
                            ),
                            const SizedBox(height: 4), // Reduced spacing
                            Row(children: [
                              Image.asset(
                                'assets/tokenization_redeem.png',
                                width: 30, // Reduced width
                                height: 30, // Reduced height
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 15), // Reduced spacing
                              Text(
                                entries,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge, // Smaller text
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
