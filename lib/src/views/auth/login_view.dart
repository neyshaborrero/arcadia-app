import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/views/auth/forget_password.dart';
import 'package:arcadia_mobile/src/views/start/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../auth/create_account_view.dart';
import '../../routes/slide_right_route.dart';
import '../../routes/slide_up_route.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _passwordVisible = false;
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
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
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        String? token = await user.getIdToken();
        print(token);
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
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'The user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email and password. Please try again.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Plase try again later.';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print(e);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0).add(
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
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
              decoration: InputDecoration(
                labelText: 'Password',
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
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _navigateWithSlideTransition(
                  context, const ForgetPasswordScreen());
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
                            builder: (context) =>
                                const CreateAccountView()), // Replace with your sign-up screen widget
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
