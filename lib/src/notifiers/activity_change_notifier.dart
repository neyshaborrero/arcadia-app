import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:flutter/foundation.dart';

class UserActivityProvider with ChangeNotifier {
  List<UserActivity> _userActivities = [];

  List<UserActivity> get userActivities => _userActivities;

  void addUserActivity(UserActivity activity) {
    _userActivities.insert(0, activity);
    notifyListeners();
  }

  void addUserActivities(List<UserActivity> activity) {
    _userActivities.addAll(activity);
    // _userActivities.insert(0, activity);
    notifyListeners();
  }

  void setUserActivities(List<UserActivity> activities) {
    _userActivities = activities;
    notifyListeners();
  }

  void clearUserActivities() {
    _userActivities = [];
    notifyListeners();
  }
}
