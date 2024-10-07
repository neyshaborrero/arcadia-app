class MatchPlayer {
  final String userId;
  final String gamertag;
  final String imageprofile;
  final String stationSpot;

  MatchPlayer({
    required this.userId,
    required this.gamertag,
    required this.imageprofile,
    required this.stationSpot,
  });

  // fromJson constructor for deserializing JSON to MatchPlayer object
  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    return MatchPlayer(
      userId: json['userId'],
      gamertag: json['gamertag'],
      imageprofile: json['imageprofile'],
      stationSpot: json['stationSpot'],
    );
  }

  // toJson method for serializing MatchPlayer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'gamertag': gamertag,
      'imageprofile': imageprofile,
      'stationSpot': stationSpot,
    };
  }
}
