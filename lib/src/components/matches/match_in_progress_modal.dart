import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/match_player.dart';

class MatchInProgressModal extends StatelessWidget {
  final MatchDetails matchDetails;

  const MatchInProgressModal({super.key, required this.matchDetails});

  @override
  Widget build(BuildContext context) {
    final String matchType = matchDetails.matchType ?? '';
    final String station = matchDetails.station?.name ?? '';
    final String gameImage = matchDetails.game?.image ?? '';
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          Colors.black.withOpacity(0.8), // Semi-transparent background
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9, // Responsive width
            maxHeight: screenHeight * 0.9, // Responsive height
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green,
                  const Color(0xFF020202),
                ],
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Match in Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CachedNetworkImage(
                    width: 100,
                    height: 100,
                    imageUrl: gameImage,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Text(
                    station,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildMatchContent(context, matchType),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchContent(BuildContext context, String matchType) {
    print("matchType $matchType");
    switch (matchType) {
      case '1v1':
        return _build1v1Match(context);
      case '2v2':
        return _build2v2Match(context);
      case '1v1v1v1':
        return _build1v1v1v1Match(context);
      default:
        return const Text(
          'Unknown Match Type',
          style: TextStyle(fontSize: 18, color: Colors.white),
        );
    }
  }

  Widget _build1v1Match(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerCard(context, matchDetails.team1?.first, 'Team 1'),
        _buildVersusIcon(context),
        _buildPlayerCard(context, matchDetails.team2?.first, 'Team 2'),
      ],
    );
  }

  Widget _build2v2Match(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlayerCard(context, matchDetails.team1?[0], 'Team 1 - A'),
            _buildPlayerCard(context, matchDetails.team1?[1], 'Team 1 - B'),
          ],
        ),
        SizedBox(
          width: double.infinity, // Ensures the container takes the full width
          child: Stack(
            alignment: Alignment.center, // Center the image and the line
            children: [
              // Line that expands from end to end
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 2, // Thickness of the line
                    color: const Color(0xFFFAC437), // Line color
                    margin: const EdgeInsets.symmetric(horizontal: 10),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlayerCard(context, matchDetails.team2?[0], 'Team 2 - A'),
            _buildPlayerCard(context, matchDetails.team2?[1], 'Team 2 - B'),
          ],
        ),
      ],
    );
  }

  Widget _build1v1v1v1Match(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final team = [
          matchDetails.team1,
          matchDetails.team2,
          matchDetails.team3,
          matchDetails.team4
        ][index];
        return _buildPlayerCard(context, team?.first, 'Team ${index + 1}');
      },
    );
  }

  Widget _buildPlayerCard(
      BuildContext context, MatchPlayer? player, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFF2C2B2B),
          backgroundImage:
              player != null ? NetworkImage(player.imageprofile) : null,
          child: player == null
              ? const Icon(Icons.person, color: Colors.white, size: 40)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          player?.gamertag ?? label,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersusIcon(BuildContext context) {
    return const Image(
      image: AssetImage('assets/versus.png'),
      width: 50,
      height: 50,
    );
  }
}
