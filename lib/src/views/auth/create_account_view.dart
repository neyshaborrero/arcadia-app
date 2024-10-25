import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../profile/update_profile.dart';
import 'package:flutter/gestures.dart';
import '../auth/login_view.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  _CreateAccountViewState createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final ArcadiaCloud _arcadiaCloud;
  bool _passwordVisible = false;
  bool _isLoading = false;

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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackbar('You won\'t be able to get in without email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await _arcadiaCloud.checkPassword(email, password, confirmPassword);
      if (response['success']) {
        print("email $email");
        UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print("are we saving? ${userCredential.user}");

        User? user = userCredential.user;
        if (user != null) {
          String? token = await user.getIdToken();

          print("token USER $token");

          final response = await _arcadiaCloud.saveUserToDB(email, token);
          if (response['success']) {
            UserProfile? profile = token != null
                ? await _arcadiaCloud.fetchUserProfile(token)
                : null;
            if (profile != null) {
              final UserProfileProvider userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
              userProfileProvider.setUserProfile(profile);
              userProfileProvider.setToken(token);
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const UserProfileUpdateScreen()),
            );
          }
        } else {
          _handleErrors(response['errors']);
        }
      } else {
        _handleErrors(response['errors']);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _showSnackbar(
          'Oops, there\'s an error happening on our side. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleErrors(List<ErrorDetail> errors) {
    String errorMessage = errors.isNotEmpty
        ? errors.map((e) => e.message).join(', ')
        : 'An unknown error occurred';
    _showSnackbar(errorMessage);
  }

  void _handleAuthException(FirebaseAuthException e) {
    ErrorDetail errorDetail;
    switch (e.code) {
      case 'email-already-in-use':
        errorDetail = ErrorDetail(
            path: 'email',
            message: 'The email address is already in use by another account.');
        break;
      case 'invalid-email':
        errorDetail = ErrorDetail(
            path: 'email', message: 'The email address is not valid.');
        break;
      case 'operation-not-allowed':
        errorDetail = ErrorDetail(
            path: 'email', message: 'Email/password accounts are not enabled.');
        break;
      case 'weak-password':
        errorDetail =
            ErrorDetail(path: 'email', message: 'The password is too weak.');
        break;
      default:
        errorDetail = ErrorDetail(path: null, message: '$e');
        break;
    }
    _showSnackbar(errorDetail.message);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineSmall,
          //style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black,
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
                    const SizedBox(height: 32),
                    _buildEmailTextField(),
                    const SizedBox(height: 50),
                    _buildPasswordTextField(),
                    const SizedBox(height: 50),
                    _buildConfirmPasswordTextField(),
                    const SizedBox(height: 50),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                    _buildLoginText(),
                    const SizedBox(height: 50),
                    _buildTermsAndConditionsText(),
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
        labelText: 'Email address *',
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
        labelText: 'Create a password *',
        hintText:
            'Must be 8 characters long, contain at least 1 number and 1 special character',
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

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Confirm password *',
        hintText: 'Repeat password',
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

  Widget _buildSubmitButton() {
    return _isLoading
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
        : ElevatedButton(
            onPressed: _createUser,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('Next', style: TextStyle(fontSize: 18)),
            ),
          );
  }

  Widget _buildLoginText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: [
          const TextSpan(text: "Already have an account? "),
          TextSpan(
            text: 'Log in',
            style: const TextStyle(
                color: Color(0xFFD20E0D), fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditionsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: [
          const TextSpan(text: "By creating an account you agree to our "),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
                color: Color(0xFFD20E0D), fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchURL(Uri.parse(
                    'https://thorn-freesia-17c.notion.site/Terms-of-Service-e2ada600ffae48828b7f1c2aa4862443')); // Replace with your terms & conditions URL
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
