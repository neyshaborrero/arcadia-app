import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyQRCode extends StatefulWidget {
  const MyQRCode({super.key});

  @override
  _MyQRCodeState createState() => _MyQRCodeState();
}

class _MyQRCodeState extends State<MyQRCode> {
  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    final screenHeight = MediaQuery.of(context).size.height;

    // Generate the referral deep link using the user's ID
    final deepLink =
        'https://arcadia-deeplink.web.app?userqr=${userProfile!.qrcode}'; // Change this URL based on your server setup

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
                            image: userProfile.profileImageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    userProfile.profileImageUrl)
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
                  userProfile.gamertag.isNotEmpty
                      ? userProfile.gamertag
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
                  userProfile.qrcode,
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
