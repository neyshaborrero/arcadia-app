import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/gamematch_container.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/hub_checkout.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/bounties/bounty_view.dart';
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
  ViewType _currentView = ViewType.createMatch;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _hubMatchesFuture = _fetchMatches(widget.hubId);
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

  Future<void> _refreshMatches() async {
    setState(() {
      _hubMatchesFuture = _fetchMatches(widget.hubId);
    });
  }

  Future<bool> _hubCheckout(String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    if (token == null) return false;

    final HubCheckOut response =
        await _arcadiaCloud.checkoutOperator(hubId, token);
    return response.success;
  }

  Future<MatchDetails?> _createMatch(String hubId, String eventId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken();
    if (token == null) return null;

    return await _arcadiaCloud.createArcadiaMatch(
        null, eventId, hubId, null, null, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(widget.hubDetails.name),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  AppBar _buildAppBar(String hubName) {
    return AppBar(
      title: _currentView == ViewType.createMatch
          ? Text(hubName)
          : Text("$hubName Bounties"),
      centerTitle: true,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.report_problem_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentView) {
      case ViewType.bounties:
        return const BountiesView(
          token: '',
        );
      case ViewType.createMatch:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<MatchDetails>>(
                  future: _hubMatchesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching matches'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildGameActivityContainer(context);
                    } else {
                      return RefreshIndicator(
                        onRefresh: _refreshMatches,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: MatchContainer(
                            hubId: widget.hubId,
                            hubMatches: snapshot.data!,
                            hubDetails: widget.hubDetails,
                            onRefreshMatches: _refreshMatches,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildNewMatchButton(context, widget.hubDetails, widget.hubId),
              const SizedBox(height: 10),
              _buildCheckOutButton(context, widget.hubId),
              const SizedBox(height: 30),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<MatchDetails>>(
                  future: _hubMatchesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching matches'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildGameActivityContainer(context);
                    } else {
                      return RefreshIndicator(
                        onRefresh: _refreshMatches,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: MatchContainer(
                            hubId: widget.hubId,
                            hubMatches: snapshot.data!,
                            hubDetails: widget.hubDetails,
                            onRefreshMatches: _refreshMatches,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildNewMatchButton(context, widget.hubDetails, widget.hubId),
              const SizedBox(height: 10),
              _buildCheckOutButton(context, widget.hubId),
              const SizedBox(height: 30),
            ],
          ),
        );
    }
  }

  Widget _buildBottomAppBar() {
    return Container(
        height: MediaQuery.of(context).size.height *
            0.12, // 10% of screen height, // You can define the height you want
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.black, // Background color of BottomAppBar
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  offset: const Offset(0, -2), // Direction of the shadow
                  spreadRadius:
                      0, // Negative spread radius to create the inner shadow effect
                  blurRadius: 10, // Blur radius
                ),
              ],
            ),
            child: BottomAppBar(
              color: Colors.black,
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.person,
                        color: _currentView == ViewType.createMatch
                            ? const Color(0xFFD20E0D)
                            : Colors.white),
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.createMatch;
                      });
                    },
                  ),
                  const SizedBox(width: 48), // Space for FAB
                  IconButton(
                    icon: Icon(Icons.event,
                        color: _currentView == ViewType.bounties
                            ? const Color(0xFFD20E0D)
                            : Colors.white),
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.bounties;
                      });
                    },
                  ),
                ],
              ),
            )));
  }

  Widget _buildGameActivityContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2B2B),
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

  Widget _buildGameActivityContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/scan_activity.png',
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
            text: 'Start a ',
            style: Theme.of(context).textTheme.bodyLarge,
            children: const <TextSpan>[
              TextSpan(
                text: 'New Match',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNewMatchButton(
      BuildContext context, Hub hubDetails, String hubId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () => {createNewMatch(hubDetails, hubId)},
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

  Widget _buildCheckOutButton(BuildContext context, String hubId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: OutlinedButton(
          onPressed: () async => {
            if (await _hubCheckout(hubId))
              {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (Route<dynamic> route) => false,
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

  void createNewMatch(Hub hubDetails, String hubId) async {
    MatchDetails? matchDetails = await _createMatch(hubId, hubDetails.eventId);

    if (matchDetails != null) {
      var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchView(
            matchData: matchDetails,
            hubDetails: hubDetails,
            hubId: widget.hubId,
          ),
        ),
      );

      if (result == 'refresh') {
        _refreshMatches();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Something went wrong. Try creating a match later')),
      );
    }
  }
}
