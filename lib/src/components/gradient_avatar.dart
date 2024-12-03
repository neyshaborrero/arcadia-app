import 'package:flutter/material.dart';
import 'dart:math';

class GradientBorderAvatar extends StatefulWidget {
  final String profileImageUrl;
  final double avatarRadius;

  const GradientBorderAvatar({
    Key? key,
    required this.profileImageUrl,
    this.avatarRadius = 50.0,
  }) : super(key: key);

  @override
  _GradientBorderAvatarState createState() => _GradientBorderAvatarState();
}

class _GradientBorderAvatarState extends State<GradientBorderAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Loop the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GradientBorderPainter(
        animation: _controller,
      ),
      child: Container(
        padding: const EdgeInsets.all(8), // Adjust padding for border thickness
        child: CircleAvatar(
          radius: widget.avatarRadius,
          backgroundColor: const Color(0xFF2C2B2B),
          child: FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: widget.profileImageUrl.isNotEmpty
                      ? NetworkImage(widget.profileImageUrl)
                      : const AssetImage('assets/hambopr.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final Animation<double> animation;

  GradientBorderPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double borderWidth = 8.0; // Border thickness
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Define the gradient
    final SweepGradient gradient = SweepGradient(
      colors: [
        const Color(0xFF151515), // Dark grey
        const Color(0xFFD20E0D), // Deep red
        const Color(0xFFC4C4C4), // Light grey
        const Color(0xFFF9F9F9), // Off-white
        const Color(0xFF151515), // Back to dark grey for looping
      ],
      stops: [0.0, 0.3, 0.6, 0.8, 1.0], // Adjust stops for smooth blending
      transform:
          GradientRotation(animation.value * 2 * pi), // Rotate the gradient
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double radius = (size.width / 2) - (borderWidth / 2);

    // Draw the circular gradient border
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Redraw on every animation tick
  }
}
