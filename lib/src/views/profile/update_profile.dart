import 'package:flutter/material.dart';


class UserProfileUpdateScreen extends StatefulWidget {
  const UserProfileUpdateScreen({super.key});

  @override
  _UserProfileUpdateScreenState createState() => _UserProfileUpdateScreenState();
}

class _UserProfileUpdateScreenState extends State<UserProfileUpdateScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _gamertagController = TextEditingController();
  String? _selectedGender;
  String? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Adjust to match your color
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.black, // Adjust to match your color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[800], // Adjust to match your color
              child: IconButton(
                icon: const Icon(Icons.add, size: 40),
                color: Colors.white,
                onPressed: () {
                  // TODO: Implement profile picture upload
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                fillColor: Colors.grey,
                filled: true,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gamertagController,
              decoration: const InputDecoration(
                labelText: 'Gamertag *',
                fillColor: Colors.grey,
                filled: true,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date of Birth *',
                fillColor: Colors.grey,
                filled: true,
              ),
              style: const TextStyle(color: Colors.white),
              // You can use a date picker input here
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Gender *',
                fillColor: Colors.grey,
                filled: true,
              ),
              value: _selectedGender,
              items: <String>['Male', 'Female', 'Other']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'User Type *',
                fillColor: Colors.grey,
                filled: true,
              ),
              value: _selectedUserType,
              items: <String>['Player', 'Coach', 'Spectator']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedUserType = newValue;
                });
              },
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Please verify your information carefully.\nOnce submitted, your details cannot be edited later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]), // Adjust to match your color
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement create account logic
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
