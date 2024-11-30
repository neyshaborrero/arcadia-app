import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/create_match_dialog.dart';
import 'package:arcadia_mobile/src/structure/game.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arcadia_mobile/src/structure/match_player.dart';
import 'package:provider/provider.dart';

import '../../structure/station.dart';

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

class _MatchViewState extends State<MatchView> with TickerProviderStateMixin {
  late int _selectedGameIndex;
  String matchType = '1v1';
  late final ArcadiaCloud _arcadiaCloud;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _progressAnimations;
  final int numberOfAvatars = 4;
  bool isWinnerSelectionEnabled = false;
  bool isAvatarSelected = true;
  late MatchDetails matchDetails;

  // Track which team is selected as the winner
  String? _selectedWinner; // "team1" or "team2"

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
        gameId: widget.hubDetails.games[1].gameId,
        matchStatus: 'created',
        matchType: '1v1', // Provide a default match type
        team1: [], // An empty list for team1
        team2: [], // An empty list for team2
        team3: [], // An empty list for team2
        team4: [], // An empty list for team2
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

    if (matchDetails.matchType != null && matchDetails.matchType!.isNotEmpty) {
      matchType = matchDetails.matchType!;
    }

    if (matchDetails.matchStatus != 'created') {
      _selectedGameIndex = widget.hubDetails.games.indexWhere(
        (game) => game.gameId == matchDetails.gameId,
      );

      // If no matching gameId is found, set default to index 0
      if (_selectedGameIndex == -1) {
        _selectedGameIndex = 0;
      }
    } else {
      // Default to the first game if the matchStatus is 'created'
      _selectedGameIndex = 0;
    }

    isAvatarSelected = matchDetails.matchStatus == "in progress" ? false : true;

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

  // Method to change the match status to "completed" after selecting a winner
  Future<bool> _changeMatchStatus(String status, String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();

    if (token == null || matchDetails.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get authentication token')),
      );
      return false;
    }

    // Change the match status to 'completed'
    bool success = await _arcadiaCloud.changeMatchStatus(
        status, matchDetails.id!, hubId, token);

    if (success) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to $status the match')),
      );
      return false;
    }
  }

  Widget buildStartMatchButton(String hubId) {
    return ElevatedButton(
      onPressed: matchDetails.matchStatus == 'ready'
          ? () async {
              // Call method to change the match status to 'in progress'
              bool success = await _changeMatchStatus('in progress', hubId);
              if (success) {
                Navigator.of(context).pop("refresh");
                setState(() {
                  // Update local match status to reflect the change
                  matchDetails.matchStatus = 'in progress';
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to start match')),
                );
              }
            }
          : null, // Disable the button if matchStatus is not 'ready'
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(350, 58),
        backgroundColor: matchDetails.matchStatus == 'ready'
            ? const Color(0XFF4BAE4F) // Your signature green color
            : Colors.grey, // Disabled state color
        disabledBackgroundColor:
            Colors.grey, // Color when the button is disabled
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        child: Text('Start Match', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  // Method to change the match status before enabling winner selection
  Future<void> _startMatch(String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();

    if (token == null || matchDetails.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get authentication token')),
      );
      return;
    }

    // Change the match status to 'in progress'
    bool success = await _arcadiaCloud.changeMatchStatus(
        'in progress', matchDetails.id!, hubId, token);

    if (success) {
      setState(() {
        isWinnerSelectionEnabled =
            true; // Enable winner selection after match starts
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match started. Select the winner.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start the match')),
      );
    }
  }

  Future<MatchPlayer?> _addPlayer(
      String userId,
      String playerSlot,
      String gameId,
      String matchId,
      String matchType,
      String hubId,
      String stationId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken();

    if (token == null) return null;

    final MatchPlayer? response = await _arcadiaCloud.addPlayerArcadiaMatch(
      gameId,
      matchId,
      playerSlot,
      userId,
      matchType,
      stationId,
      hubId,
      token,
    );

    return response;
  }

  // Method to call the setMatchWinner API
  Future<void> _endMatch(String hubId) async {
    if (_selectedWinner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a winner')),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();

    if (token == null || matchDetails.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get authentication token')),
      );
      return;
    }

    // First, update the match status to 'completed'
    await _changeMatchStatus("completed", hubId);

    // Call setMatchWinner API
    bool success = await _arcadiaCloud.setMatchWinner(
      _selectedWinner == 'team1' ? '1' : '2', // Pass 1 for team1, 2 for team2
      matchDetails.id!,
      hubId,
      token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match Winner Declared')),
      );
      Navigator.pop(context, 'refresh'); // Refresh the view
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set match winner')),
      );
    }
  }

  Future<bool> _deleteArcadiaMatch(String matchId, String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();

    if (token == null) return false;

    final bool response =
        await _arcadiaCloud.deleteArcadiaMatch(matchId, hubId, token);
    return response;
  }

  void deleteMatch(String? matchId, String hubId) async {
    if (matchId != null) {
      bool deleteMatch = await _deleteArcadiaMatch(matchId, hubId);
      if (deleteMatch) {
        Navigator.pop(context, 'refresh');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed delete match. Try again later')),
        );
      }
    }
  }

  void getMatchReady(MatchDetails matchData, String hubId) async {
    if (matchData.id != null) {
      var didChange = await _changeMatchStatus('ready', hubId);

      if (didChange) showCreateMatch(context, matchData, hubId);
    }
  }

  // Method to handle avatar tap
  void _onAvatarTapped(int index) {
    setState(() {
      isAvatarSelected = true;

      if (matchDetails.matchType == '1v1') {
        // For 1v1, we have two avatars, one for each team
        if (index == 0) {
          _selectedWinner = 'team1'; // Tapped team 1
        } else if (index == 1) {
          _selectedWinner = 'team2'; // Tapped team 2
        }

        // Animate the tapped avatar
        for (int i = 0; i < _controllers.length; i++) {
          if (i == index) {
            _controllers[i].forward(from: 0.0);
          } else {
            _controllers[i].reset();
          }
        }
      } else if (matchDetails.matchType == '2v2') {
        // For 2v2, handle the animation logic here
        if (index == 0 || index == 1) {
          _selectedWinner = 'team1'; // Tapped team 1
          _controllers[0].forward(from: 0.0);
          _controllers[1].forward(from: 0.0);
          _controllers[2].reset(); // Reset team2 animations
          _controllers[3].reset();
        } else if (index == 2 || index == 3) {
          _selectedWinner = 'team2'; // Tapped team 2
          _controllers[2].forward(from: 0.0);
          _controllers[3].forward(from: 0.0);
          _controllers[0].reset(); // Reset team1 animations
          _controllers[1].reset();
        }
      } else if (matchDetails.matchType == '1v1v1v1') {
        // For 1v1v1v1, each index corresponds to a different team
        if (index == 0) {
          _selectedWinner = 'team1'; // Team 1 is the winner
        } else if (index == 1) {
          _selectedWinner = 'team2'; // Team 2 is the winner
        } else if (index == 2) {
          _selectedWinner = 'team3'; // Team 3 is the winner
        } else if (index == 3) {
          _selectedWinner = 'team4'; // Team 4 is the winner
        }

        // Animate the tapped avatar, reset the others
        for (int i = 0; i < _controllers.length; i++) {
          if (i == index) {
            _controllers[i]
                .forward(from: 0.0); // Start animation for selected avatar
          } else {
            _controllers[i].reset(); // Reset animation for other avatars
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MatchDetails matchData = matchDetails;
    // Find the selected game based on matchDetails.gameId
    Game? selectedGame = widget.hubDetails.games.firstWhere(
      (game) => game.gameId == matchData.gameId,
      orElse: () => widget
          .hubDetails.games[0], // Default to the first game if no match found
    );

    // Find the station based on the selected game
    String selectedStationName = widget.hubDetails.stations.values
        .firstWhere(
          (station) => station.gameId == selectedGame.gameId,
          orElse: () => Station(
            id: 'unknown',
            gameId: 'unknown',
            name: 'Unknown Station',
            status: 'available',
          ),
        )
        .name;
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
        actions: matchDetails.matchStatus != 'in progress'
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.delete_forever_sharp,
                    color: Color(0xFFD20E0D), // Your signature red color
                    size: 40, // Increase the size of the icon
                  ),
                  onPressed: () {
                    if (widget.matchData?.id != null &&
                        widget.matchData!.id!.isNotEmpty) {
                      // var matchId = widget.matchData?.id!;
                      deleteMatch(widget.matchData!.id, widget.hubId);
                    }
                  },
                ),
              ]
            : [],

        automaticallyImplyLeading: matchDetails.matchStatus == 'created'
            ? false
            : true, // Enable back button
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
              const SizedBox(height: 20),

              if (matchData.matchStatus != "in progress")
                Column(
                  children: [
                    // Display the name of the currently selected game
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "${selectedGame.name} ${selectedGame.type}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Only show one game if match status is not created
                    if (matchData.matchStatus != 'created')
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _buildGameSelection(
                          context,
                          widget.hubDetails.games.indexOf(selectedGame),
                          selectedGame.image,
                          selectedGame.type,
                          selectedStationName,
                        ),
                      )
                    else
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
                                        child: _buildGameSelection(
                                          context,
                                          index,
                                          game.image,
                                          game.type,
                                          widget.hubDetails.stations.values
                                              .firstWhere(
                                                  (station) =>
                                                      station.gameId ==
                                                      game.gameId,
                                                  orElse: () => Station(
                                                      id: '422',
                                                      gameId: '3242',
                                                      status: 'available',
                                                      name: 'Unknown Station'))
                                              .name,
                                        ), // Game image
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
                    matchData.team3,
                    matchData.team4,
                    matchData.matchStatus ?? '',
                    matchData),
              ),
              const SizedBox(height: 50), // Add some space below the button

              // New Match button at the bottom
              _buildMatchControlButtons(context, matchData),

              const SizedBox(height: 20), // Add some space below the button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPlayerAvatar(
    BuildContext context,
    String playerLabel,
    MatchDetails match,
  ) {
    return Column(
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
                onTap: () async {
                  final String result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRCodeScreen(
                        viewType: ViewType.createMatch,
                      ),
                    ),
                  );

                  if (result.isNotEmpty) {
                    final MatchPlayer? player = await _addPlayer(
                        result,
                        playerLabel,
                        widget.hubDetails.games[_selectedGameIndex].gameId,
                        match.id ?? '',
                        matchType,
                        widget.hubId,
                        widget.hubDetails.getStationIdByGameId(widget
                                .hubDetails.games[_selectedGameIndex].gameId) ??
                            '');

                    setState(() {
                      if (player != null) {
                        if (matchType == '1v1') {
                          if (playerLabel == 'A') {
                            matchDetails.team1?.add(player);
                          } else if (playerLabel == 'B') {
                            matchDetails.team2?.add(player);
                          }
                        } else if (matchType == '2v2') {
                          if (playerLabel == 'A') {
                            matchDetails.team1?.add(player);
                          } else if (playerLabel == 'B') {
                            matchDetails.team1?.add(player);
                          } else if (playerLabel == 'C') {
                            matchDetails.team2?.add(player);
                          } else if (playerLabel == 'D') {
                            matchDetails.team2?.add(player);
                          }
                        } else if (matchType == '1v1v1v1') {
                          // Handle 1v1v1v1
                          if (playerLabel == 'A') {
                            matchDetails.team1?.add(player); // Team 1
                          } else if (playerLabel == 'B') {
                            matchDetails.team2?.add(player); // Team 2
                          } else if (playerLabel == 'C') {
                            matchDetails.team3?.add(player); // Team 3
                          } else if (playerLabel == 'D') {
                            matchDetails.team4?.add(player); // Team 4
                          }
                        }
                      }
                    });
                  }
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
                color:
                    Colors.white, // Ensure text is readable on dark background
              ),
        ),
      ],
    );
  }

  Widget _buildPlayerAvatarSelection(
      String matchType,
      List<MatchPlayer>? team1,
      List<MatchPlayer>? team2,
      List<MatchPlayer>? team3,
      List<MatchPlayer>? team4,
      String matchStatus,
      MatchDetails match) {
    // Function to find player based on the station spot
    MatchPlayer? getPlayerForSpot(String spot, List<MatchPlayer>? team) {
      if (team != null) {
        for (var player in team) {
          if (player.stationSpot == spot) {
            return player;
          }
        }
      }
      return null; // Return null if no player found for that spot
    }

    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Player spots for both 1v1 and 2v2
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Spot A (Station Spot "A")
            getPlayerForSpot('A', team1) != null
                ? _buildPlayerAvatar(
                    context,
                    0, // Spot A
                    getPlayerForSpot('A', team1)!.gamertag,
                    getPlayerForSpot('A', team1)!.imageprofile,
                    'A', // Station spot A
                    matchStatus,
                  )
                : _buildAddPlayerAvatar(context, 'A', match),

            if (matchType == '1v1')
              Flexible(
                child: Image.asset(
                  'assets/versus.png',
                  width: 60,
                  height: 60,
                ),
              ),

            // Spot B (Station Spot "B")
            if (matchType == '1v1')
              // For 1v1, check Spot B in team1 first, then team2
              getPlayerForSpot('B', team1) != null
                  ? _buildPlayerAvatar(
                      context,
                      1, // Spot B
                      getPlayerForSpot('B', team1)!.gamertag,
                      getPlayerForSpot('B', team1)!.imageprofile,
                      'B', // Station spot B
                      matchStatus,
                    )
                  : getPlayerForSpot('B', team2) != null
                      ? _buildPlayerAvatar(
                          context,
                          1, // Spot B
                          getPlayerForSpot('B', team2)!.gamertag,
                          getPlayerForSpot('B', team2)!.imageprofile,
                          'B', // Station spot B
                          matchStatus,
                        )
                      : _buildAddPlayerAvatar(context, 'B', match),

            if (matchType == '1v1v1v1')
              // In 1v1v1v1, Spot A is Team 1, Spot B is Team 2, Spot C is Team 3, Spot D is Team 4
              getPlayerForSpot('B', team2) != null
                  ? _buildPlayerAvatar(
                      context,
                      1, // Spot B for Team 2
                      getPlayerForSpot('B', team2)!.gamertag,
                      getPlayerForSpot('B', team2)!.imageprofile,
                      'B', // Station spot B for Team 2
                      matchStatus,
                    )
                  : _buildAddPlayerAvatar(context, 'B', match),

            if (matchType == '2v2')
              // For 2v2, check Spot B in team1
              getPlayerForSpot('B', team1) != null
                  ? _buildPlayerAvatar(
                      context,
                      1, // Spot B
                      getPlayerForSpot('B', team1)!.gamertag,
                      getPlayerForSpot('B', team1)!.imageprofile,
                      'B', // Station spot B
                      matchStatus,
                    )
                  : _buildAddPlayerAvatar(context, 'B', match),
          ],
        ),

        if (matchType == '2v2') ...[
          // Versus Image for 2v2 with the line
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

          // Second row for 2v2: Spots C and D
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Spot C (Station Spot "C")
              getPlayerForSpot('C', team2) != null
                  ? _buildPlayerAvatar(
                      context,
                      2, // Spot C
                      getPlayerForSpot('C', team2)!.gamertag,
                      getPlayerForSpot('C', team2)!.imageprofile,
                      'C', // Station spot C
                      matchStatus,
                    )
                  : _buildAddPlayerAvatar(context, 'C', match),

              // Spot D (Station Spot "D")
              getPlayerForSpot('D', team2) != null
                  ? _buildPlayerAvatar(
                      context,
                      3, // Spot D
                      getPlayerForSpot('D', team2)!.gamertag,
                      getPlayerForSpot('D', team2)!.imageprofile,
                      'D', // Station spot D
                      matchStatus,
                    )
                  : _buildAddPlayerAvatar(context, 'D', match),
            ],
          ),
        ],

        if (matchType == '1v1v1v1') ...[
          // Versus Image for 2v2 with the line
          SizedBox(
            width:
                double.infinity, // Ensures the container takes the full width
            child: Stack(
              alignment: Alignment.center, // Center the image and the line
              children: [
                Image.asset(
                  'assets/versus.png', // Replace with your image asset path
                  width: 60,
                  height: 60,
                ),
              ],
            ),
          ),

          // Second row for 2v2: Spots C and D
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Spot C (Station Spot "C")
              getPlayerForSpot('C', team3) != null
                  ? _buildPlayerAvatar(
                      context,
                      2, // Spot C
                      getPlayerForSpot('C', team3)!.gamertag,
                      getPlayerForSpot('C', team3)!.imageprofile,
                      'C', // Station spot C
                      matchStatus,
                    )
                  : _buildAddPlayerAvatar(context, 'C', match),

              // Spot D (Station Spot "D")
              getPlayerForSpot('D', team4) != null
                  ? _buildPlayerAvatar(
                      context,
                      3, // Spot D
                      getPlayerForSpot('D', team4)!.gamertag,
                      getPlayerForSpot('D', team4)!.imageprofile,
                      'D', // Station spot D
                      matchStatus,
                    )
                  : _buildAddPlayerAvatar(context, 'D', match),
            ],
          ),
        ],
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
                child: GestureDetector(
                    onTap: () async {
                      if (matchStatus == "created") {
                        final String result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeScreen(
                              viewType: ViewType.createMatch,
                            ),
                          ),
                        );

                        if (result.isNotEmpty) {
                          //_addPlayer(result,playerSlo)
                        }
                      }
                    },
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
                    )),
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

  Widget _buildGameSelection(BuildContext context, int index, String gameImage,
      String gameMatchType, String stationName) {
    bool isSelected = _selectedGameIndex == index;
    double size = isSelected ? 115.0 : 65.0;
    double opacity = isSelected ? 1.0 : 0.5;

    Widget gameSelectionContent = Column(children: [
      AnimatedOpacity(
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
      Text(stationName),
    ]);

    // Conditionally wrap the content in a GestureDetector if matchStatus is 'created'
    if (matchDetails.matchStatus == 'created') {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedGameIndex = index; // Set the selected game index
            print("game match type $gameMatchType");
            matchType = gameMatchType;
            matchDetails.team2 = [];
            matchDetails.team1 = [];
            matchDetails.team3 = [];
            matchDetails.team4 = [];
          });
        },
        child: gameSelectionContent,
      );
    } else {
      // Return content without GestureDetector if matchStatus is not 'created'
      return gameSelectionContent;
    }
  }

  Widget _buildMatchControlButtons(
      BuildContext context, MatchDetails matchData) {
    Widget buildEndMatchButton() {
      return ElevatedButton(
        onPressed: matchData.matchStatus == 'in progress'
            ? () {
                _endMatch(widget.hubId); // End match and set winner
              }
            : null,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(350, 58),
          disabledBackgroundColor: Colors.grey,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: Text('End Match', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    Widget buildCreateMatchButton(String hubId) {
      return ElevatedButton(
        onPressed: () async {
          // Fetch the selected game and station info based on _selectedGameIndex
          final selectedGame = widget.hubDetails.games[_selectedGameIndex];
          final selectedStationId =
              widget.hubDetails.getStationIdByGameId(selectedGame.gameId);

          // Check if the station is found
          if (selectedStationId != null &&
              widget.hubDetails.stations.containsKey(selectedStationId)) {
            final selectedStation =
                widget.hubDetails.stations[selectedStationId];

            // Update the matchDetails with the selected game and station
            setState(() {
              matchDetails.game =
                  selectedGame; // Set the selected game in matchDetails
              matchDetails.stationId =
                  selectedStationId; // Set the stationId in matchDetails
              matchDetails.station =
                  selectedStation; // Set the corresponding station object
              matchDetails.gameId =
                  selectedGame.gameId; // Set the gameId in matchDetails
            });

            // Call the _changeMatchStatus function and wait for its result
            bool success = await _changeMatchStatus('ready', hubId);

            // If the status change is successful, show the dialog
            if (success) {
              // Show the dialog and wait for its result
              await showCreateMatch(context, matchDetails, hubId);
              Navigator.pop(context, 'refresh');
            } else {
              // Handle the failure case with a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create match')),
              );
            }
          } else {
            // If no station is found, display an error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No station found for the selected game')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(350, 58),
          disabledBackgroundColor: Colors.grey,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: Text('Create Match', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          if (matchData.matchStatus == 'created')
            buildCreateMatchButton(widget.hubId),
          if (matchData.matchStatus == 'ready')
            buildStartMatchButton(widget.hubId),
          if (matchData.matchStatus == "in progress") buildEndMatchButton(),
        ],
      ),
    );
  }
}

// Custom Painter for circular border animation
class CircularBorderPainter extends CustomPainter {
  final double progress;

  CircularBorderPainter({required this.progress});

  get showProgress => null;

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
