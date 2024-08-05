import 'package:arcadia_mobile/src/notifiers/change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:provider/provider.dart';
import 'quests_dialogs.dart';

class ListAction extends StatelessWidget {
  final List<MissionDetails> missions;
  final String title;
  final bool isTablet;
  final bool isLargePhone;
  final bool isSmallPhone;

  const ListAction({
    super.key,
    required this.missions,
    required this.title,
    required this.isTablet,
    required this.isLargePhone,
    required this.isSmallPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0, left: 20.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: missions.length,
          itemBuilder: (context, index) {
            MissionDetails mission = missions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2c2b2b),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    mission.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  subtitle: Text(
                    mission.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  leading: Container(
                    width: isTablet
                        ? 40
                        : isLargePhone
                            ? 35
                            : 29,
                    height: isTablet
                        ? 40
                        : isLargePhone
                            ? 35
                            : 29,
                    decoration: BoxDecoration(
                      color: (Provider.of<ClickedState>(context)
                                  .isClicked(mission.id) ||
                              mission.completed)
                          ? const Color(0XFF4aae50)
                          : const Color(0XFFc7c7c7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isTablet
                            ? 35
                            : isLargePhone
                                ? 30
                                : 24,
                      ),
                    ),
                  ),
                  onTap: () async {
                    showActivityDialog(
                            context,
                            mission.id,
                            false,
                            (Provider.of<ClickedState>(context)
                                    .isClicked(mission.id) ||
                                mission.completed),
                            mission.title,
                            mission.description,
                            mission.imageComplete,
                            mission.imageIncomplete)
                        .then((result) {
                      Provider.of<ClickedState>(context, listen: false)
                          .showChildren(true);
                      if (result != null && result == true) {
                        Provider.of<ClickedState>(context, listen: false)
                            .toggleClicked(mission.id);
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}