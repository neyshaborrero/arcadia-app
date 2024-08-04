import 'dart:math';

import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:flutter/foundation.dart';

class AdsDetailsProvider with ChangeNotifier {
  final List<AdsDetails> _adsDetails = [];

  List<AdsDetails> get adsDetails => _adsDetails;

  void addAllAdsDetails(List<AdsDetails> ads) {
    _adsDetails.clear(); // Clear existing ads before adding new ones
    _adsDetails.addAll(ads);
    notifyListeners();
  }

  void addAdsDetails(AdsDetails ad) {
    _adsDetails.add(ad);
    notifyListeners();
  }

  AdsDetails getSplashAd() {
    try {
      final List<AdsDetails> legendaryAds =
          _adsDetails.where((element) => element.tier == 'legendary').toList();

      if (legendaryAds.isEmpty) {
        return AdsDetails(
            tier: "legendary",
            image:
                "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2F2024_Logo-B.png?alt=media&token=fe68c904-1ae3-477e-956f-4f5655c44888",
            url: "https://www.yosoyungamer.com/arcadia-battle-royale-2024/",
            partner: "ysug",
            id: "0000000"); // Default ad
      }

      final randomIndex = Random().nextInt(legendaryAds.length);
      return legendaryAds[randomIndex];
    } catch (e) {
      // Return a default ad or handle the case when no 'legendary' ad is found
      return AdsDetails(
          tier: "legendary",
          image:
              "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2F2024_Logo-B.png?alt=media&token=fe68c904-1ae3-477e-956f-4f5655c44888",
          url: "https://www.yosoyungamer.com/arcadia-battle-royale-2024/",
          partner: "ysug",
          id: "0000000");
    }
  }

  List<AdsDetails> getEpicAds() {
    List<AdsDetails> epicAds =
        _adsDetails.where((element) => element.tier == 'epic').toList();
    epicAds.shuffle(Random());
    return epicAds;
  }
}
