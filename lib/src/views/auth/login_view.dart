import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/views/auth/forget_password.dart';
import 'package:arcadia_mobile/src/views/start/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../auth/create_account_view.dart';
import '../../routes/slide_right_route.dart';
import '../../routes/slide_up_route.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const LoginScreen({super.key, required this.firebaseService});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: "neysha.borrero@gmail.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "mononoke");
  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _arcadiaCloud = ArcadiaCloud(widget.firebaseService);
  }

  Future<void> _loginUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You wont be able to get in without email and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _arcadiaCloud.loginUser(email, password);

      if (response['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('An unexpected error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Adjust the color as needed
        title: const Text(
          'Log In',
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
          // Password TextField
          TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                fillColor: Color(0xFF2C2B2B), // Use appropriate color
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
                suffixIcon: Icon(Icons.visibility_off), // Change as needed
              ),
              obscureText: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              )),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _navigateWithSlideTransition(
                  context,
                  ForgetPasswordScreen(
                    firebaseService: widget.firebaseService,
                  ));
            },
            child: const Text(
              'Forgot password?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _loginUser,
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
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Colors.white, fontSize: 16 // default text color
                  ),
              children: <TextSpan>[
                const TextSpan(
                  text: "Don't have an account? ",
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: const TextStyle(
                    color: Color(0xFFD20E0D), // text color for "Sign Up"
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateAccountView(
                                  firebaseService: widget.firebaseService,
                                )), // Replace with your sign-up screen widget
                      );
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

  // Function to navigate with the slide transition
  void _navigateWithSlideUpTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
