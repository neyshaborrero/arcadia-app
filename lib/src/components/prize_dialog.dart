import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart'; // Update with the actual path to your QRCodeScreen class

void showPrizeDialog(
  BuildContext context,
  String title,
  String image,
  String token,
  String description,
  String poweredby,
  String termsurl,
) {
  showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.transparent, // Background color
            ), // Padding from all sides
            child: Padding(
              padding: const EdgeInsets.all(0.0),
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
                            title,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight
                                  .w700, // This corresponds to font-weight: 700 in CSS
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                              child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: CachedNetworkImage(
                                    width: 214,
                                    height: 118,
                                    imageUrl: image,
                                    fit: BoxFit.fitWidth,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ))),
                          const SizedBox(height: 15),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/tokenization.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  '$token Tokens',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight
                                        .w800, // This corresponds to font-weight: 700 in CSS
                                  ),
                                ),
                                const Text(
                                  ' / entry',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight
                                        .w600, // This corresponds to font-weight: 700 in CSS
                                  ),
                                )
                              ]),
                          const SizedBox(height: 5),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight
                                  .w600, // This corresponds to font-weight: 700 in CSS
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Transform.translate(
                                offset: const Offset(
                                    0, 4), // Move the text 3 pixels up
                                child: const Text(
                                  'Sponsored by:',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight
                                        .w600, // This corresponds to font-weight: 700 in CSS
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CachedNetworkImage(
                                width: 80,
                                height: 45,
                                imageUrl: poweredby,
                                fit: BoxFit.fitWidth,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Raffle entries unlock in Arcadia on Dec 7 & 8!',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight
                                  .w800, // This corresponds to font-weight: 700 in CSS
                            ),
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
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog first
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
                            child: Text(
                              "Close",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            )),
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
