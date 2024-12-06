import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/db_listener_service.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorScreen extends StatefulWidget {
  final bool isWifi;

  const ErrorScreen({super.key, required this.isWifi});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _isLoading = false;
  String? _message;
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
  }

  Future<void> _fetchMatchDetails() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _message = "User not authenticated";
        });
        return;
      }

      final token = await user.getIdToken();
      if (token == null) {
        setState(() {
          _message = "Unable to retrieve token";
        });
        return;
      }

      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);

      final userprofile = userProfileProvider.userProfile;

      if (userprofile != null) {
        final currentMatchId =
            Provider.of<DatabaseListenerService>(context, listen: false)
                .currentMatchValue;

        final match = await _arcadiaCloud.getMatch(
            userprofile.playerCurrentHub, currentMatchId, token);

        if (match != null) {
          setState(() {
            _message = "Match details fetched successfully!";
          });
        } else {
          setState(() {
            _message = "No match details found.";
          });
        }
      } else {
        setState(() {
          _message = "User profile is unavailable.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error fetching match details: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 150,
                maxWidth: 368,
              ),
              child: Image.asset(
                !widget.isWifi ? 'assets/no_connection.png' : 'assets/wifi.png',
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            if (!widget.isWifi)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Could not load The Arcadia Battle Royale App. Please make sure you have internet connection.',
                  style: TextStyle(
                    color: Colors.black, // Text color set to black
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (widget.isWifi)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Please connect to the event's Wi-Fi.",
                  style: TextStyle(
                    color: Colors.black, // Text color set to black
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchMatchDetails,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    )
                  : const Text("Retry"),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _message!,
                  style: const TextStyle(
                    color: Colors.red, // Error or feedback text in red
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
