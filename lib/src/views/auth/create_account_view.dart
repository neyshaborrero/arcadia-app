import 'package:flutter/material.dart';
import '../profile/update_profile.dart';
import '../../routes/slide_right_route.dart';
import 'package:flutter/gestures.dart';
import '../auth/login_view.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  _CreateAccountViewState createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final TextEditingController _ticketCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
        backgroundColor: Colors.black, // Adjust the color as needed
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 32),

          TextFormField(
              controller: _ticketCodeController,
              decoration: const InputDecoration(
                labelText: 'Ticket Code *',
                contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        10), // CSS border-radius: 10px 0px 0px 0px;
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  borderSide:
                      BorderSide.none, // CSS opacity: 0; implies no border
                ),
                fillColor: Color(0xFF2C2B2B), // Use appropriate color
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              )),
          const SizedBox(height: 50),

          // Email TextField
          TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email address *',
                contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        10), // CSS border-radius: 10px 0px 0px 0px;
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  borderSide:
                      BorderSide.none, // CSS opacity: 0; implies no border
                ),
                fillColor: Color(0xFF2C2B2B), // Use appropriate color
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              )),
          const SizedBox(height: 50),
          // Password TextField
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
                contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                fillColor: const Color(0xFF2C2B2B), // Use appropriate color
                filled: true,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        10), // CSS border-radius: 10px 0px 0px 0px;
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  borderSide:
                      BorderSide.none, // CSS opacity: 0; implies no border
                ),
              ),
              obscureText: !_passwordVisible,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              )),
          const SizedBox(height: 50),
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
                contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                fillColor: const Color(0xFF2C2B2B), // Use appropriate color
                filled: true,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        10), // CSS border-radius: 10px 0px 0px 0px;
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  borderSide:
                      BorderSide.none, // CSS opacity: 0; implies no border
                ),
              ),
              obscureText: !_passwordVisible,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              )),

          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              _navigateWithSlideTransition(
                  context, const UserProfileUpdateScreen());
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text(
                'Next',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Colors.white, fontSize: 16 // default text color
                  ),
              children: <TextSpan>[
                const TextSpan(
                  text: "Already have an account? ",
                ),
                TextSpan(
                  text: 'Log in',
                  style: const TextStyle(
                    color: Color(0xFFD20E0D), // text color for "Sign Up"
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen()), // Replace with your sign-up screen widget
                      );
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            'By creating an account you Agree to our Terms & Conditions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ]),
      ),
    );
  }

  // Function to navigate with the slide transition
  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideRightRoute(page: page));
  }
}
