import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/prize_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RaffleEntriesScreen extends StatelessWidget {
  final List<PrizeDetails> prizeList;
  final int entriesDay;

  const RaffleEntriesScreen(
      {super.key, required this.prizeList, required this.entriesDay});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final columnCount = isTablet ? 3 : 2;

    return Column(
      children: <Widget>[
        const SizedBox(
          height: 10,
        ),
        const AdsCarouselComponent(
          viewType: ViewType.prize,
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 100.0, // Set the maximum height
                      ),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFD20E0D)
                                .withOpacity(0.85), // Dark red color start
                            const Color(0xFF020202)
                                .withOpacity(0.85), // Lighter red color end
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Tokens',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 6),
                              Row(children: [
                                Image.asset(
                                  'assets/tokenization.png',
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 25),
                                Text(
                                  userProfile != null
                                      ? userProfile.tokens.toString()
                                      : '0',
                                  style: Theme.of(context).textTheme.titleLarge,
                                )
                              ])
                            ],
                          ),
                          Container(
                            height:
                                50, // Adjust the height according to your needs
                            width: 2, // Width of the line
                            color: Colors.white, // Color of the line
                          ),
                          GestureDetector(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Entries',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 5),
                                Row(children: [
                                  Image.asset(
                                    'assets/tokenization_redeem.png',
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 25),
                                  Text(
                                    '$entriesDay',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  )
                                ])
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
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    spacing: 10.0, // Spacing between items horizontally
                    runSpacing: 10.0, // Spacing between items vertically
                    children: List.generate(prizeList.length, (index) {
                      final PrizeDetails prize = prizeList[index];
                      return Container(
                        width: (screenWidth - (columnCount + 1) * 10) /
                            columnCount,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2c2b2b),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              prize.title,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CachedNetworkImage(
                              width: 280,
                              height: 150,
                              imageUrl: prize.image,
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/tokenization.png',
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${prize.token} Tokens',
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.translate(
                                  offset: const Offset(
                                      0, -6), // Move the text 3 pixels up
                                  child: Text(
                                    'Sponsored by:',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                CachedNetworkImage(
                                  width: 150,
                                  height: 90,
                                  imageUrl: prize.poweredBy,
                                  fit: BoxFit.fitWidth,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
