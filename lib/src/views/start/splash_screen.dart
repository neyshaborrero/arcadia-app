import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
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
        UserProfile? profile =
            token != null ? await _arcadiaCloud.fetchUserProfile(token) : null;

        if (profile != null) {
          Provider.of<UserProfileProvider>(context, listen: false)
              .setUserProfile(profile);
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
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
