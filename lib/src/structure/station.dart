class Station {
  final String gameId;
  final String name;
  final String status;

  Station({
    required this.gameId,
    required this.name,
    required this.status,
  });

  // Factory constructor to create a Station object from JSON
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      gameId: json['gameId'] ?? '242332',
      name: json['name'] as String,
      status: json['status'] as String,
    );
  }

  // Method to convert Station object to JSON
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'name': name,
      'status': status,
    };
  }
}
