import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/prizes_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/survey_vote_status_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/views/start/error_view.dart';
import 'package:arcadia_mobile/src/views/start/splash_screen.dart';
import 'package:arcadia_mobile/src/views/start/update_app_view.dart';
import 'package:arcadia_mobile/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'firebase_options_dev.dart';
import 'src/notifiers/change_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check the value of FLAVOR passed via --dart-define to determine the environment.
  const flavor = String.fromEnvironment('FLAVOR');
  FirebaseOptions firebaseOptions;

  if (flavor == 'dev') {
    // Use development Firebase configuration
    firebaseOptions = DefaultFirebaseOptionsDev.currentPlatform;
  } else {
    // Use production Firebase configuration (default)
    firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  }

  await Firebase.initializeApp(options: firebaseOptions);

  final firebaseService = FirebaseService.createInstance();
  bool initialized = await firebaseService.initialize();
  List<AdsDetails> splashAd = await loadSplashAds(initialized, firebaseService);

  // Initialize Firebase Performance
  FirebasePerformance performance = FirebasePerformance.instance;

  // Start screen trace
  Trace screenTrace = performance.newTrace('main_screen_trace');
  await screenTrace.start();

  // Perform the version check
  print("Are we in release mode? $kReleaseMode");
  if (kReleaseMode) {
    bool isLatestVersion = await firebaseService.checkForUpdate();
    if (!isLatestVersion) {
      runApp(const UpdateRequiredApp());
      return;
    }
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
      home: initialized ? const SplashScreen() : const ErrorScreen(),
    );
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
