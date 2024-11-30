import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ffi' as ffi; // Prefix dart:ffi
import 'dart:ui'; // Keep dart:ui without a prefix

class PlayerQRCodeWidget extends StatelessWidget {
  const PlayerQRCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    final screenHeight = MediaQuery.of(context).size.height;

    // Generate the referral deep link using the user's ID
    final deepLink =
        'https://arcadia-deeplink.web.app?userqr=${userProfile!.qrcode}'; // Change this URL based on your server setup

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatarWidget(
                    avatarRadius: screenHeight / 10,
                    profileImageUrl: userProfile.profileImageUrl,
                  ),
                  ProfileIconsWidget(userProfile: userProfile),
                ],
              ),
              const SizedBox(height: 20),
              QRCodeWidget(
                data: deepLink,
                qrcodeText: userProfile.qrcode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Function for Circle Avatar
class UserAvatarWidget extends StatelessWidget {
  final double avatarRadius;
  final String profileImageUrl;

  const UserAvatarWidget({
    super.key,
    required this.avatarRadius,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                image: profileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(profileImageUrl)
                    : const AssetImage('assets/hambopr.jpg') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileIconsWidget extends StatelessWidget {
  final UserProfile? userProfile;

  const ProfileIconsWidget({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconColumn(
                context: context,
                imagePath: 'assets/level-shield.png',
                badgeText: '${userProfile?.playerLevel ?? 0}',
                labelText: "Level",
                paddingTop: 2.0),
            const SizedBox(width: 20),
            _buildIconColumn(
                context: context,
                imagePath: 'assets/award.png',
                badgeText: '${userProfile?.prestigeTotal ?? 0}',
                labelText: "Prestige",
                paddingTop: 0.0),
          ],
        ),
        const SizedBox(height: 16),
        //_buildXpTokensContainer(userProfile, context),
        // _buildXpOrTokensColumn(
        //   context: context,
        //   label: " Win Streak",
        //   value: '100',
        //   assetPath: 'assets/fire.png',
        // )

        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset(
                        'assets/fire.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  Text(
                    "${userProfile?.matchStreak ?? 0} Win Streak",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset(
                        'assets/ribbon.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Text(
                    "${userProfile?.xp ?? 0} XP",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              )
            ]),
      ],
    );
  }

  BoxDecoration _buildGradientBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD20E0D).withOpacity(0.85),
          const Color(0xFF020202).withOpacity(0.85),
        ],
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildCenterDivider() {
    return Container(
      height: 40, // Consistent height for the divider
      width: 2, // Thickness of the divider
      color: Colors.white.withOpacity(0.55),
    );
  }

  Widget _buildXpOrTokensColumn(
      {required BuildContext context,
      required String label,
      required String value,
      required String assetPath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Image.asset(assetPath, width: 55, height: 55, fit: BoxFit.cover),
            const SizedBox(width: 10),
            Row(children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 5),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ])
          ],
        ),
      ],
    );
  }

  Widget _buildXpTokensContainer(
      UserProfile? userProfile, BuildContext context) {
    return Stack(
      clipBehavior:
          Clip.none, // Allows the image to overflow outside the container
      children: [
        Container(
          constraints:
              const BoxConstraints(maxHeight: 100.0), // Consistent height
          padding: const EdgeInsets.all(20.0),
          decoration: _buildGradientBoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Ensures vertical alignment
            children: [
              _buildXpOrTokensColumn(
                context: context,
                label: 'XP',
                value: userProfile?.xp.toString() ?? '0',
                assetPath: 'assets/fire.png',
              ),
              _buildXpOrTokensColumn(
                context: context,
                label: '',
                value: userProfile?.tokens.toString() ?? '0',
                assetPath: 'assets/ribbon.png',
              ),
            ],
          ),
        ),
        Positioned(
            top: 5, // Adjust to position the image above the container
            left: 0,
            right: 0,
            child: Center(child: _buildCenterDivider())),
      ],
    );
  }

  Widget _buildIconColumn({
    required BuildContext context,
    required String imagePath,
    required String badgeText,
    required String labelText,
    required double paddingTop,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Image.asset(
              imagePath,
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
            Positioned(
              top: 5,
              right: 10,
              child: _buildTextBadge(badgeText, paddingTop),
            ),
          ],
        ),
        Text(labelText, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildTextBadge(String text, double top) {
    final double formattedPadding = text.length == 1 ? 7.0 : 5.0;

    return Container(
      padding: EdgeInsets.only(
        top: top,
        bottom: 0.0,
        left: 0.0,
        right: formattedPadding,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outline text
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5 // Width of the outline
                ..color = Colors.black, // Outline color
            ),
          ),
          // Filled white text
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Fill color
            ),
          ),
        ],
      ),
    );
  }
}

class QRCodeWidget extends StatelessWidget {
  final String data;
  final String qrcodeText;

  const QRCodeWidget({
    super.key,
    required this.data,
    required this.qrcodeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: QrImageView(
            data: data,
            size: 206,
            embeddedImage: const AssetImage('assets/arcadia_icon.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(54.0, 56.0),
            ),
            errorCorrectionLevel: QrErrorCorrectLevel.H,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          qrcodeText,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
