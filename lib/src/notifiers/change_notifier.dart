import 'package:flutter/foundation.dart';

class ClickedState with ChangeNotifier {
  final Set<String> _clickedIds = {};
  bool _isVisible = true;
  bool get isVisible => _isVisible;

  void toggleClicked(String id, {bool initialState = false}) {
    if (initialState) {
      // Add to the set without toggling off if already present
      _clickedIds.add(id);
    } else {
      // Toggle the state: add if not present, remove if present
      if (_clickedIds.contains(id)) {
        _clickedIds.remove(id);
      } else {
        _clickedIds.add(id);
      }
    }
    notifyListeners();
  }

  bool isClicked(String id) {
    return _clickedIds.contains(id);
  }

  void showChildren(bool visible) {
    _isVisible = visible;
    notifyListeners();
  }
}
