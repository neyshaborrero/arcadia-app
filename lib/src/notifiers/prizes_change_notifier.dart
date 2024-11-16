import 'package:arcadia_mobile/src/structure/prize_details.dart';
import 'package:flutter/foundation.dart';

class PrizesChangeProvider with ChangeNotifier {
  List<PrizeDetails> _prizeList = [];

  List<PrizeDetails> get prizeList => _prizeList;

  void setPrizeList(List<PrizeDetails> prizes) {
    _prizeList = prizes;
    notifyListeners();
  }

  // Add multiple prizes to the existing list
  void addPrizes(List<PrizeDetails> prizes) {
    _prizeList.addAll(prizes);
    notifyListeners(); // Notify listeners about the change
  }

  List<PrizeDetails> getPrizesByRaffleDate(String date) {
    return _prizeList
        .where((prize) =>
            prize.lootPrize == false &&
            prize.raffleDate.substring(0, 10) == date)
        .toList();
  }

  List<PrizeDetails> getLootPrizes() {
    return _prizeList.where((prize) => prize.lootPrize == true).toList();
  }
}
