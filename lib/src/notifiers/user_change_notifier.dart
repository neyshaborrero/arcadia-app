import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:flutter/foundation.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;
  String? get profileUrl => _userProfile?.profileImageUrl;
  bool get isOperator => _userProfile?.userType == 'operator';
  String? get currentHubId => _userProfile?.currentHubId;

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

  void setTokens(int tokens) {
    _userProfile!.tokens = tokens;
    notifyListeners();
  }

  void updateRaffleEntries(int entries, int dayOne, int dayTwo) {
    _userProfile!.raffleEntries = _userProfile!.raffleEntries + entries;
    _userProfile!.raffleEntriesDayOne =
        _userProfile!.raffleEntriesDayOne + dayOne;
    _userProfile!.raffleEntriesDayTwo =
        _userProfile!.raffleEntriesDayTwo + dayTwo;
    notifyListeners();
  }

  void updateXP(int xpEarned) {
    _userProfile!.xp = _userProfile!.xp + xpEarned;
    notifyListeners();
  }

  void updateOperatorCheckIn(String hubId) {
    if (_userProfile != null) {
      _userProfile!.currentHubId = hubId;
      notifyListeners();
    }
  }
}
