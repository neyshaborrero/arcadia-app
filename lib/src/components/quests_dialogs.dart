import 'package:arcadia_mobile/src/notifiers/change_notifier.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart'; // Update with the actual path to your QRCodeScreen class

Future<bool?> showActivityDialog(
  BuildContext context,
  bool showChildren,
  bool isCompleted,
  String subtitle,
  String description,
  String imageComplete,
  String imageIncomplete,
) {
  final clickedState = Provider.of<ClickedState>(context, listen: false);
  clickedState.showChildren(showChildren); // Hide children
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: SingleChildScrollView(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black, // Background color
            ), // Padding from all sides
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Makes the column wrap its content
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD20E0D),
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ), // Background color of the circle
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Use MainAxisSize.min to wrap content in the column.
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Tokens Earned',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (imageComplete != '')
                            Center(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: isCompleted
                                    ? Image.network(imageComplete,
                                        width: 93, height: 93)
                                    : Image.network(imageIncomplete,
                                        width: 93, height: 93),
                              ),
                            ),
                          if (imageComplete != '') const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      isCompleted
                          ? Navigator.of(context).pop()
                          : _navigateUpWithSlideTransition(context,
                              const QRCodeScreen()); // Close the dialog
                    },
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 225, maxWidth: 225),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD20E0D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: isCompleted
                              ? Text(
                                  "Close",
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                )
                              : Text(
                                  "Scan QR",
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
}
