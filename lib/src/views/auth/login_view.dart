import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Adjust the color as needed
        title: const Text('Log In'),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email TextField
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                fillColor: Colors.grey, // Use appropriate color
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Password TextField
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                fillColor: Colors.grey, // Use appropriate color
                filled: true,
                suffixIcon: Icon(Icons.visibility_off), // Change as needed
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement forgot password functionality
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement login functionality
              },
              child: const Text('Log in'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to Sign Up screen
              },
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyle(color: Colors.grey[600]), // Use appropriate color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
