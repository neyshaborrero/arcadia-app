import 'dart:async';
import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/bounty.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/views/qrcode/player_qr_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BountyCountdownModal extends StatefulWidget {
  final FirebaseService firebaseService;
  final Bounty bounty;

  const BountyCountdownModal(
      {super.key, required this.firebaseService, required this.bounty});

  @override
  _BountyCountdownModalState createState() => _BountyCountdownModalState();
}

class _BountyCountdownModalState extends State<BountyCountdownModal> {
  late Timer _timer;
  late int _remainingTime; // Countdown starts from 15 minutes (in seconds)
  bool _showConfirmation = false; // State for confirmation logic
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);

    // Calculate remaining time based on expirationTimestamp
    _remainingTime = widget.bounty.expirationTimestamp != null
        ? ((widget.bounty.expirationTimestamp! -
                    DateTime.now().millisecondsSinceEpoch) /
                1000)
            .ceil()
        : 10 * 60;

    // Start countdown if there is remaining time
    if (_remainingTime > 0) {
      _startCountdown();
    } else {
      _onCountdownComplete(); // Handle case where expiration time is already passed
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        _onCountdownComplete();
      }
    });
  }

  void _onCountdownComplete() {
    // Perform any action after the countdown ends
    rejectBounty(widget.bounty.bountyId);
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onConfirmation() {
    setState(() {
      _showConfirmation = true; // Show confirmation button
    });
  }

  void _onCancel() {
    setState(() {
      _showConfirmation = false; // Reset to default button
    });
    rejectBounty(widget.bounty.bountyId);
  }

  Future<void> rejectBounty(String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not authenticated");
    }

    final token = await user?.getIdToken();
    if (token == null) {
      print("Unable to retrieve token");
    }

    // Fetch matches from the API
    try {
      if (token != null) {
        await _arcadiaCloud.rejectBounty(
          token,
          widget.bounty.bountyId,
        );
      }
    } catch (e) {
      print("Error fetching match details: $e");
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final UserProfile? userProfile =
        Provider.of<UserProfileProvider>(context).userProfile;
    final deepLink =
        'https://arcadia-deeplink.web.app?userqr=${userProfile!.qrcode}';

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
                        'Report for Bounty Match!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Column(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: [
                            //       UserAvatarWidget(
                            //         avatarRadius: screenHeight / 10,
                            //         profileImageUrl: userProfile != null
                            //             ? userProfile.profileImageUrl
                            //             : '',
                            //       ),
                            //       Text(
                            //         userProfile.gamertag.isNotEmpty
                            //             ? userProfile.gamertag
                            //             : '[gamertag]',
                            //         style: const TextStyle(
                            //           fontSize: 16.0,
                            //           fontWeight: FontWeight.w700,
                            //         ),
                            //       ),
                            //     ]),
                            QRCodeWidget(
                              data: deepLink,
                              qrcodeText: userProfile.qrcode,
                            ),
                          ]),
                      SizedBox(height: screenHeight * 0.02),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'You have been selected for a Bounty Match. Report yourself to the ',
                            ),
                            TextSpan(
                              text: 'Bounty Hunter Grounds',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                            const TextSpan(
                              text: ' or you will lose a Prestige.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        _formatTime(_remainingTime),
                        style: TextStyle(
                          fontSize: screenWidth * 0.15, // Scaled font size
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'If time is up you lose a prestige.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
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
                    if (_showConfirmation) {
                      // Handle the final action on confirmation
                      _timer.cancel(); // Stop the timer
                      _onCancel();
                    } else {
                      _onConfirmation(); // Trigger confirmation step
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showConfirmation
                        ? const Color(0xFFD20E0D) // Confirmation color
                        : const Color(0xFF5D5D5D), // Default color
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.02,
                    ),
                  ),
                  child: Text(
                    _showConfirmation
                        ? 'Are you Sure?' // Confirmation text
                        : 'I am not interested.', // Default text
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
