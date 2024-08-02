import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/prizes_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/views/start/error_view.dart';
import 'package:arcadia_mobile/src/views/start/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/notifiers/change_notifier.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseService = FirebaseService.createInstance();
  bool initialized = await firebaseService.initialize();
  List<AdsDetails> splashAd = await loadSplashAds(initialized, firebaseService);

  // Initialize Firebase Performance
  FirebasePerformance performance = FirebasePerformance.instance;

  // Start screen trace
  Trace screenTrace = performance.newTrace('main_screen_trace');
  await screenTrace.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClickedState()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserActivityProvider()),
        ChangeNotifierProvider(create: (_) => AdsDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PrizesChangeProvider()),
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
    ),
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
      theme: _buildThemeData(),
      debugShowCheckedModeBanner: false,
      home: initialized ? const SplashScreen() : const ErrorScreen(),
    );
  }
}

ThemeData _buildThemeData() {
  return ThemeData(
    textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700)),
    scaffoldBackgroundColor: const Color(0xFF000000),
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFD20E0D),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey), // border color when focused
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFD20E0D)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF313131)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight
              .w400 // Set font size for selected tab labels // and also set weight, etc., as needed
          ),
      // Style for the tab text when unselected.
      unselectedLabelStyle: TextStyle(
        fontSize: 20.0, // Set font size for unselected tab labels
      ),
      // Color for the tab text and icons when selected.
      labelColor: Color(0xFFD20E0D),
      // Color for the indicator beneath the selected tab.
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Color(0xFFD20E0D),
              width: 2.0 // Border color Indicator thickness
              ),
        ),
      ),
    ),
  );
}
