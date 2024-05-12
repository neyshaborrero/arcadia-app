import 'package:flutter/foundation.dart';

class ClickedState with ChangeNotifier {
  final Set<int> _clickedIds = {};
  bool _isVisible = true;
  bool get isVisible => _isVisible;

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

  void showChildren(bool visible) {
    _isVisible = visible;
    notifyListeners();
  }
}
