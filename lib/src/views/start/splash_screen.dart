import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/tools/is_tablet.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:arcadia_mobile/src/views/start/start_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';
// import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  late final ArcadiaCloud _arcadiaCloud;
  late AdsDetails ad;
  // late VideoPlayerController _controller;
  bool showIndicator = false;

  @override
  void initState() {
    super.initState();
    ad = Provider.of<AdsDetailsProvider>(context, listen: false).getSplashAd();

    // _controller = VideoPlayerController.asset('assets/arcadia_anime.mp4')
    //   ..initialize().then((_) {
    //     setState(() {
    //       _controller.setLooping(true);
    //       _controller.setVolume(0);
    //       _controller.play();
    //     });
    //   });

    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    // _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the app is resumed, show the splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
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
    final isTabletDevice = isTablet(context);
    return Scaffold(
      body: Container(
          color: const Color(0xFFE30D0D), // Background color
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                FractionallySizedBox(
                  widthFactor: isTabletDevice
                      ? 0.7
                      : 0.9, // 50% for tablets, 90% for other devices
                  child: GestureDetector(
                    onTap: () {
                      launchURL(Uri.parse(ad.url)); // Launch the URL on tap
                    },
                    child: CachedNetworkImage(
                      imageUrl: ad.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                if (showIndicator)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
              ]),
            ],
          )),
    );
  }
}
