class UserProfile {
  final String fullName;
  final String gender;
  final String dob;
  final String gamertag;
  String profileImageUrl;
  final String userType;
  int tokens;
  final String qrcode;
  final bool profileComplete;
  String fcmToken;
  int xp;

  UserProfile(
      {required this.fullName,
      required this.gender,
      required this.dob,
      required this.gamertag,
      required this.profileImageUrl,
      required this.userType,
      required this.tokens,
      required this.qrcode,
      required this.profileComplete,
      required this.fcmToken,
      required this.xp});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        fullName: json['fullName'] ?? '',
        xp: json['xp'] ?? 0,
        gender: json['gender'] ?? '',
        dob: json['dob'] ?? '',
        gamertag: json['gamertag'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
        userType: json['userType'] ?? '',
        tokens: json['tokens'] ?? 0,
        qrcode: json['qrcode'] ?? '',
        profileComplete: json['profileComplete'] ?? false,
        fcmToken: json['fcmToken'] ?? '');
  }

  String tokensToString() {
    return tokens.toString();
  }
}
