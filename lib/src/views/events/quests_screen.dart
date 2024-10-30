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

class QuestsView extends StatelessWidget {
  final List<MissionDetails> missionList;

  const QuestsView({super.key, required this.missionList});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;

    // Separate the missions into daily quests and side quests
    final dailyQuests =
        missionList.where((mission) => mission.type == 'dquest').toList();
    final sideQuests =
        missionList.where((mission) => mission.type == 'squest').toList();

    // Determine if the device is a tablet based on screen width
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final bool isLargePhone = MediaQuery.of(context).size.shortestSide >= 380 &&
        MediaQuery.of(context).size.shortestSide < 600;
    final bool isSmallPhone = MediaQuery.of(context).size.shortestSide < 380;

    return Consumer<ClickedState>(
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
                                context, const RaffleView());
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
                    missions: dailyQuests,
                    title: 'Earn Daily Tokens',
                    isTablet: isTablet,
                    isLargePhone: isLargePhone,
                    isSmallPhone: isSmallPhone,
                    onShowChildren: (bool value) {
                      clickedState.showChildren(value);
                    },
                  ),
                  ListAction(
                    missions: sideQuests,
                    title: 'Earn More Tokens',
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
          if (clickedState.isVisible)
            Padding(
              padding: const EdgeInsets.only(bottom: 42, top: 5),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 400 : 200),
                child: ElevatedButton(
                  onPressed: () =>
                      launchURL(Uri.parse('https://prticket.sale/ARCADIA')),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(isTablet ? 70 : 50),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 10,
                      vertical: isTablet ? 20 : 10,
                    ),
                    child: Text(
                      'Buy Tickets',
                      style: TextStyle(fontSize: isTablet ? 24 : 18),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
