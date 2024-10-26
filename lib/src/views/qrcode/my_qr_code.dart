import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyQRCode extends StatefulWidget {
  const MyQRCode({super.key});

  @override
  _MyQRCodeState createState() => _MyQRCodeState();
}

class _MyQRCodeState extends State<MyQRCode> {
  late final FirebaseService _firebaseService;
  late final ArcadiaCloud _arcadiaCloud;
  UserProfile? _userProfile;
  late final Timer? _timer;

  @override
  void initState() {
    super.initState();
    _firebaseService = Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(_firebaseService);
    _timer = Timer.periodic(
          Duration(seconds: 10),
          (Timer timer) async {
            final bool getUserResult = await getUser();

            if (getUserResult == false) {
              timer.cancel();
            }
          },
        );
  }

  Future<bool> getUser() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false;
    }

    final String? userToken = await currentUser.getIdToken();

    if (!(context.mounted) || userToken == null) {
      return false;
    }

    final UserProfile? userProfile = await _arcadiaCloud.fetchUserProfile(userToken);

    if (!mounted || !(context.mounted)) {
      return false;
    }

    setState(() {
      _userProfile = userProfile;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_userProfile == null) {
      return Center(
        child: Text("User not found..."),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;

    // Generate the referral deep link using the user's ID
    final deepLink =
        'https://arcadia-deeplink.web.app?userqr=${_userProfile!.qrcodeWithPepper}';
    // Change this URL based on your server setup

    // print("USER'S PROFILE IMAGE URL: ${_userProfile!.profileImageUrl}");
    // print("QR CODE WITH PEPPER: ${_userProfile!.qrcodeWithPepper}");

    // Determine the avatar radius based on screen size
    double avatarRadius;
    if (screenHeight > 800) {
      avatarRadius = screenHeight / 8; // Larger screens
    } else if (screenHeight > 600) {
      avatarRadius = screenHeight / 9; // Medium screens
    } else {
      avatarRadius = screenHeight / 10; // Smaller screens
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: const Color(0xFF2C2B2B),
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: _userProfile!.profileImageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    _userProfile!.profileImageUrl)
                                : const AssetImage('assets/hambopr.jpg')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _userProfile!.gamertag.isNotEmpty
                      ? _userProfile!.gamertag
                      : '[gamertag]',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 21, horizontal: 31),
                  child: Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: QrImageView(
                    //data: userProfile!.qrcode,
                    data: deepLink,
                    size: 206,
                    embeddedImage: const AssetImage('assets/arcadia_icon.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(54, 56),
                    ),
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
                Text(
                  _userProfile!.qrcode,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                    height:
                        100), // Spacer to prevent overlap with the bottom widget
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AdsCarouselComponent(
              viewType: ViewType.qrprofile,
            ),
          ),
        ],
      ),
    );
  }
}
