class UserProfile {
  final String fullName;
  final String gender;
  final String dob;
  final String gamertag;
  String profileImageUrl;
  final String userType;

  UserProfile(
      {required this.fullName,
      required this.gender,
      required this.dob,
      required this.gamertag,
      required this.profileImageUrl,
      required this.userType});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      gamertag: json['gamertag'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      userType: json['userType'] ?? '',
    );
  }
}
