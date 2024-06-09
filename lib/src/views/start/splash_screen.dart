import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/providers/change_notifier.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/views/start/start_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_view.dart'; // Import your Home screen

class SplashScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  const SplashScreen({super.key, required this.firebaseService});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    _arcadiaCloud = ArcadiaCloud(widget.firebaseService);
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return; //
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                StartScreen(firebaseService: widget.firebaseService),
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
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    firebaseService: widget.firebaseService,
                  )),
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
