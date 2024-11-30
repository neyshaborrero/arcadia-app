import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/db_listener_service.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/global_db_listener.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/prizes_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/survey_vote_status_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/views/onboarding/onboarding_manager.dart';
import 'package:arcadia_mobile/src/views/onboarding/onboarding_screen.dart';
import 'package:arcadia_mobile/src/views/start/error_view.dart';
import 'package:arcadia_mobile/src/views/start/splash_screen.dart';
import 'package:arcadia_mobile/src/views/start/update_app_view.dart';
import 'package:arcadia_mobile/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/notifiers/change_notifier.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseService = FirebaseService.createInstance();
  bool initialized = await firebaseService.initialize();
  List<AdsDetails> splashAd = await loadSplashAds(initialized, firebaseService);

  await DefaultCacheManager().emptyCache();

  //Clear the onboarding preference
  // final onboardingManager = OnboardingManager();
  // await onboardingManager.clearOnboardingSeenPreference();

  // Initialize Firebase Performance
  FirebasePerformance performance = FirebasePerformance.instance;

  // Start screen trace
  Trace screenTrace = performance.newTrace('main_screen_trace');
  await screenTrace.start();

  // Perform the version check
  bool isLatestVersion = await firebaseService.checkForUpdate();
  if (!isLatestVersion) {
    runApp(const UpdateRequiredApp());
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClickedState()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserActivityProvider()),
        ChangeNotifierProvider(create: (_) => AdsDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PrizesChangeProvider()),
        ChangeNotifierProvider(create: (_) => VoteStatusNotifier()),
        ChangeNotifierProvider(
            create: (_) =>
                DatabaseListenerService(firebaseService: firebaseService)),
        Provider<FirebaseService>.value(value: firebaseService),
      ],
      child: MyApp(
          initialized: initialized, ads: splashAd, screenTrace: screenTrace),
    ),
  );
}

Future<List<AdsDetails>> loadSplashAds(
    bool initialized, FirebaseService firebaseService) async {
  if (!initialized) {
    return defaultAds();
  }

  final arcadiaCloud = ArcadiaCloud(firebaseService);
  List<AdsDetails> adsList = await arcadiaCloud.fetchAds();

  if (adsList.isEmpty) {
    return defaultAds();
  }

  return adsList;
}

List<AdsDetails> defaultAds() {
  return [
    AdsDetails(
        tier: "legendary",
        image:
            "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2F2024_Logo-B.png?alt=media&token=fe68c904-1ae3-477e-956f-4f5655c44888",
        url: "https://www.yosoyungamer.com/arcadia-battle-royale-2024/",
        partner: "ysug",
        id: '0000000'),
  ];
}

class MyApp extends StatelessWidget {
  final bool initialized;
  final List<AdsDetails> ads;
  final Trace screenTrace;

  const MyApp(
      {super.key,
      required this.initialized,
      required this.ads,
      required this.screenTrace});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdsDetailsProvider>(context, listen: false)
          .addAllAdsDetails(ads);
      // Stop screen trace after the first frame is rendered
      screenTrace.stop();
    });

    return MaterialApp(
        title: 'Arcadia Battle Royale 2024',
        theme: _buildThemeData(context),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
            future: OnboardingManager().hasSeenOnboarding(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              bool hasSeenOnboarding = snapshot.data ?? false;

              return hasSeenOnboarding
                  ? initialized
                      ? SplashScreen()
                      : ErrorScreen()
                  : OnboardingScreen(
                      onFinish: () {
                        // Rebuild to display the splash screen after onboarding
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                initialized ? SplashScreen() : ErrorScreen(),
                          ),
                        );
                      },
                    );
            }));
  }
}

ThemeData _buildThemeData(BuildContext context) {
  // Determine if the device is a tablet based on screen width
  final double screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth >= 600;
  final bool isLargePhone = screenWidth >= 380 && screenWidth < 600;
  // final bool isSmallPhone = screenWidth < 380;

  double titleFontSize;
  double labelSmallFontSize;
  double labelMediumFontSize;
  double labelLargeFontSize;

  if (isTablet) {
    titleFontSize = 26.0;
    labelSmallFontSize = 16.0;
    labelMediumFontSize = 18.0;
    labelLargeFontSize = 20.0;
  } else if (isLargePhone) {
    titleFontSize = 22.0;
    labelSmallFontSize = 14.0;
    labelMediumFontSize = 16.0;
    labelLargeFontSize = 18.0;
  } else {
    titleFontSize = 20.0;
    labelSmallFontSize = 12.0;
    labelMediumFontSize = 14.0;
    labelLargeFontSize = 16.0;
  }

  return buildThemeData(context);
}
