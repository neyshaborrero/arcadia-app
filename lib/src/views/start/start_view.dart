import 'package:flutter/material.dart';
import '../auth/create_account_view.dart';
import '../auth/login_view.dart';
import '../tickets/ticket_tiers_view.dart';
import '../../routes/slide_right_route.dart';
import '../../routes/slide_up_route.dart';
// import 'package:url_launcher/url_launcher.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 150,
                maxWidth: 368,
              ),
              child: Image.asset(
                'assets/2024_Logo-B.png',
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 368),
              child: ElevatedButton(
                onPressed: () {
                  _navigateWithSlideTransition(context, const LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 368),
              child: OutlinedButton(
                onPressed: () {
                  _navigateWithSlideTransition(
                      context, const CreateAccountView());
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 368),
              child: OutlinedButton(
                onPressed: () {
                  _navigateUpWithSlideTransition(context, const TicketTiers());
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Text(
                    'Purchase Tickets',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Future<void> _launchURL() async {
  //   final Uri url = Uri.parse('https://arcadia-example-app.bubbleapps.io/version-test');
  //   // if (await canLaunchUrl(url)) {
  //   //   await launchUrl(url, mode: LaunchMode.externalApplication);
  //   // } else {
  //   //   throw 'Could not launch $url';
  //   // }
  // }

  // Function to navigate with the slide transition
  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideRightRoute(page: page));
  }

  // Function to navigate with the slide transition
  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
