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
  String? currentHubId;
  bool? isAdmin;
  int xp;
  final String checkedin;
  int playerLevel;
  int matchStreak;
  int prestigeTotal;
  int raffleEntries;
  int raffleEntriesDayOne;
  int raffleEntriesDayTwo;
  String playerCurrentHub;
  String currentMatch;
  bool raffleParticipation;
  int tokensDayOne;
  int tokensDayTwo;

  UserProfile(
      {required this.fullName,
      required this.currentMatch,
      required this.gender,
      required this.dob,
      required this.gamertag,
      required this.profileImageUrl,
      required this.userType,
      required this.tokens,
      required this.qrcode,
      required this.profileComplete,
      required this.fcmToken,
      this.currentHubId,
      this.isAdmin,
      required this.raffleEntries,
      required this.raffleEntriesDayOne,
      required this.raffleEntriesDayTwo,
      required this.xp,
      required this.checkedin,
      required this.raffleParticipation,
      required this.playerLevel,
      required this.matchStreak,
      required this.prestigeTotal,
      required this.playerCurrentHub,
      required this.tokensDayOne,
      required this.tokensDayTwo});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] ?? '',
      raffleParticipation: json['raffleParticipation'] ?? false,
      currentMatch: json['currentMatch'] ?? '',
      xp: json['xp'] ?? 0,
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      gamertag: json['gamertag'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      userType: json['userType'] ?? '',
      tokens: json['tokens'] ?? 0,
      qrcode: json['qrcode'] ?? '',
      profileComplete: json['profileComplete'] ?? false,
      fcmToken: json['fcmToken'] ?? '',
      currentHubId: json['currentHubId'] ?? '',
      isAdmin: json['isAdmin'],
      checkedin: json['checkedin'] ?? '',
      playerLevel: json['playerLevel'] ?? 0,
      raffleEntries: json['raffleEntries'] ?? 0,
      raffleEntriesDayOne: json['raffleEntriesDayOne'] ?? 0,
      raffleEntriesDayTwo: json['raffleEntriesDayTwo'] ?? 0,
      matchStreak: json['matchStreak'] ?? 0,
      prestigeTotal: json['prestigeTotal'] ?? 0,
      playerCurrentHub: json['playerCurrentHub'] ?? '',
      tokensDayOne: json['tokensDayOne'] ?? 0,
      tokensDayTwo: json['tokensDayTwo'] ?? 0,
    );
  }

  String tokensToString() {
    return tokens.toString();
  }
}
