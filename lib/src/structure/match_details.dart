import 'package:arcadia_mobile/src/structure/match_player.dart';
import 'package:arcadia_mobile/src/structure/station.dart';
import 'package:arcadia_mobile/src/structure/game.dart'; // Assuming you have the Game model in this path

class MatchDetails {
  final String? id;
  String? gameId;
  final String? eventId;
  final String? hubId;
  String? stationId;
  Station? station;
  String? matchStatus;
  String? matchType;
  final String? winner;
  List<MatchPlayer>? team1;
  List<MatchPlayer>? team2;
  List<MatchPlayer>? team3;
  List<MatchPlayer>? team4;
  Game? game; // Add the Game object here

  MatchDetails({
    this.id,
    this.gameId,
    this.eventId,
    this.hubId,
    this.stationId,
    this.station,
    this.matchStatus,
    this.matchType,
    this.winner,
    this.team1,
    this.team2,
    this.team3,
    this.team4,
    this.game,
  });

  // Factory constructor to create a MatchDetails object from JSON
  factory MatchDetails.fromJson(String? id, Map<String, dynamic> json) {
    return MatchDetails(
      id: id ?? json['id'], // Default to provided `id` if available
      gameId: json['gameId'] as String?,
      eventId: json['eventId'] as String?,
      hubId: json['hubId'] as String?,
      stationId: json['stationId'] as String?,
      station: json['station'] != null
          ? Station.fromJson(json['stationId'], json['station'])
          : null, // Pass both stationId and station data
      matchStatus: json['matchStatus'] as String?,
      matchType: json['matchType'] as String?,
      winner: json['winner'] as String?, // Allow `winner` to be nullable
      team1:
          json['team1'] != null ? _parseTeam(json['team1']) : <MatchPlayer>[],
      team2:
          json['team2'] != null ? _parseTeam(json['team2']) : <MatchPlayer>[],
      team3:
          json['team3'] != null ? _parseTeam(json['team3']) : <MatchPlayer>[],
      team4:
          json['team4'] != null ? _parseTeam(json['team4']) : <MatchPlayer>[],
      game: json['game'] != null
          ? Game.fromJson(json['game'])
          : null, // Parse the `game` field
    );
  }

  // Helper function to parse team data
  static List<MatchPlayer> _parseTeam(Map<String, dynamic> teamJson) {
    List<MatchPlayer> team = [];
    if (teamJson['playerOne'] != null) {
      team.add(MatchPlayer.fromJson(teamJson['playerOne']));
    }
    if (teamJson['playerTwo'] != null) {
      team.add(MatchPlayer.fromJson(teamJson['playerTwo']));
    }
    return team;
  }

  // Method to convert a MatchDetails object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'eventId': eventId,
      'hubId': hubId,
      'stationId': stationId,
      'station': station?.toJson(), // Convert station object to JSON
      'matchStatus': matchStatus,
      'matchType': matchType,
      'winner': winner,
      'team1': team1?.map((player) => player.toJson()).toList(),
      'team2': team2?.map((player) => player.toJson()).toList(),
      'team3': team1?.map((player) => player.toJson()).toList(),
      'team4': team2?.map((player) => player.toJson()).toList(),
      'game': game?.toJson(), // Convert the game object to JSON
    };
  }
}
