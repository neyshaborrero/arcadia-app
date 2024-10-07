import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:flutter/foundation.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;
  String? get profileUrl => _userProfile?.profileImageUrl;

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

  void updateTokens(int tokensEarned) {
    _userProfile!.tokens = _userProfile!.tokens + tokensEarned;
    notifyListeners();
  }

  void updateXP(int xpEarned) {
    _userProfile!.xp = _userProfile!.xp + xpEarned;
    notifyListeners();
  }
}
