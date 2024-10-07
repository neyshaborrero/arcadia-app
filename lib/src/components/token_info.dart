import 'package:flutter/material.dart';

class TokenInfo extends StatelessWidget {
  final int tokens;
  final double scaleFactor;

  const TokenInfo({
    super.key,
    required this.tokens,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final double imageSize = 45 * scaleFactor;
    final double fontSizeLabel =
        Theme.of(context).textTheme.labelMedium!.fontSize! * scaleFactor;
    final double fontSizeTitle =
        Theme.of(context).textTheme.titleLarge!.fontSize! * scaleFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Tokens Earned',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontSize: fontSizeLabel),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Image.asset(
              'assets/tokenization.png',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 25),
            Text(
              tokens.toString(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: fontSizeTitle),
            ),
          ],
        ),
      ],
    );
  }
}
