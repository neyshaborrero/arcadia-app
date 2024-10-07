import 'package:arcadia_mobile/src/notifiers/change_notifier.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';

Future<bool?> showActivityDialog(
  BuildContext context,
  String? missionId,
  bool showChildren,
  bool isCompleted,
  String subtitle,
  String description,
  String imageComplete,
  String imageIncomplete,
  int? streak,
) {
  final clickedState = Provider.of<ClickedState>(context, listen: false);
  clickedState.showChildren(showChildren);

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        // child: SizedBox(
        //   width: screenSize.width * 0.9, // 90% of screen width
        //   height: (streak != null && streak > 1)
        //       ? screenSize.height * 0.6
        //       : screenSize.height * 0.5, // 60% or 50% of screen height
        //   child: DecoratedBox(
        //     decoration: const BoxDecoration(
        //       color: Colors.black, // Background color
        //     ),
        child: IntrinsicHeight(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildMissionContent(
                  context,
                  isCompleted,
                  subtitle,
                  description,
                  imageComplete,
                  imageIncomplete,
                  streak,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _buildActionButton(
                context,
                isCompleted,
                streak,
              ),
            ],
          ),
        )),
      );
    },
  );
}
//       );
//     },
//   );
// }

Widget _buildMissionContent(
  BuildContext context,
  bool isCompleted,
  String subtitle,
  String description,
  String imageComplete,
  String imageIncomplete,
  int? streak,
) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFD20E0D), // Background color
      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
    ),
    padding: const EdgeInsets.all(16.0), // Add padding
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildTitle(context, isCompleted, streak),
        const SizedBox(height: 12),
        _buildImageDisplay(isCompleted, imageComplete, imageIncomplete, streak),
        if (streak == null || streak <= 1) ...[
          const SizedBox(height: 12),
          Flexible(
            // This will make the text wrap within the available space
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              description,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (streak != null && streak > 1) ...[
          const SizedBox(height: 16),
          _buildStreakDisplay(context, streak),
        ],
      ],
    ),
  );
}

Widget _buildTitle(BuildContext context, bool isCompleted, int? streak) {
  if (streak != null && streak > 1) return const SizedBox.shrink();
  return Text(
    isCompleted ? 'Tokens Earned' : 'Win Tokens',
    style: Theme.of(context).textTheme.titleLarge,
  );
}

Widget _buildImageDisplay(
  bool isCompleted,
  String imageComplete,
  String imageIncomplete,
  int? streak,
) {
  if (streak != null && streak > 1) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.asset('assets/fire.png', width: 95, height: 95),
      ),
    );
  }

  if (imageComplete.isNotEmpty) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.network(
          isCompleted ? imageComplete : imageIncomplete,
          width: 95,
          height: 95,
        ),
      ),
    );
  }

  return const SizedBox.shrink();
}

Widget _buildStreakDisplay(BuildContext context, int streak) {
  return Column(
    children: [
      Text(
        '$streak',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
            ),
      ),
      Text(
        'Day Streak!',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
      ),
      const SizedBox(height: 10),
      Stack(
        alignment: Alignment.center,
        children: [
          // The horizontal line behind the checkmarks
          Positioned(
            top:
                15, // Adjust this value to control the vertical alignment of the line
            left: MediaQuery.of(context).size.width *
                0.1, // Adjust start position
            right:
                MediaQuery.of(context).size.width * 0.1, // Adjust end position
            child: Container(
              height: 4,
              color: const Color(0xFFD9D9D9),
            ),
          ),
          // The row with the checkmarks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isCurrentStreak = index + 1 == streak;
              return Flexible(
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < streak
                              ? const Color(0xFF4BAE4F)
                              : const Color(0XFFD9D9D9)),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      child: isCurrentStreak
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4BAE4F),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/tokenization.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${index + 1}x',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              '${index + 1}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        'Complete a quest every day to build your streak and earn rewards.',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildActionButton(
  BuildContext context,
  bool isCompleted,
  int? streak,
) {
  final buttonText = isCompleted ? "Close" : "Scan QR";

  return Column(
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: Colors.black,
        ),
        onPressed: () {
          if (isCompleted) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
            _navigateUpWithSlideTransition(
                context,
                const QRCodeScreen(
                  viewType: ViewType.quest,
                ));
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 225, maxWidth: 225),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFD20E0D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
}
