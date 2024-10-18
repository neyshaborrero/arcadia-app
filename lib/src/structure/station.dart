class Station {
  final String id;
  final String gameId;
  final String name;
  final String status;

  Station({
    required this.id,
    required this.gameId,
    required this.name,
    required this.status,
  });

  // Factory constructor to create a Station object from JSON
  factory Station.fromJson(String id, Map<String, dynamic> json) {
    return Station(
      id: id,
      gameId: json['gameId'] ?? '',
      name: json['name'] as String,
      status: json['status'] as String,
    );
  }

  // Method to convert Station object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'name': name,
      'status': status,
    };
  }
}
