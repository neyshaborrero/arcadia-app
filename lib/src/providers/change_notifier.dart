import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:flutter/foundation.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }

  void updateProfileUrl(String profileUrl) {
    if (_userProfile != null) {
      _userProfile!.profileImageUrl = profileUrl;
      notifyListeners();
    }
  }
}
