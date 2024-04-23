import 'package:arcadia_mobile/src/views/auth/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../routes/slide_right_route.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Adjust the color as needed
        title: const Text(
          'Forgot password?',
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
          const SizedBox(height: 75),
          const Text(
            'Please enter the email address associated with the account',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 24),
          // Email TextField
          TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
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
          ElevatedButton(
            onPressed: () {
              _navigateWithSlideTransition(
                  context, const ResetPasswordScreen());
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text(
                'Send Link',
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
                  text: "Remember password? ",
                ),
                TextSpan(
                  text: 'Log in',
                  style: const TextStyle(
                    color: Color(0xFFD20E0D), // text color for "Sign Up"
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pop(context);
                    },
                ),
              ],
            ),
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
