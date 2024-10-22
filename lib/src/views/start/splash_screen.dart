import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:arcadia_mobile/src/views/matches/match_activity.dart';
import 'package:arcadia_mobile/src/views/profile/update_profile.dart';
import 'package:arcadia_mobile/src/views/start/start_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  late final ArcadiaCloud _arcadiaCloud;
  late Future<AdsDetails> _splashAdFuture;
  bool showIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);

    _splashAdFuture = _initializeSplashAd();

    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  Future<AdsDetails> _initializeSplashAd() async {
    final adsProvider = Provider.of<AdsDetailsProvider>(context, listen: false);
    if (adsProvider.adsDetails.isEmpty) {
      await Future.delayed(
          const Duration(milliseconds: 1)); // Simulate loading delay
    }
    return adsProvider.getSplashAd();
  }

  void _checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      print("user in splash screen $user");

      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const StartScreen(),
          ),
        );
      } else {
        try {
          String? token = await user.getIdToken();
          if (token != null) {
            UserProfile? profile = await _arcadiaCloud.fetchUserProfile(token);
            if (profile != null) {
              Provider.of<UserProfileProvider>(context, listen: false)
                  .setUserProfile(profile);

              if (profile.currentHubId != null &&
                  profile.currentHubId!.isNotEmpty) {
                _goToOperatorView(token, profile.currentHubId!);
                return;
              }

              if (!profile.profileComplete) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const UserProfileUpdateScreen()),
                );
              }
            }

            List<MissionDetails>? missions = await _fetchMissions(token);
            missions = MissionDetails.sortByCompletedAndTitle(missions ?? []);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(missions: missions ?? []),
              ),
            );
          }
        } catch (e) {
          // Handle errors (e.g., network issues, token retrieval issues)
          print('Error fetching user profile or missions: $e');
        }
      }
    }, onError: (error) {
      // Handle errors in the auth state changes listener
      print('Error listening to auth state changes: $error');
    });
  }

  Future<List<MissionDetails>?> _fetchMissions(String token) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken();
      if (token == null) return null;

      // Get the user's local datetime
      final userLocalDatetime = DateTime.now().toIso8601String();

      // Get the user's timezone name (using intl)
      // final userTimezone = DateFormat('z').format(DateTime.now());
      const userTimezone = "EST";
      return await _arcadiaCloud.fetchArcadiaMissions(
          token, userLocalDatetime, userTimezone);
    } catch (e) {
      // Handle network or token retrieval errors
      print('Error fetching missions: $e');
      return null;
    }
  }

  Future<void> _recordAdView(AdsDetails ad) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null) return;

    _arcadiaCloud.recordAdView(
        ViewType.splash.toString().split('.').last, ad.partner, ad.id, token);
  }

  Future<void> _recordAdClick(AdsDetails ad) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null) return;

    _arcadiaCloud.recordAdView(
        ViewType.splash.toString().split('.').last, ad.partner, ad.id, token);

    launchURL(Uri.parse(ad.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // CachedNetworkImage taking up 100% of the screen while fitting based on aspect ratio
          FutureBuilder<AdsDetails>(
            future: _splashAdFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error loading ad',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasData) {
                final ad = snapshot.data!;

                // Record the ad view
                _recordAdView(ad);

                return Center(
                  child: Transform.translate(
                    offset: const Offset(0, -20), // Move 10 pixels up
                    child: FractionallySizedBox(
                      widthFactor: 1.0, // 100% of the screen width
                      heightFactor: 1.0, // 100% of the screen height
                      child: GestureDetector(
                        onTap: () {
                          //_recordAdClick(ad);
                        },
                        child: CachedNetworkImage(
                          imageUrl: ad.image,
                          fit: BoxFit
                              .contain, // Fit the image within the screen while preserving aspect ratio
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error)),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'No ad available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/arcadia_splash_portrait.png', // Replace with your image asset path
                width: MediaQuery.of(context)
                    .size
                    .width, // Full screen width on non-tablets
                fit: BoxFit.cover,
              )),

          // Optional: Loading indicator or other content
          if (showIndicator)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _goToOperatorView(String token, String hubId) async {
    Hub? hub = await _arcadiaCloud.getHubDetails(hubId, token);
    if (hub != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => GameActivityView(
                  hubId: hubId,
                  hubDetails: hub,
                )),
      );
    } else {
      return;
    }
  }
}
