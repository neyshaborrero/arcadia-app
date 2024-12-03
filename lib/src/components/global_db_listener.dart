import 'package:arcadia_mobile/services/db_listener_service.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GlobalDBListener extends StatelessWidget {
  final Widget child;

  const GlobalDBListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseListenerService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);

    // Initialize the listener
    databaseService.initializeListener();

    // Check the static flag for navigation
    if (databaseService.secondListenerValue &&
        !DatabaseListenerService.hasNavigated) {
      DatabaseListenerService.hasNavigated = true;
      Future.microtask(() async {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (Route<dynamic> route) => false,
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print("User not authenticated");
          return;
        }

        // Write "abandon" action to the database
        await firebaseService.writeToDatabase(
          '/users/${user.uid}/refresh',
          false,
        );
      });
    }

    return Stack(
      children: [
        child,
        if (databaseService.currentMatchValue.length > 2)
          _buildBlockingModal(context),
        if (databaseService.currentMatchValue == "0")
          _buildResultsModal(context, firebaseService),
        if (databaseService.currentMatchValue == "-1")
          _buildLoserModal(context, firebaseService),
      ],
    );
  }

  Widget _buildBlockingModal(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black87, // Makes the background darker
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Match in Progress.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Reset listener and dismiss modal
            //     Provider.of<DatabaseListenerService>(context, listen: false)
            //         .reset();
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.red,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //   ),
            //   child: const Text(
            //     'Abandon Match',
            //     style: TextStyle(
            //       fontSize: 18,
            //       color: Colors.white,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsModal(
      BuildContext context, FirebaseService firebaseService) {
    return Positioned.fill(
      child: Material(
        color: Colors.black87, // Makes the background darker
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You Are the Winner 100XP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  print("User not authenticated");
                  return;
                }

                // Write "abandon" action to the database
                await firebaseService.writeToDatabase(
                  '/users/${user.uid}/currentMatch',
                  '',
                );

                await firebaseService.writeToDatabase(
                  '/users/${user.uid}/refresh',
                  true,
                );

                Provider.of<DatabaseListenerService>(context, listen: false)
                    .reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Congrats',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoserModal(
      BuildContext context, FirebaseService firebaseService) {
    return Positioned.fill(
      child: Material(
        color: Colors.black87, // Makes the background darker
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You Are a Loser 25XP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  print("User not authenticated");
                  return;
                }

                // Write "abandon" action to the database
                await firebaseService.writeToDatabase(
                  '/users/${user.uid}/currentMatch',
                  '',
                );

                await firebaseService.writeToDatabase(
                  '/users/${user.uid}/refresh',
                  true,
                );

                Provider.of<DatabaseListenerService>(context, listen: false)
                    .reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'I Need to Practice',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
