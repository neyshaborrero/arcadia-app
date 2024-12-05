// Widget Function for Circle Avatar
import 'package:arcadia_mobile/src/components/gradient_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  final double avatarRadius;
  final String profileImageUrl;
  final Animation<double>? animation;

  const UserAvatarWidget({
    super.key,
    required this.avatarRadius,
    required this.profileImageUrl,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    if (animation != null) {
      return CustomPaint(
        painter: GradientBorderPainter(
          animation: animation!, // Pass the animation controller
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(8), // Adjust padding for border thickness
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
                        : const AssetImage('assets/hambopr.jpg')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8), // Adjust padding for border thickness
        child: CircleAvatar(
          radius: 73,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 70,
            backgroundImage: profileImageUrl.isNotEmpty
                ? CachedNetworkImageProvider(profileImageUrl)
                : const AssetImage('assets/hambopr.jpg') as ImageProvider,
          ),
        ),
      );
    }
  }
}
