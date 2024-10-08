import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/match_player.dart';
import 'package:arcadia_mobile/src/tools/slides.dart';
import 'package:flutter/material.dart';

import '../views/matches/match_view.dart';

class MatchContainer extends StatefulWidget {
  final String hubId;
  final Hub hubDetails;
  final List<MatchDetails> hubMatches;

  const MatchContainer(
      {super.key,
      required this.hubId,
      required this.hubMatches,
      required this.hubDetails});

  @override
  _MatchContainerState createState() => _MatchContainerState();
}

class _MatchContainerState extends State<MatchContainer> {
  bool hasReachedMaxVotes = false;

  @override
  Widget build(BuildContext context) {
    final bool tablet = MediaQuery.of(context).size.width >= 600;
    final double scaleFactor = tablet
        ? MediaQuery.of(context).size.height / 1000
        : MediaQuery.of(context).size.height / 900;
    final double padding = 12 * scaleFactor;

    // Directly using the matches from widget.hubMatches
    final matches = widget.hubMatches;

    if (matches.isEmpty) {
      return Center(
          child: Text(
              'No matches available')); // Show message if no matches are available
    }

    // Render the matches when data is available
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(12), // You can adjust the padding as needed
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Ensure content stretches horizontally
          children: [
            _buildPlayerAvatarSelection(
                context, matches), // Pass the matches to the selection method
          ],
        ),
      ),
    );
  }

  // Method to dynamically build player avatar selections based on fetched data
  Widget _buildPlayerAvatarSelection(
      BuildContext context, List<MatchDetails> matches) {
    List<Widget> rows = [];

    // Loop through each match entry in the provided data
    for (var match in matches) {
      rows.add(_buildPlayerAvatarRow(context, match));
      rows.add(const SizedBox(height: 30)); // Space between rows
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildPlayerAvatarRow(BuildContext context, MatchDetails match) {
    List<MatchPlayer> team1 = match.team1 ?? [];
    List<MatchPlayer> team2 = match.team2 ?? [];

    return InkWell(
      onTap: () {
        navigateUpWithSlideTransition(
            context,
            MatchView(
              matchData: match,
              hubDetails: widget.hubDetails,
              hubId: widget.hubId,
            ));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD20E0D).withOpacity(0.85), // Dark red color start
              const Color(0xFF020202)
                  .withOpacity(0.85), // Lighter red color end
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Ensures the column takes only the necessary space
          children: [
            // Display station name and game name
            Center(
              child: Text(
                match.station!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "${match.game!.name} ${match.game!.type}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),

            // Display team1 and team2 players
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: _buildPlayerAvatar(context, team1[0].gamertag,
                      team1[0].imageprofile, team1[0].stationSpot),
                ),
                if (match.matchType == '1v1')
                  Flexible(
                    child: Image.asset(
                      'assets/versus.png', // Replace with your image asset path
                      width: 60,
                      height: 60,
                    ),
                  ),
                Flexible(
                  child: _buildPlayerAvatar(context, team2[0].gamertag,
                      team2[0].imageprofile, team2[0].stationSpot),
                ),
              ],
            ),

            if (match.matchType == '2v2') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double
                    .infinity, // Ensures the container takes the full width
                child: Stack(
                  alignment: Alignment.center, // Center the image and the line
                  children: [
                    // Line that expands from end to end
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 2, // Thickness of the line
                          color: const Color(
                              0xFFFAC437), // Line color (Hex code #FAC437)
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10), // Optional margin
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (team1.length > 1)
                    Flexible(
                      child: _buildPlayerAvatar(context, team1[1].gamertag,
                          team1[1].imageprofile, team1[1].stationSpot),
                    ),
                  if (team2.length > 1)
                    Flexible(
                      child: _buildPlayerAvatar(context, team2[1].gamertag,
                          team2[1].imageprofile, team2[1].stationSpot),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Method to build CircleAvatar with player label and profile image
  Widget _buildPlayerAvatar(BuildContext context, String playerLabel,
      String imageUrl, String stationSpot) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4.0,
                ),
              ),
              child: CircleAvatar(
                radius: 50, // Set a fixed size for the avatar
                backgroundColor: const Color(0xFF2C2B2B),
                backgroundImage:
                    NetworkImage(imageUrl), // Load player profile image
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD20E0D),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      stationSpot,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // Space between avatar and text
        Text(
          playerLabel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color:
                    Colors.white, // Ensure text is readable on dark background
              ),
        ),
      ],
    );
  }
}
