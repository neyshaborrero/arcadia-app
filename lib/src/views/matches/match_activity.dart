import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/gamematch_container.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/hub_checkout.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/tools/slides.dart';
import 'package:arcadia_mobile/src/views/matches/match_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameActivityView extends StatefulWidget {
  final String hubId;
  final Hub hubDetails;
  const GameActivityView(
      {super.key, required this.hubId, required this.hubDetails});

  @override
  _GameActivityViewState createState() => _GameActivityViewState();
}

class _GameActivityViewState extends State<GameActivityView> {
  late final ArcadiaCloud _arcadiaCloud;
  late Future<List<MatchDetails>> _hubMatchesFuture;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _hubMatchesFuture = _fetchMatches(widget.hubId); // Initialize the Future
  }

  Future<List<MatchDetails>> _fetchMatches(String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken();

    if (token == null) return [];

    final List<MatchDetails> response =
        await _arcadiaCloud.getArcadiaMatches(hubId, token);
    return response.isNotEmpty ? response : [];
  }

  Future<bool> _hubCheckout(String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();

    if (token == null) return false;

    final HubCheckOut response =
        await _arcadiaCloud.checkoutOperator(hubId, token);

    if (response.success) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Expanded widget to take up remaining space
            Expanded(
              child: FutureBuilder<List<MatchDetails>>(
                future: _hubMatchesFuture, // Pass the future here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show loading indicator while fetching matches
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Handle errors while fetching data
                    return const Center(child: Text('Error fetching matches'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Show no matches available if the list is empty
                    return _buildGameActivityContainer(context);
                  } else {
                    // Show the MatchContainer with fetched matches
                    return SingleChildScrollView(
                      child: MatchContainer(
                        hubId: widget.hubId,
                        hubMatches: snapshot.data!, // Pass the fetched matches
                        hubDetails: widget.hubDetails,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20), // Space before the buttons

            // Buttons at the bottom
            _buildNewMatchButton(context, widget.hubDetails),
            const SizedBox(height: 10), // Space between buttons
            _buildCheckOutButton(context, widget.hubId),
            const SizedBox(height: 30), // Add some space below the buttons
          ],
        ),
      ),
    );
  }

  // AppBar Widget
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Operator'),
      centerTitle: true,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.report_problem_rounded, color: Colors.white),
          onPressed: () {
            // Add your onPressed functionality here
          },
        ),
      ],
    );
  }

  // Game Activity Container for No Matches
  Widget _buildGameActivityContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2B2B), // Custom color
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          const Text(
            'Game Activity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Spacer(),
          _buildGameActivityContent(context),
          const Spacer(),
        ],
      ),
    );
  }

  // Content in the Game Activity Section
  Widget _buildGameActivityContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/scan_activity.png', // Replace with your image path
          height: 150,
        ),
        const SizedBox(height: 20),
        Text(
          'You have no active games.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text.rich(
          TextSpan(
            text: 'Start a ', // Regular part
            style: Theme.of(context).textTheme.bodyLarge,
            children: const <TextSpan>[
              TextSpan(
                text: 'New Match', // Part you want to make bold
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Button for New Match
  Widget _buildNewMatchButton(BuildContext context, Hub hubDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () => {
            navigateUpWithSlideTransition(
                context,
                MatchView(
                  matchData: null,
                  hubDetails: hubDetails,
                  hubId: widget.hubId,
                ))
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Text(
              'New Match',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  // Button for Check-Out
  Widget _buildCheckOutButton(BuildContext context, String hubId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: OutlinedButton(
          onPressed: () async => {
            if (await _hubCheckout(hubId))
              {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // Replace '/' with your initial route name
                  (Route<dynamic> route) =>
                      false, // This clears all previous routes
                )
              }
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Text(
              'Check-Out',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
