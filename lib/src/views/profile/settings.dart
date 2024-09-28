import 'dart:io';

import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/src/components/delete_account.dart';
import 'package:arcadia_mobile/src/components/picture_upload_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/views/start/start_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  XFile? _imageFile; // Used to hold the image file
  bool _notificationsEnabled = false;
  bool _locationEnabled = false;
  late final ArcadiaCloud _arcadiaCloud;
  late final FirebaseService _firebaseService;
  late final String userToken;
  late final User? user;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _firebaseService = Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(_firebaseService);
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userToken = (await user?.getIdToken())!;
    }

    _notificationsEnabled = await _firebaseService.isNotificationEnabled();
    _locationEnabled = await Geolocator.isLocationServiceEnabled();

    setState(() {});
  }

  Future<void> _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      setState(() {
        _notificationsEnabled = true;
      });
    } else {
      setState(() {
        _notificationsEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'To enable notifications go to your settings to start receiving latest Arcadia notifications.')),
      );
    }
  }

  void _toggleNotifications(bool value) {
    if (value) {
      _requestNotificationPermissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'To disable notifications go to your settings to stop receiving latest Arcadia notifications.')),
      );
    }
  }

  void _toggleLocation(bool value) {
    if (value) {
      //_requestNotificationPermissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'To disable location go to your settings to stop sharing your location in Arcadia app.')),
      );
    }
  }

  // Method to show the bottom sheet menu
  void _showImagePickerMenu(BuildContext context) {
    showUploadPictureDialog(context);
  }

  // Method to log out the user
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Provider.of<UserProfileProvider>(context, listen: false).clearUserProfile();
    Provider.of<UserActivityProvider>(context, listen: false)
        .clearUserActivities();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StartScreen()),
        ModalRoute.withName('/') // Replace with your sign-up screen widget
        ); // Redirect to the login screen
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Assuming dark theme from screenshot
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            Column(children: [
              Stack(
                alignment:
                    Alignment.center, // Aligns the '+' icon over the avatar

                children: [
                  Container(
                    padding: const EdgeInsets.all(
                        2), // This value is the width of the border
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 4.0, // Border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 70, // Adjust the radius to your preference
                      backgroundColor: const Color(
                          0xFF2C2B2B), // Background color for the avatar
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: _imageFile == null &&
                                      userProfile != null &&
                                      userProfile.profileImageUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      userProfile.profileImageUrl)
                                  : _imageFile != null
                                      ? FileImage(File(_imageFile!.path))
                                      : const AssetImage('assets/hambopr.jpg')
                                          as ImageProvider,
                              fit: BoxFit
                                  .cover, // Fills the space, you could use BoxFit.contain to maintain aspect ratio
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // Adjust the position as per your design
                    right: 0, // Adjust the position as per your design
                    child: GestureDetector(
                      onTap: () => _showImagePickerMenu(context),
                      child: Container(
                        width: 46.0,
                        height: 46.0,
                        decoration: const BoxDecoration(
                          color: Color(
                              0xFFD20E0D), // Background color of the '+' icon circle
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ]),
            Divider(color: Colors.grey[800]),
            ListTile(
              title: const Text('Notifications',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              title:
                  const Text('Location', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: _locationEnabled,
                onChanged: _toggleLocation,
                activeColor: Colors.green,
              ),
            ),
            _buildListTile('Privacy Policy', context,
                'https://thorn-freesia-17c.notion.site/Privacy-Policy-2301f06eb14c4753b76e4ee23b15ff35'),
            _buildListTile('Terms of Service', context,
                'https://thorn-freesia-17c.notion.site/Terms-of-Service-e2ada600ffae48828b7f1c2aa4862443'),
            _buildListTile('About', context,
                'https://www.yosoyungamer.com/arcadia-battle-royale-2024/'),
            _buildListTile('Contact', context, 'https://wa.me/17873207511'),
            _buildListTile(
                'Purchase Tickets', context, 'https://prticket.sale/ARCADIA'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () {
                      _logout();
                    },
                    child: const Text('Log Out'),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
                child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 16),
                children: [
                  const TextSpan(text: ""),
                  TextSpan(
                    text: 'Delete Account',
                    style: const TextStyle(
                        color: Color(0xFFD20E0D), fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (userProfile != null) {
                          showDeleteAccount(
                                  context,
                                  userToken,
                                  'Delete Account',
                                  'Thinking about pulling the plug? Just hit "Yes" if you would like all your personal data be erased from the Arcadia Battle Royale app.',
                                  userProfile.tokens,
                                  _arcadiaCloud)
                              .then((result) async {
                            if (result == true) {
                              await FirebaseAuth.instance.signOut();

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const StartScreen()),
                                (Route<dynamic> route) =>
                                    false, // Remove all previous routes
                              );
                            }
                          });
                        }
                      },
                  ),
                ],
              ),
            )),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  ListTile _buildListTile(String title, BuildContext context, String url) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
      onTap: () {
        _launchUrl(url);
        // Implement navigation or functionality for each settings option
      },
    );
  }
}
