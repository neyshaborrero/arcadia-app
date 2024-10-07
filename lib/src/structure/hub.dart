import 'package:arcadia_mobile/src/structure/game.dart';
import 'package:arcadia_mobile/src/structure/station.dart';

class Hub {
  final List<String> assignedOperators;
  final String description;
  final String eventId;
  final String image;
  final String name;
  final String sponsorId;
  final Map<String, Station> stations; // Change to Map with Station class
  final List<Game> games;

  Hub({
    required this.assignedOperators,
    required this.description,
    required this.eventId,
    required this.image,
    required this.name,
    required this.sponsorId,
    required this.stations,
    required this.games,
  });

  factory Hub.fromJson(Map<String, dynamic> json) {
    // Parsing stations: Convert each station entry into a Station object
    Map<String, Station> stationsMap =
        (json['stations'] as Map<String, dynamic>).map(
      (key, value) =>
          MapEntry(key, Station.fromJson(value as Map<String, dynamic>)),
    );

    // Parsing games: Convert each game entry into a Game object
    List<Game> gameList = (json['games'] as List).map((gameJson) {
      return Game.fromJson(gameJson as Map<String, dynamic>);
    }).toList();

    return Hub(
      assignedOperators: List<String>.from(json['assignedOperators']),
      description: json['description'],
      eventId: json['eventId'],
      image: json['image'],
      name: json['name'],
      sponsorId: json['sponsorId'],
      stations: stationsMap,
      games: gameList,
    );
  }
}
