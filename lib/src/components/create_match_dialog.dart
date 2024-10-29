import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<String?> showCreateMatch(BuildContext context, MatchDetails match) {
  final firebaseService = Provider.of<FirebaseService>(context, listen: false);
  final ArcadiaCloud arcadiaCloud = ArcadiaCloud(firebaseService);

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: IntrinsicHeight(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildMatchContent(context, match),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Align buttons with space between them
                children: [
                  // First Action Button
                  Expanded(
                    child: _buildCloseButton(
                      context,
                      arcadiaCloud, // First action button parameters
                    ),
                  ),
                  if (match.id != null)
                    // Second Action Button
                    Expanded(
                      child: _buildActionButton(
                          context,
                          arcadiaCloud, // Second action button parameters
                          match.id!),
                    ),
                ],
              ),
            ],
          ),
        )),
      );
    },
  ).then((result) {
    return "refresh";
  });
}

Widget _buildMatchContent(
  BuildContext context,
  MatchDetails matchData,
) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD20E0D).withOpacity(0.85), // Dark red color start
          const Color(0xFF020202).withOpacity(0.85), // Lighter red color end
        ],
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(16.0), // Add padding
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          matchData.station?.name ??
              'Unknown Station', // Display the station name
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        // Conditionally render based on matchType
        if (matchData.matchType == '1v1')
          _build1v1MatchContent(context, matchData)
        else if (matchData.matchType == '2v2')
          _build2v2MatchContent(context, matchData),

        const SizedBox(height: 12),
        Text(
          'Would you like to start the match?',
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildActionButton(
    BuildContext context, ArcadiaCloud arcadiaCloud, String matchId) {
  const buttonText = "Start Match";

  return Column(
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: Colors.black,
        ),
        onPressed: () async {
          // Call the function to change the match status to 'in progress'
          bool success = await _changeMatchStatus(
            arcadiaCloud,
            matchId,
          );
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            // Handle the failure case with a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to start match')),
            );
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 225, maxWidth: 225),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0XFF4BAE4F), // Your signature green color
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildCloseButton(BuildContext context, ArcadiaCloud arcadiaCloud) {
  const buttonText = "Close";

  return Column(
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: Colors.black,
        ),
        onPressed: () async {
          Navigator.of(context).pop(true);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 225, maxWidth: 225),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFD20E0D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Future<bool> _changeMatchStatus(
    ArcadiaCloud arcadiaCloud, String matchId) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final token = await user.getIdToken();

  if (token == null) return false;
  try {
    final success =
        await arcadiaCloud.changeMatchStatus('in progress', matchId, token);

    return success;
  } catch (e) {
    // Handle error
    print('Failed to set the match to In Progress');
    return false;
  }
}

// Helper to build the content for a 1v1 match
Widget _build1v1MatchContent(BuildContext context, MatchDetails matchData) {
  return Row(
    children: [
      _buildPlayerAvatar(
        context,
        matchData.team1?.isNotEmpty == true
            ? matchData.team1![0].gamertag
            : 'Player 1',
        matchData.team1?.isNotEmpty == true
            ? matchData.team1![0].imageprofile
            : '',
        'A',
      ),
      const SizedBox(width: 5),
      Flexible(
        child: Image.asset(
          'assets/versus.png',
          width: 60,
          height: 60,
        ),
      ),
      const SizedBox(width: 5),
      _buildPlayerAvatar(
        context,
        matchData.team2?.isNotEmpty == true
            ? matchData.team2![0].gamertag
            : 'Player 2',
        matchData.team2?.isNotEmpty == true
            ? matchData.team2![0].imageprofile
            : '',
        'B',
      ),
    ],
  );
}

// Helper to build the content for a 2v2 match
Widget _build2v2MatchContent(BuildContext context, MatchDetails matchData) {
  return Column(
    children: [
      // First row for Team 1
      Row(
        children: [
          _buildPlayerAvatar(
            context,
            matchData.team1!.isNotEmpty
                ? matchData.team1![0].gamertag
                : 'Player A',
            matchData.team1!.isNotEmpty ? matchData.team1![0].imageprofile : '',
            'A',
          ),
          const SizedBox(width: 5),
          _buildPlayerAvatar(
            context,
            matchData.team1!.length > 1
                ? matchData.team1![1].gamertag
                : 'Player B',
            matchData.team1!.length > 1 ? matchData.team1![1].imageprofile : '',
            'B',
          ),
        ],
      ),
      const SizedBox(height: 5),
      // Versus image
      Center(
        child: Image.asset(
          'assets/versus.png',
          width: 60,
          height: 60,
        ),
      ),
      const SizedBox(height: 5),
      // Second row for Team 2
      Row(
        children: [
          _buildPlayerAvatar(
            context,
            matchData.team2!.isNotEmpty
                ? matchData.team2![0].gamertag
                : 'Player C',
            matchData.team2!.isNotEmpty ? matchData.team2![0].imageprofile : '',
            'C',
          ),
          const SizedBox(width: 5),
          _buildPlayerAvatar(
            context,
            matchData.team2!.isNotEmpty
                ? matchData.team2![1].gamertag
                : 'Player D',
            matchData.team2!.isNotEmpty ? matchData.team2![1].imageprofile : '',
            'D',
          ),
        ],
      ),
    ],
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
              color: Colors.white, // Ensure text is readable on dark background
            ),
      ),
    ],
  );
}
