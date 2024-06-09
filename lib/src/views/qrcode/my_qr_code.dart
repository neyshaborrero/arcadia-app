import 'package:arcadia_mobile/src/providers/change_notifier.dart';
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
    return Column(children: [
      const SizedBox(
        height: 38,
      ),
      Container(
        padding:
            const EdgeInsets.all(2), // This value is the width of the border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white, // Border color
            width: 4.0, // Border width
          ),
        ),
        child: CircleAvatar(
          radius: 95, // Adjust the radius to your preference
          backgroundColor:
              const Color(0xFF2C2B2B), // Background color for the avatar
          child: FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: userProfile != null &&
                          userProfile.profileImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(userProfile.profileImageUrl)
                      : const AssetImage('assets/hambopr.jpg')
                          as ImageProvider, // Fallback to default asset image
                  fit: BoxFit
                      .cover, // Fills the space, you could use BoxFit.contain to maintain aspect ratio
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 14,
      ),
      Text(
        userProfile != null && userProfile.profileImageUrl.isNotEmpty
            ? userProfile.gamertag
            : 'hambopr',
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight:
              FontWeight.w700, // This corresponds to font-weight: 700 in CSS
        ),
      ),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 31),
          child: Container(
            height: 2, // Adjust the height according to your needs
            width: MediaQuery.of(context).size.width, // Width of the line
            color: Colors.white, // Color of the line
          )),
      Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10), // Border radius
        ),
        child: QrImageView(
          data: '123455',
          size: 206,
          embeddedImage: const AssetImage('assets/ysug.png'),
          // You can include embeddedImageStyle Property if you
          //wanna embed an image from your Asset folder
          embeddedImageStyle: const QrEmbeddedImageStyle(
            size: Size(
              54,
              56,
            ),
          ),
        ),
      ),
      const Text(
        '35624527',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight:
              FontWeight.w700, // This corresponds to font-weight: 700 in CSS
        ),
      ),
    ]);
  }
}
