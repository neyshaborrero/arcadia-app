import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:flutter/foundation.dart';

class AdsDetailsProvider with ChangeNotifier {
  final List<AdsDetails> _adsDetails = [];

  List<AdsDetails> get adsDetails => _adsDetails;

  void addAllAdsDetails(List<AdsDetails> ads) {
    _adsDetails.addAll(ads);
    // notifyListeners();
  }

  void addAdsDetails(AdsDetails ad) {
    _adsDetails.add(ad);
    // notifyListeners();
  }

  AdsDetails getSplashAd() {
    return _adsDetails.firstWhere((element) => element.tier == 'legendary');
  }

  List<AdsDetails> getEpicAds() {
    return _adsDetails.where((element) => element.tier == 'epic').toList();
  }
}
