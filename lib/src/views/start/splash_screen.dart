import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/views/start/start_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_view.dart'; // Import your Home screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return; //
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const StartScreen(),
          ),
        );
      } else {
        print(await user.getIdToken());
        String? token = await user.getIdToken();
        Provider.of<AdsDetailsProvider>(context, listen: false).addAdsDetails([
          AdsDetails(
              id: "123456",
              image:
                  "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2Fnews_ad.png?alt=media&token=91fc471c-0e56-461b-a030-9f50d8cd1c6c",
              url: "google.com"),
          AdsDetails(
              id: "123457",
              image:
                  "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2Fnews_ad.png?alt=media&token=91fc471c-0e56-461b-a030-9f50d8cd1c6c",
              url: "google.com")
        ]);

        // Provider.of<AdsDetailsProvider>(context, listen: false).addAdsDetails([
        //   AdsDetails(
        //       id: '123456',
        //       image:
        //           'https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2Fnews_ad.png?alt=media&token=91fc471c-0e56-461b-a030-9f50d8cd1c6c',
        //       url: 'google.com')
        //   // {
        //   //   "image":
        //   //       "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2Fnews_ad.png?alt=media&token=91fc471c-0e56-461b-a030-9f50d8cd1c6c"
        //   // } as AdsDetails,
        //   // {
        //   //   "image":
        //   //       "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2Fnews_ad.png?alt=media&token=91fc471c-0e56-461b-a030-9f50d8cd1c6c"
        //   // } as AdsDetails
        // ]);

        if (token != null) {
          UserProfile? profile = await _arcadiaCloud.fetchUserProfile(token);

          if (profile != null) {
            Provider.of<UserProfileProvider>(context, listen: false)
                .setUserProfile(profile);
          }

          List<MissionDetails>? missions = await _fetchMissions(token);
          if (missions != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(missions: missions)),
            );
          }
        }
      }
    });
  }

  Future<List<MissionDetails>?> _fetchMissions(String token) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken();

    if (token == null) return null;

    return await _arcadiaCloud.fetchArcadiaMissions(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Color(0xFFE30D0D), // Background color
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  'assets/ad_splash.jpg',
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 70),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ]),
            ],
          )),
    );
  }
}
