import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
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
                const AdsCarouselComponent(),
                const SizedBox(
                  height: 10,
                ),
                if (clickedState.isVisible)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                    const Color(0xFFD20E0D).withOpacity(
                                        0.85), // Dark red color start
                                    const Color(0xFF020202).withOpacity(
                                        0.85), // Lighter red color end
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Tokens Earned',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
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
                                      onTap: () {
                                        // Perform the desired action when the Column is tapped
                                        _navigateUpWithSlideTransition(
                                            context, const RaffleView());
                                        // You can navigate to a new page, show a dialog, etc.
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'View Rewards',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(children: [
                                            Image.asset(
                                              'assets/prize.png',
                                              width: 45,
                                              height: 45,
                                              fit: BoxFit.cover,
                                            ),
                                          ])
                                        ],
                                      )),
                                ],
                              ),
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
              ],
            ));
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
