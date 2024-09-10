import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // For platform check

class UpdateRequiredApp extends StatelessWidget {
  const UpdateRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Wrap your widget tree in a MaterialApp
      title: 'Update Required',
      home: UpdateAppView(),
    );
  }
}

class UpdateAppView extends StatelessWidget {
  const UpdateAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFF222222),
          title: Column(
            children: [
              // Adding the asset image at the top
              Image.asset(
                'assets/2024_Logo-B.png', // Ensure this path is correct
                height: 300, // Adjust height and width as needed
                width: 300,
              ),
              const Text('Update Required',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
              'A new version of the app is available. Please update to continue.',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                String url;

                // Determine the platform and set the appropriate URL
                if (Platform.isAndroid) {
                  url =
                      'https://play.google.com/store/apps/details?id=com.ysug.arcadia'; // Replace with your Android app's URL
                } else if (Platform.isIOS) {
                  url =
                      'https://apps.apple.com/us/app/arcadia-battle-royale/id6511213711'; // Replace with your iOS app's URL
                } else {
                  // If the platform is not Android or iOS, handle accordingly
                  url = ''; // Use a default or error URL if necessary
                }

                // Check if the device can launch the URL
                if (await canLaunchUrl(Uri.parse(url))) {
                  // If the URL can be launched, launch it
                  await launchURL(Uri.parse(url));
                } else {
                  // If the URL can't be launched, show an error message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Could not launch the update URL.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Update Now',
                  style: TextStyle(color: Color(0xFFD20E0D))),
            ),
          ],
        ),
      ),
    );
  }
}
