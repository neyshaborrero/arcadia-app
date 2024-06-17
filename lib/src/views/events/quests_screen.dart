import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notifiers/change_notifier.dart';

class QuestsView extends StatelessWidget {
  final List<MissionDetails> newsArticleList;

  const QuestsView({super.key, required this.newsArticleList});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    return Consumer<ClickedState>(
        builder: (context, clickedState, child) => Column(
              children: <Widget>[
                if (clickedState.isVisible)
                  Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('Tokens Earned',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge),
                      )),
                if (clickedState.isVisible)
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       '3,050',
                        //       style: Theme.of(context).textTheme.titleLarge,
                        //     ),
                        //     Text(
                        //       'XP',
                        //       style: Theme.of(context).textTheme.titleSmall,
                        //     )
                        //   ],
                        // ),
                        // Container(
                        //   height: 50, // Adjust the height according to your needs
                        //   width: 2, // Width of the line
                        //   color: Colors.white, // Color of the line
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              userProfile != null
                                  ? userProfile.tokens.toString()
                                  : '0',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            // Text(
                            //   'Tokens',
                            //   style: Theme.of(context).textTheme.titleSmall,
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                if (clickedState.isVisible)
                  Padding(
                      padding: const EdgeInsets.only(top: 36.0, left: 37.0),
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
                                  itemCount: newsArticleList.length,
                                  itemBuilder: (context, index) {
                                    MissionDetails article =
                                        newsArticleList[index];
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
                                                article.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge,
                                              ),
                                              subtitle: Text(
                                                article.description,
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
                                                  color: clickedState
                                                          .isClicked(article.id)
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
                                                        false,
                                                        clickedState.isClicked(
                                                            article.id),
                                                        article.title,
                                                        article.description,
                                                        article.imageComplete,
                                                        article.imageIncomplete)
                                                    .then((result) {
                                                  clickedState
                                                      .showChildren(true);
                                                  if (result != null &&
                                                      result == true) {
                                                    clickedState.toggleClicked(
                                                        article.id);
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

  // void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
  //   Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  // }

//   Future<bool?> showCustomDialog(BuildContext context, bool isCompleted,
//       String subtitle, String description) {
//     final clickedState = Provider.of<ClickedState>(context, listen: false);
//     clickedState.showChildren(false); // Hide children
//     return showDialog<bool>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.black,
//           child: DecoratedBox(
//               decoration: const BoxDecoration(
//                 color: Colors.black, // Background color
//               ), // Padding from all sides

//               child: Column(
//                 // return Dialog(
//                 //   // backgroundColor: const Color(0xFFD20E0D),
//                 //   insetPadding: const EdgeInsets.all(40),

//                 //   child: Align(
//                 //       alignment: Alignment.center,
//                 //       // This will ensure the dialog is centered on screen.
//                 //       child: SizedBox(
//                 //           width: MediaQuery.of(context).size.width * 0.8,
//                 //           child: Column(
//                 mainAxisSize:
//                     MainAxisSize.min, // Makes the column wrap its content
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFD20E0D),
//                         borderRadius: BorderRadius.circular(
//                             10.0), // Background color of the circle
//                       ),
//                       padding: const EdgeInsets.all(20),
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       height: MediaQuery.of(context).size.height * 0.32,
//                       child: Column(
//                           mainAxisSize: MainAxisSize
//                               .min, // Use MainAxisSize.min to wrap content in the column.
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Text(
//                               'Tokens Earned',
//                               style: Theme.of(context).textTheme.titleLarge,
//                             ),
//                             const SizedBox(height: 12),
//                             Center(
//                                 child: Container(
//                                     decoration: const BoxDecoration(
//                                         color: Colors.white,
//                                         shape: BoxShape.circle),
//                                     child: isCompleted
//                                         ? Image.asset('assets/map_icon_1.png',
//                                             width: 93, height: 93)
//                                         : Image.asset(
//                                             'assets/map_icon_1_grey.png',
//                                             width: 93,
//                                             height: 93))),
//                             const SizedBox(height: 12),
//                             Text(
//                               subtitle,
//                               style: Theme.of(context).textTheme.labelLarge,
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               description,
//                               style: Theme.of(context).textTheme.labelMedium,
//                               textAlign: TextAlign.center,
//                             ),
//                           ])),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(48),
//                           backgroundColor: Colors.black),
//                       onPressed: () {
//                         isCompleted
//                             ? Navigator.of(context).pop()
//                             : _navigateUpWithSlideTransition(context,
//                                 const QRCodeScreen()); // Close the dialog
//                       },
//                       child: ConstrainedBox(
//                           constraints: const BoxConstraints(
//                               minWidth: 225, maxWidth: 225),
//                           child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFD20E0D),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: isCompleted
//                                     ? Text(
//                                         "Close",
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .headlineSmall,
//                                       )
//                                     : Text(
//                                         "Scan QR",
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .headlineSmall,
//                                       ),
//                               )))),
//                 ],
//               )),
//         );
//       },
//     );
//   }
}
