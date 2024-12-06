import 'dart:async';
import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinalCompetitionModal extends StatefulWidget {
  final FirebaseService firebaseService;

  const FinalCompetitionModal({
    super.key,
    required this.firebaseService,
  });

  @override
  _FinalCompetitionModalState createState() => _FinalCompetitionModalState();
}

class _FinalCompetitionModalState extends State<FinalCompetitionModal> {
  bool _showConfirmation = false; // State for confirmation logic
  bool _showConfirmationYes = false; // State for confirmation logic
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onConfirmationYes() {
    setState(() {
      _showConfirmationYes = true; // Show confirmation button
    });
  }

  void _onConfirmation() async {
    setState(() {
      _showConfirmation = true; // Show confirmation button
    });
  }

  Future<void> answerFinalCompetition(String status) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw Exception("Unable to retrieve token");
    }

    try {
      await _arcadiaCloud.answerFinalCompetition(token, status);
    } catch (e) {
      print("Error sending answer: $e");
      rethrow; // Re-throw the error to be caught in _onConfirmation
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final UserProfile? userProfile =
        Provider.of<UserProfileProvider>(context).userProfile;

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
                        const Color(0xFFD20E0D),
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
                        'You Made It!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Image.asset('assets/loot_chest.png',
                          width: 200, height: 200, fit: BoxFit.contain),
                      Text(
                        'You are one of the top 12 players that have made it to the',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Final Competition! ',
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Accept the following terms to compete for the',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Royal Loot',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: <Color>[
                                Color(0xFFFDD835), // Gold color
                                Color(0xFFFFF9C4), // Lighter gold/yellow
                                Color(0xFFFDD835), // Gold again
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                      SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Surrender your ',
                            ),
                            TextSpan(
                              text: '${userProfile?.tokens} tokens ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const TextSpan(
                              text: "earned in today's competition",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Surrender your ',
                            ),
                            TextSpan(
                              text: '${userProfile?.xp} XP ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const TextSpan(
                              text: "earned in today's competition",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'If you dont accept you wont participate in the final competition and your XP will be converted to tokens',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_showConfirmationYes) {
                          try {
                            await answerFinalCompetition("accepted");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Answer sent successfully to Master Control.'),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error sending the answer to Master Control, please try again later',
                                ),
                              ),
                            );
                          }
                        } else {
                          _onConfirmationYes(); // Trigger confirmation step
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showConfirmationYes
                            ? const Color(0xFF5D5D5D) // Confirmation color
                            : const Color(0xFF4BAE4F), // Default color
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        _showConfirmationYes
                            ? 'Confirm Yes' // Confirmation text
                            : 'Lets do it', // Default text
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_showConfirmation) {
                          try {
                            await answerFinalCompetition("accepted");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Answer sent successfully to Master Control.'),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error sending the answer to Master Control, please try again later',
                                ),
                              ),
                            );
                          }
                        } else {
                          _onConfirmation(); // Trigger confirmation step
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showConfirmation
                            ? const Color(0xFFD20E0D) // Confirmation color
                            : const Color(0xFF5D5D5D), // Default color
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        _showConfirmation
                            ? 'Confirm No' // Confirmation text
                            : 'Not today', // Default text
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
