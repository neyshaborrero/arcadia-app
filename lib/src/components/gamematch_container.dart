import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/match_player.dart';
import 'package:flutter/material.dart';

import '../views/matches/match_view.dart';

class MatchContainer extends StatefulWidget {
  final String hubId;
  final Hub hubDetails;
  final List<MatchDetails> hubMatches;
  final VoidCallback onRefreshMatches;

  const MatchContainer({
    super.key,
    required this.hubId,
    required this.hubMatches,
    required this.hubDetails,
    required this.onRefreshMatches,
  });

  @override
  _MatchContainerState createState() => _MatchContainerState();
}

class _MatchContainerState extends State<MatchContainer> {
  @override
  Widget build(BuildContext context) {
    final matches = widget.hubMatches;

    if (matches.isEmpty) {
      return const Center(child: Text('No matches available'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var match in matches) ...[
              _buildPlayerAvatarRow(context, match),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatarRow(BuildContext context, MatchDetails match) {
    List<MatchPlayer> team1 = match.team1 ?? [];
    List<MatchPlayer> team2 = match.team2 ?? [];
    List<MatchPlayer> team3 = match.team3 ?? [];
    List<MatchPlayer> team4 = match.team4 ?? [];

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchView(
              matchData: match,
              hubDetails: widget.hubDetails,
              hubId: widget.hubId,
            ),
          ),
        );

        if (result == 'refresh') {
          widget.onRefreshMatches();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (match.matchStatus == 'in progress')
                  ? Colors.green.withOpacity(0.85)
                  : const Color(0xFFD20E0D).withOpacity(0.85),
              const Color(0xFF020202).withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              match.station?.name ?? 'Finish Setting up the Match',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              match.game != null
                  ? "${match.game!.name} ${match.game!.type}"
                  : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Display avatars for 1v1v1v1
            if (match.matchType == '1v1v1v1') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (team1.isNotEmpty) _buildPlayerAvatar(context, team1[0]),
                  if (team2.isNotEmpty) _buildPlayerAvatar(context, team2[0]),
                ],
              ),
              Image.asset(
                'assets/versus.png',
                width: 60,
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (team3.isNotEmpty) _buildPlayerAvatar(context, team3[0]),
                  if (team4.isNotEmpty) _buildPlayerAvatar(context, team4[0]),
                ],
              ),
            ] else if (match.matchType == '2v2') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (team1.isNotEmpty) _buildPlayerAvatar(context, team1[0]),
                  SizedBox(
                    width: double
                        .infinity, // Ensures the container takes the full width
                    child: Stack(
                      alignment:
                          Alignment.center, // Center the image and the line
                      children: [
                        // Line that expands from end to end
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 2, // Thickness of the line
                              color: const Color(0xFFFAC437), // Line color
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        // Image centered on top of the line
                        Image.asset(
                          'assets/versus.png', // Replace with your image asset path
                          width: 60,
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                  if (team2.isNotEmpty) _buildPlayerAvatar(context, team2[0]),
                ],
              ),
            ] else if (match.matchType == '1v1') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (team1.isNotEmpty) _buildPlayerAvatar(context, team1[0]),
                  Image.asset(
                    'assets/versus.png',
                    width: 60,
                    height: 60,
                  ),
                  if (team2.isNotEmpty) _buildPlayerAvatar(context, team2[0]),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(BuildContext context, MatchPlayer player) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(player.imageprofile),
          backgroundColor: const Color(0xFF2C2B2B),
        ),
        const SizedBox(height: 8),
        Text(
          player.gamertag,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
