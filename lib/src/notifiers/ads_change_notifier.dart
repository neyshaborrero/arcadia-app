import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:flutter/foundation.dart';

class AdsDetailsProvider with ChangeNotifier {
  final List<AdsDetails> _adsDetails = [];

  List<AdsDetails> get adsDetails => _adsDetails;

  void addAdsDetails(List<AdsDetails> activity) {
    _adsDetails.addAll(activity);
    notifyListeners();
  }
}
