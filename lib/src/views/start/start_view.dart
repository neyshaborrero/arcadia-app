import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/create_account_view.dart';
import '../auth/login_view.dart';
import '../../routes/slide_right_route.dart';
import '../../routes/slide_up_route.dart';

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
                key: const ValueKey('createAccountButtonKey'),
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
                  _launchUrl();
                  //_navigateUpWithSlideTransition(context, const TicketTiers());
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

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse('https://prticket.sale/ARCADIA'),
        mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch https://prticket.sale/ARCADIA');
    }
  }

  // Function to navigate with the slide transition
  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideRightRoute(page: page));
  }

  // Function to navigate with the slide transition
  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
