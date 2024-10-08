import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/create_match_dialog.dart';
import 'package:arcadia_mobile/src/structure/game.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/slides.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arcadia_mobile/src/structure/match_player.dart';
import 'package:provider/provider.dart';

class MatchView extends StatefulWidget {
  final MatchDetails? matchData;
  final Hub hubDetails;
  final String hubId;
  const MatchView(
      {super.key,
      required this.matchData,
      required this.hubDetails,
      required this.hubId});

  @override
  _MatchViewState createState() => _MatchViewState();
}

class HubDetails {}

class _MatchViewState extends State<MatchView> with TickerProviderStateMixin {
  int _selectedGameIndex = 1;
  String matchType = '1v1';
  late final ArcadiaCloud _arcadiaCloud;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _progressAnimations;
// Number of avatars in this example
  final int numberOfAvatars = 4;
  bool _isAvatarSelected = true;
  late MatchDetails matchDetails;

  @override
  void initState() {
    super.initState();

    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);

    if (widget.matchData != null) {
      matchDetails = widget.matchData!;
    } else {
      matchDetails = MatchDetails(
        gameId: '', // Provide a default gameId
        matchType: '', // Provide a default match type
        team1: [], // An empty list for team1
        team2: [], // An empty list for team2
        game: Game(
          gameId: '',
          type: '',
          name: '',
          image: '',
          xpWin: 0,
          xpLose: 0,
          multiplier: 1,
        ),
      );
    }

    if (matchDetails.matchType!.isNotEmpty) {
      matchType = matchDetails.matchType!;
    }

    _isAvatarSelected =
        matchDetails.matchStatus == "in progress" ? false : true;

    // Initialize a list of animation controllers and animations
    _controllers = List.generate(
      numberOfAvatars,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500), // Speed up the animation
        vsync: this,
      ),
    );

    _progressAnimations = List.generate(
      numberOfAvatars,
      (index) =>
          Tween<double>(begin: 0.0, end: 1.0).animate(_controllers[index]),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<MatchDetails?> _createMatch(
      Hub hub, Game game, String hubId, String stationId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken();

    if (token == null) return null;

    final MatchDetails? response = await _arcadiaCloud.createArcadiaMatch(
        game.gameId, hub.eventId, hubId, stationId, game.type, token);

    return response;
  }

  // Method to handle avatar tap
  void _onAvatarTapped(int index) {
    setState(() {
      // Set _isAvatarSelected to true when an avatar is selected
      _isAvatarSelected = true;

      // Check if the match is a "2v2" and select both avatars of the same team
      if (matchDetails.matchType == '2v2') {
        if (index == 0 || index == 1) {
          // Tapped on team1
          _controllers[0].forward(from: 0.0);
          _controllers[1].forward(from: 0.0);
          _controllers[2].reset(); // Reset team2 animations
          _controllers[3].reset();
        } else if (index == 2 || index == 3) {
          // Tapped on team2
          _controllers[2].forward(from: 0.0);
          _controllers[3].forward(from: 0.0);
          _controllers[0].reset(); // Reset team1 animations
          _controllers[1].reset();
        }
      } else {
        // For "1v1", only animate the tapped avatar
        for (int i = 0; i < _controllers.length; i++) {
          if (i == index) {
            _controllers[i].forward(from: 0.0);
          } else {
            _controllers[i].reset();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MatchDetails matchData = matchDetails;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: true, // Enable back button
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD20E0D).withOpacity(0.85), // Dark red color start
              const Color(0xFF020202).withOpacity(0.85), // Black color end
            ],
          ),
        ),
        child: SingleChildScrollView(
          // Make the entire screen scrollable
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: (matchData.matchStatus != "in progress")
                    ? Text(
                        'Select Game',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors
                                  .white, // Set text color to white for contrast
                            ),
                      )
                    : Text(
                        matchData.station!.name,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors
                                  .white, // Set text color to white for contrast
                            ),
                      ),
              ),
              if (matchData.matchStatus == "in progress")
                Center(
                  child: Text(
                    matchData.game!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (matchData.matchStatus != "in progress")
                const SizedBox(height: 20),

              if (matchData.matchStatus != "in progress")
                Column(
                  children: [
                    // Display the name of the currently selected game at the top
                    if (widget.hubDetails.games.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "${widget.hubDetails.games[_selectedGameIndex].name} ${widget.hubDetails.games[_selectedGameIndex].type}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Single row for game selection
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.horizontal, // Make row scrollable if needed
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...widget.hubDetails.games
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              Game game = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 8.0), // Add spacing between items
                                child: Column(
                                  children: [
                                    // Game image wrapped in GestureDetector to allow selection
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedGameIndex =
                                              index; // Update the selected game index
                                        });
                                      },
                                      child: _buildGameSelection(context, index,
                                          game.image, game.type), // Game image
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: Text(
                  (matchData.matchStatus != "in progress")
                      ? 'Assign Players'
                      : 'Select Winner(s)',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors
                            .white, // Set text color to white for contrast
                      ),
                ),
              ),
              if (matchData.matchStatus != "in progress")
                const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildPlayerAvatarSelection(
                  matchType,
                  //matchData.matchType ?? '1v1',
                  matchData.team1,
                  matchData.team2,
                  matchData.matchStatus ?? '',
                ),
              ),
              const SizedBox(height: 50), // Add some space below the button

              // New Match button at the bottom
              _buildNewMatchButton(context, matchData),

              const SizedBox(height: 20), // Add some space below the button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPlayerAvatar(BuildContext context, String playerLabel) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2C2B2B),
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    heightFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: const AssetImage('assets/headphone.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Action for tapping the add player button (e.g., opening QRCode screen)
                    navigateUpWithSlideTransition(
                        context,
                        const QRCodeScreen(
                          viewType: ViewType.createMatch,
                        ));
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD20E0D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 24,
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
                  color: Colors
                      .white, // Ensure text is readable on dark background
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatarSelection(String matchType, List<MatchPlayer>? team1,
      List<MatchPlayer>? team2, String matchStatus) {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            team1 != null && team1.isNotEmpty
                ? _buildPlayerAvatar(
                    context,
                    0,
                    team1.first.gamertag,
                    team1.first.imageprofile,
                    team1.first.stationSpot,
                    matchStatus)
                : _buildAddPlayerAvatar(context, 'A'),
            if (matchType == '1v1')
              Flexible(
                child: Image.asset(
                  'assets/versus.png', // Replace with your image asset path
                  width: 60,
                  height: 60,
                ),
              ),
            team2 != null && team2.isNotEmpty
                ? _buildPlayerAvatar(
                    context,
                    1,
                    team2.first.gamertag,
                    team2.first.imageprofile,
                    team2.first.stationSpot,
                    matchStatus)
                : _buildAddPlayerAvatar(context, 'B'),
          ],
        ),
        if (matchType == '2v2')
          SizedBox(
            width:
                double.infinity, // Ensures the container takes the full width
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
        if (matchType == '2v2')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              team1 != null && team1.isNotEmpty
                  ? _buildPlayerAvatar(
                      context,
                      2,
                      team1.last.gamertag,
                      team1.last.imageprofile,
                      team1.last.stationSpot,
                      matchStatus)
                  : _buildAddPlayerAvatar(context, 'C'),
              team2 != null && team2.isNotEmpty
                  ? _buildPlayerAvatar(
                      context,
                      3,
                      team2.last.gamertag,
                      team2.last.imageprofile,
                      team2.last.stationSpot,
                      matchStatus)
                  : _buildAddPlayerAvatar(context, 'D'),
            ],
          ),
      ],
    );
  }

  Widget _buildPlayerAvatar(BuildContext context, int index, String playerLabel,
      String imageUrl, String stationSpot, String matchStatus) {
    return GestureDetector(
      onTap: () => (matchStatus == "in progress")
          ? _onAvatarTapped(index)
          : null, // Use index for unique avatar control
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _progressAnimations[index],
                builder: (context, child) {
                  return CustomPaint(
                    painter: CircularBorderPainter(
                      progress: _progressAnimations[index].value,
                    ),
                    child: child,
                  );
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2C2B2B),
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            playerLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSelection(
      BuildContext context, int index, String gameImage, String gameMatchType) {
    bool isSelected = _selectedGameIndex == index;

    double size = isSelected ? 115.0 : 65.0;
    double opacity = isSelected ? 1.0 : 0.5;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameIndex = index; // Set the selected game index
          matchType = gameMatchType;
        });
      },
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 600),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CachedNetworkImage(
            width: size,
            height: size,
            imageUrl: gameImage,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  // Build the "New Match" button
  Widget _buildNewMatchButton(BuildContext context, MatchDetails matchData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () => {
            if (matchData.matchStatus != "in progress")
              showCreateMatch(context, matchData)
            else if (matchData.matchStatus == "in progress")
              {_isAvatarSelected ? Navigator.pop(context) : null}
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(350, 58),
            disabledBackgroundColor: Colors.grey,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Text(
              (matchData.matchStatus != "in progress")
                  ? 'Create Match'
                  : (matchData.matchStatus == "created")
                      ? 'Start Match'
                      : 'End Match',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for circular border animation
class CircularBorderPainter extends CustomPainter {
  final double progress;

  CircularBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0XFF4BAE4F)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double startAngle = -3.14 / 2; // Start at the top
    final double sweepAngle = 2 * 3.14 * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CircularBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
