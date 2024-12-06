import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/event/intercative_map_widget.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/events/event_quests_screen.dart';
import 'package:arcadia_mobile/src/views/events/loot_screen.dart';
import 'package:arcadia_mobile/src/views/events/raffle_view.dart';
import 'package:flutter/material.dart';

class EventHome extends StatefulWidget {
  final List<MissionDetails> missionList;
  const EventHome({super.key, required this.missionList});

  @override
  _EventHomeState createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AdsCarouselComponent(viewType: ViewType.eventHome),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _EventSection(
                      title: 'Royal Loot',
                      description: 'Prizes when you win the Final Competition.',
                      assetPath: 'assets/loot.png',
                      actionLabel: 'View Prizes',
                      onActionPressed: () {
                        _navigateUpWithSlideTransition(
                          context,
                          const LootView(), // Destination page
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _EventSection(
                      title: 'Rewards',
                      description: 'Redeem tokens for rewards',
                      assetPath: 'assets/gift_card.png',
                      actionLabel: 'Redeem Tokens',
                      onActionPressed: () {
                        _navigateUpWithSlideTransition(
                          context,
                          const RaffleView(
                            viewType: ViewType.prize,
                          ), // Destination page
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _EventSection(
                      title: 'Event Quests',
                      description: 'Complete quest for daily token rewards!',
                      assetPath: 'assets/map.png',
                      actionLabel: 'Earn Tokens',
                      onActionPressed: () {
                        _navigateUpWithSlideTransition(
                          context,
                          EventQuestsScreen(
                              missionList:
                                  widget.missionList), // Destination page
                        );
                      },
                    ),
                    // const SizedBox(height: 20),
                    // _EventSection(
                    //   title: 'Event Map',
                    //   description: 'Explore Battle Royale Arena ',
                    //   assetPath: 'assets/map_icon_1.png',
                    //   actionLabel: 'View',
                    //   onActionPressed: () {
                    //     _navigateUpWithSlideTransition(
                    //       context,
                    //       InteractiveMapWidget(), // Destination page
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  final String title;
  final String description;
  final String assetPath;
  final String actionLabel;
  final VoidCallback onActionPressed; // Callback for button action

  const _EventSection({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.actionLabel,
    required this.onActionPressed, // Required navigation callback
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Make the container take full width
      margin: const EdgeInsets.symmetric(horizontal: 16), // Outer margin
      padding: const EdgeInsets.all(16), // Inner padding
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD20E0D), // Dark red
            Color(0xFF020202), // Black
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildImage(context, assetPath),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 250, // Set the maximum width
            child: ElevatedButton(
              onPressed: onActionPressed, // Trigger the navigation callback
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(25), // Button height
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  actionLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, String assetPath) {
    return Image.asset(
      assetPath,
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.1,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.broken_image,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}
