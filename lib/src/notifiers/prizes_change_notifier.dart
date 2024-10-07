import 'package:arcadia_mobile/src/structure/prize_details.dart';
import 'package:flutter/foundation.dart';

class PrizesChangeProvider with ChangeNotifier {
  List<PrizeDetails> _prizeList = [];

  List<PrizeDetails> get prizeList => _prizeList;

  void setPrizeList(List<PrizeDetails> prizes) {
    _prizeList = prizes;
    notifyListeners();
  }

  List<PrizeDetails> getPrizesByRaffleDate(String date) {
    return _prizeList
        .where((prize) => prize.raffleDate.substring(0, 10) == date)
        .toList();
  }
}
