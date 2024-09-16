import 'package:arcadia_mobile/src/tools/slides.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/create_account_view.dart';
import '../auth/login_view.dart';

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
            _buildLogo(context),
            const Spacer(),
            _buildLoginButton(context),
            const SizedBox(height: 24),
            _buildCreateAccountButton(context),
            const SizedBox(height: 24),
            _buildPurchaseTicketsButton(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double logoSize = constraints.maxWidth * 0.9;
        if (constraints.maxWidth > 600) {
          logoSize = constraints.maxWidth * 0.7;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: logoSize,
          ),
          child: Image.asset(
            'assets/2024_Logo-B.png',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 368),
      child: ElevatedButton(
        onPressed: () =>
            navigateWithSlideRightTransition(context, const LoginScreen()),
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
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 368),
      child: OutlinedButton(
        key: const ValueKey('createAccountButtonKey'),
        onPressed: () => navigateWithSlideRightTransition(
            context, const CreateAccountView()),
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
    );
  }

  Widget _buildPurchaseTicketsButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 368),
      child: OutlinedButton(
        onPressed: () => _launchUrl('https://prticket.sale/ARCADIA'),
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
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    // Implement a dialog to show the error to the user
  }
}
