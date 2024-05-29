import 'package:arcadia_mobile/services/firebase.dart';
import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class ChangePasswordScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  const ChangePasswordScreen({super.key, required this.firebaseService});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final FirebaseService firebaseService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black, // Adjust the color as needed
        title: const Text(
          'Password Change',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 116),
          const Text(
            'Your password has been changed successfully',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginScreen(
                        firebaseService:
                            firebaseService)), // Replace with your sign-up screen widget
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text(
                'Log in',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
