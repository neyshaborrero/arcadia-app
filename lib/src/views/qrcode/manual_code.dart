import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManualQRCodeView extends StatefulWidget {
  const ManualQRCodeView({super.key});

  @override
  _ManualQRCodeViewState createState() => _ManualQRCodeViewState();
}

class _ManualQRCodeViewState extends State<ManualQRCodeView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
  }

  Future<void> _validateQRCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a QR Code to earn tokens.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? token = await user.getIdToken();
        if (token != null) {
          final UserActivity? response =
              await _arcadiaCloud.validateQRCode(code, token);

          if (response != null) {
            final userProfileProvider =
                Provider.of<UserProfileProvider>(context, listen: false);
            userProfileProvider.updateTokens(response.value);
            Provider.of<UserActivityProvider>(context, listen: false)
                .addUserActivity(response);
            Provider.of<ClickedState>(context, listen: false)
                .toggleClicked(response.qrcode);

            showActivityDialog(
                context,
                response.id,
                true,
                true,
                response.title,
                response.description,
                response.imageComplete,
                response.imageComplete);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'We couldnt validate the QR Code, try another one.')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('We couldnt validate the QR Code, try another one.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 50),
      Text('Enter the Code manually',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(
        height: 16,
      ),
      TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'QR Code',
            contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(10), // CSS border-radius: 10px 0px 0px 0px;
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              borderSide: BorderSide.none, // CSS opacity: 0; implies no border
            ),
            fillColor: Color(0xFF2C2B2B), // Use appropriate color
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          )),
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _validateQRCode,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ),
        ),
      ),
    ]);
  }
}
