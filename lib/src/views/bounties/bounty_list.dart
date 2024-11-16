import 'dart:async';
import 'package:arcadia_mobile/src/components/bounty_countdown.dart';
import 'package:arcadia_mobile/src/structure/bounty.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BountiesList extends StatefulWidget {
  final List<Bounty> bounties;

  const BountiesList({super.key, required this.bounties});

  @override
  _BountiesListState createState() => _BountiesListState();
}

class _BountiesListState extends State<BountiesList> {
  late List<int?>
      expirationTimestamps; // Store expiration timestamps for each bounty

  @override
  void initState() {
    super.initState();
    expirationTimestamps = List<int?>.filled(widget.bounties.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final columnCount = isTablet ? 1 : 1;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: List.generate(widget.bounties.length, (index) {
            final bounty = widget.bounties[index];

            return Container(
              width: (screenWidth - (columnCount + 1) * 10) / columnCount,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFD20E0D).withOpacity(0.85),
                    const Color(0xFF020202).withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 120,
                      backgroundColor: const Color(0xFF2C2B2B),
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: bounty.playerProfileImageUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      bounty.playerProfileImageUrl)
                                  : const AssetImage('assets/hambopr.jpg')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bounty.gamerTag,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Streak ${bounty.currentStreak}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  // Display the countdown if we have an expiration timestamp
                  if (expirationTimestamps[index] != null)
                    BountyCountdownWidget(
                        expirationTimestamp: expirationTimestamps[index]!),
                  const SizedBox(height: 15),
                  if (expirationTimestamps[index] == null)
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: ElevatedButton(
                        onPressed: () async {
                          final String result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRCodeScreen(
                                viewType: ViewType.challengeBounty,
                                bountyId: bounty.bountyId,
                              ),
                            ),
                          );

                          // Parse the expiration timestamp and update state
                          final int newExpirationTimestamp =
                              int.tryParse(result) ?? 0;
                          setState(() {
                            expirationTimestamps[index] =
                                newExpirationTimestamp;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD20E0D),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Challenge',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
