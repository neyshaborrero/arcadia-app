class Game {
  final String gameId;
  final String image;
  final int multiplier;
  final String name;
  final String type;
  final int xpLose;
  final int xpWin;

  Game({
    required this.gameId,
    required this.image,
    required this.multiplier,
    required this.name,
    required this.type,
    required this.xpLose,
    required this.xpWin,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameId: json['gameId'] ?? '324432',
      image: json['image'],
      multiplier: json['multiplier'] ?? 1,
      name: json['name'],
      type: json['type'],
      xpLose: json['xpLose'],
      xpWin: json['xpWin'],
    );
  }

  // Method to convert a Game object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'image': image,
      'multiplier': multiplier,
      'name': name,
      'type': type,
      'xpLose': xpLose,
      'xpWin': xpWin,
    };
  }
}
