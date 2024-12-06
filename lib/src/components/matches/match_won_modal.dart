import 'package:arcadia_mobile/services/db_listener_service.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MatchWonModal extends StatefulWidget {
  final FirebaseService firebaseService;
  final int winXp;

  const MatchWonModal(
      {super.key, required this.firebaseService, required this.winXp});

  @override
  _MatchWonModalState createState() => _MatchWonModalState();
}

class _MatchWonModalState extends State<MatchWonModal> {
  late DatabaseListenerService databaseListenerService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the DatabaseListenerService
    databaseListenerService =
        Provider.of<DatabaseListenerService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          Colors.black.withOpacity(0.8), // Fullscreen overlay with transparency
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF4BAE4F),
                        const Color(0xFF020202),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'You Won!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Image.asset('assets/trophy.png',
                          width: screenWidth * 0.4,
                          height: screenWidth * 0.4,
                          fit: BoxFit.cover),
                      SizedBox(height: screenHeight * 0.04),
                      Text(
                        'You Gain',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08, // Scaled font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${widget.winXp} XP',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08, // Scaled font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      print("User not authenticated");
                      return;
                    }

                    // Write "abandon" action to the database
                    await widget.firebaseService.writeToDatabase(
                      '/users/${user.uid}/currentMatch',
                      '',
                    );

                    await widget.firebaseService.writeToDatabase(
                      '/users/${user.uid}/refresh',
                      true,
                    );

                    // Use the stored reference instead of looking up the Provider
                    databaseListenerService.reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFD20E0D), // Confirmation color
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.02,
                    ),
                  ),
                  child: Text(
                    'Close', // Default text
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
