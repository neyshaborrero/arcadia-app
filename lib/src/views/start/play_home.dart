import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/qrcode/player_qr_code.dart';
import 'package:flutter/material.dart';

class PlayHome extends StatelessWidget {
  const PlayHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AdsCarouselComponent(viewType: ViewType.eventHome),
          Expanded(
            child:
                PlayerQRCodeWidget(), // Ensure MyQRCode takes available space
          ),
        ],
      ),
    );
  }
}
