import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
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
                        )),
                      ],
                    ),
                  ),
                if (clickedState.isVisible)
                  Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 37.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Daily Quests',
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleLarge),
                      )),
                if (clickedState.isVisible)
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Consumer<ClickedState>(
                            builder: (context, clickedState, child) =>
                                ListView.builder(
                                  itemCount: missionList.length,
                                  itemBuilder: (context, index) {
                                    MissionDetails mission = missionList[index];
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2c2b2b),
                                              borderRadius: BorderRadius.circular(
                                                  10.0), // Adds rounded corners to the container
                                            ), // Conditional background color
                                            child: ListTile(
                                              title: Text(
                                                mission.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge,
                                              ),
                                              subtitle: Text(
                                                mission.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                              ),
                                              leading: Container(
                                                width:
                                                    29, // Adjust the size as needed
                                                height:
                                                    29, // Adjust the size as needed
                                                decoration: BoxDecoration(
                                                  color: (clickedState
                                                              .isClicked(
                                                                  mission.id) ||
                                                          mission.completed)
                                                      ? const Color(0XFF4aae50)
                                                      : const Color(
                                                          0XFFc7c7c7), // Background color of the circle
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                    child: Icon(
                                                  Icons
                                                      .check, // Just the checkmark
                                                  color: Colors.white,
                                                  size:
                                                      29, // Adjust the size of the checkmark as needed
                                                )),
                                              ),
                                              onTap: () async {
                                                showActivityDialog(
                                                        context,
                                                        mission.id,
                                                        false,
                                                        (clickedState.isClicked(
                                                                mission.id) ||
                                                            mission.completed),
                                                        mission.title,
                                                        mission.description,
                                                        mission.imageComplete,
                                                        mission.imageIncomplete)
                                                    .then((result) {
                                                  clickedState
                                                      .showChildren(true);
                                                  if (result != null &&
                                                      result == true) {
                                                    clickedState.toggleClicked(
                                                        mission.id);
                                                    // Handle the result here
                                                  }
                                                });
                                              },
                                            )));
                                  },
                                ))),
                  ),
                if (clickedState.isVisible)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 368),
                    child: ElevatedButton(
                      onPressed: () =>
                          launchURL(Uri.parse('https://prticket.sale/ARCADIA')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        child: Text(
                          'Buy Tickets',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 40,
                )
              ],
            ));
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
