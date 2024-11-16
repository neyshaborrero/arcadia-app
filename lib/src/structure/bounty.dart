class Bounty {
  final String bountyId;
  final int currentStreak;
  final int bountyAmount;
  final String gameId;
  final String gameImage;
  final String gameName;
  final String gamerTag;
  final String hubId;
  final String hubName;
  final String playerProfileImageUrl;
  final String playerUserId;
  final String status;
  final int? expirationTimestamp;

  Bounty({
    required this.bountyId,
    required this.currentStreak,
    required this.bountyAmount,
    required this.gameId,
    required this.gameImage,
    required this.gameName,
    required this.gamerTag,
    required this.hubId,
    required this.hubName,
    required this.playerProfileImageUrl,
    required this.playerUserId,
    required this.status,
    this.expirationTimestamp,
  });

  // Factory constructor to create a Bounty instance from JSON
  factory Bounty.fromJson(Map<String, dynamic> json) {
    return Bounty(
        bountyId: json['bountyId'],
        currentStreak: json['currentStreak'],
        bountyAmount: json['bountyAmount'],
        gameId: json['gameId'],
        gameImage: json['gameImage'],
        gameName: json['gameName'],
        gamerTag: json['gamerTag'],
        hubId: json['hubId'],
        hubName: json['hubName'],
        playerProfileImageUrl: json['playerProfileImageUrl'],
        playerUserId: json['playerUserId'],
        status: json['status'],
        expirationTimestamp: json['expirationTimestamp']);
  }
}
