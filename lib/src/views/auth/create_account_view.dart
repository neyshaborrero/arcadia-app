import 'package:flutter/material.dart';
import '../profile/update_profile.dart';
import '../../routes/slide_right_route.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  _CreateAccountViewState createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final TextEditingController _ticketCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.black, // Adjust the color as needed
      ),
      body: Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _ticketCodeController,
              decoration: const InputDecoration(
                labelText: 'Ticket Code *',
                hintText: 'Ticket Code',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                hintText: 'example@gmail.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Create a password *',
                hintText: 'must be 8 characters',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm password *',
                hintText: 'repeat password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                    _navigateWithSlideTransition(context, const UserProfileUpdateScreen());
              },
              child: const Text('Next'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement navigation to login
              },
              child: const Text('Already have an account? Log in'),
            ),
            const Spacer(), // Use spacer at the end to push everything up
            const Text(
              'By creating an account you Agree to our Terms & Conditions.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Function to navigate with the slide transition
  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideRightRoute(page: page));
  }

}
