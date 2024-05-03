import 'package:flutter/foundation.dart';

class ClickedState with ChangeNotifier {
  final Set<int> _clickedIds = {};

  void toggleClicked(int id) {
    if (_clickedIds.contains(id)) {
      _clickedIds.remove(id);
    } else {
      _clickedIds.add(id);
    }
    notifyListeners();
  }

  bool isClicked(int id) {
    return _clickedIds.contains(id);
  }
}
