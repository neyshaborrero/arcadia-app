import 'package:arcadia_mobile/services/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DatabaseListenerService with ChangeNotifier {
  final FirebaseService firebaseService;
  String _currentMatchValue = '';
  bool _secondListenerValue = false;
  static bool hasNavigated = false; // Static variable to track navigation

  String get currentMatchValue => _currentMatchValue;
  bool get secondListenerValue => _secondListenerValue;

  DatabaseListenerService({required this.firebaseService});

  Future<void> initializeListener() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No authenticated user found.");
      return;
    }

    final userId = user.uid; // Get the UID directly from FirebaseAuth

    // Monitor database connection status
    firebaseService.monitorConnectionStatus();

    // Listen to changes in the specific user path
    final path = '/users/$userId/currentMatch';
    firebaseService.listenToDatabase(path, (event) {
      final newValue = event.snapshot.value as String?;
      if (newValue != null && newValue != _currentMatchValue) {
        _currentMatchValue = newValue;
        print("New value detected: $_currentMatchValue");
        notifyListeners();
      }
    });

    // Second Listener: Listen to another path (e.g., 'preferences')
    final secondPath = '/users/$userId/refresh';
    firebaseService.listenToDatabase(secondPath, (event) {
      final newValue = event.snapshot.value as bool;
      if (newValue == true && newValue != _secondListenerValue) {
        _secondListenerValue = newValue;
        print("New value detected: $_secondListenerValue");
        notifyListeners();
      }
    });
  }

  void reset() {
    _currentMatchValue = '';
    _secondListenerValue = false;
    notifyListeners();
    hasNavigated = false;
  }
}
