import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/views/profile/update_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/views/auth/forget_password.dart';
import 'package:arcadia_mobile/src/views/start/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../auth/create_account_view.dart';
import '../../routes/slide_right_route.dart';

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
    _arcadiaCloud =
        ArcadiaCloud(Provider.of<FirebaseService>(context, listen: false));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('You won\'t be able to get in without email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await _handleUserLogin(user);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _showSnackbar('An unexpected error occurred. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUserLogin(User user) async {
    try {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        final profile = await _arcadiaCloud.fetchUserProfile(token);
        if (profile != null) {
          Provider.of<UserProfileProvider>(context, listen: false)
              .setUserProfile(profile);
          if (!profile.profileComplete) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const UserProfileUpdateScreen()),
            );
            return;
          }
        }

        final missions = await _fetchMissions(token);
        if (missions != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomeScreen(missions: missions)));
        }
      } else {
        _showSnackbar('Invalid token. Please try again.');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      _showSnackbar('An error occurred while fetching user data.');
    }
  }

  Future<List<MissionDetails>?> _fetchMissions(String token) async {
    try {
      // Get the user's local datetime
      final userLocalDatetime = DateTime.now().toIso8601String();

      // Get the user's timezone name (using intl)
      // final userTimezone = DateFormat('z').format(DateTime.now());
      const userTimezone = 'EST';
      return await _arcadiaCloud.fetchArcadiaMissions(
          token, userLocalDatetime, userTimezone);
    } catch (e) {
      print('Error fetching missions: $e');
      return null;
    }
  }

  void _handleAuthException(FirebaseAuthException e) {
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
        errorMessage = 'An unexpected error occurred. Please try again later.';
        break;
    }
    _showSnackbar(errorMessage);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateWithSlideRightTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideRightRoute(page: page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Log In',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double widthFactor = constraints.maxWidth > 600 ? 0.7 : 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0).add(EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom)),
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 116),
                    _buildEmailTextField(),
                    const SizedBox(height: 50),
                    _buildPasswordTextField(),
                    const SizedBox(height: 8),
                    _buildForgotPasswordButton(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildSignUpText(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email address',
        contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        fillColor: Color(0xFF2C2B2B),
      ),
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon:
              Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        fillColor: const Color(0xFF2C2B2B),
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: !_passwordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () => _navigateWithSlideRightTransition(
          context, const ForgetPasswordScreen()),
      child: const Text('Forgot password?',
          style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _buildLoginButton() {
    return _isLoading
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
        : ElevatedButton(
            onPressed: _loginUser,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('Log in', style: TextStyle(fontSize: 18)),
            ),
          );
  }

  Widget _buildSignUpText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: [
          const TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
                color: Color(0xFFD20E0D), fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateAccountView()));
              },
          ),
        ],
      ),
    );
  }
}
