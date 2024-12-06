import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/list_actions.dart';
import 'package:arcadia_mobile/src/components/token_xp_container.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:arcadia_mobile/src/views/events/raffle_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notifiers/change_notifier.dart';

class EventQuestsScreen extends StatelessWidget {
  final List<MissionDetails> missionList;

  const EventQuestsScreen({super.key, required this.missionList});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;

    // Determine if the device is a tablet based on screen width
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final bool isLargePhone = MediaQuery.of(context).size.shortestSide >= 380 &&
        MediaQuery.of(context).size.shortestSide < 600;
    final bool isSmallPhone = MediaQuery.of(context).size.shortestSide < 380;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text(
            'Event Quests',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight
                  .w700, // This corresponds to font-weight: 700 in CSS
            ),
          ),
          toolbarHeight: 30.0,
        ),
        body: Consumer<ClickedState>(
          builder: (context, clickedState, child) => Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              const AdsCarouselComponent(viewType: ViewType.quest),
              if (clickedState.isVisible)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TokenXPContainer(
                              tokens: userProfile?.tokens ?? 0,
                              onViewRewardsTap: () {
                                _navigateUpWithSlideTransition(
                                    context,
                                    const RaffleView(
                                      viewType: ViewType.prize,
                                    ));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (clickedState.isVisible)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18.0),
                    children: [
                      ListAction(
                        missions: missionList,
                        title: 'Event Tokens',
                        isTablet: isTablet,
                        isLargePhone: isLargePhone,
                        isSmallPhone: isSmallPhone,
                        onShowChildren: (bool value) {
                          clickedState.showChildren(value);
                        },
                      ),
                      const SizedBox(
                        height: 20, // Add some spacing to prevent overlap
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
