import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/db_listener_service.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/services/network_status_checker.dart';
import 'package:arcadia_mobile/src/components/matches/bounty_countdown_modal.dart';
import 'package:arcadia_mobile/src/components/matches/final_competition_modal.dart';
import 'package:arcadia_mobile/src/components/matches/match_in_progress_modal.dart';
import 'package:arcadia_mobile/src/components/matches/match_lost_modal.dart';
import 'package:arcadia_mobile/src/components/matches/match_won_modal.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/bounty.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/views/start/error_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GlobalDBListener extends StatefulWidget {
  final Widget child;

  const GlobalDBListener({super.key, required this.child});

  @override
  _GlobalDBListenerState createState() => _GlobalDBListenerState();
}

class _GlobalDBListenerState extends State<GlobalDBListener> {
  late final ArcadiaCloud _arcadiaCloud;
  Future<MatchDetails?>? _matchDetailsFuture;
  Future<Bounty?>? _bountyDetailsFuture;
  //late NetworkStatusChecker _networkStatusChecker;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);

    // _networkStatusChecker =
    //     Provider.of<NetworkStatusChecker>(context, listen: false);

    // // Listen for connectivity changes
    // _networkStatusChecker.onConnectivityChanged.listen((connectivityResults) {
    //   print("whifi issue");
    //   if (!connectivityResults.contains(ConnectivityResult.wifi)) {
    //     // If no Wi-Fi, navigate to ErrorScreen
    //     Future.microtask(() {
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(
    //           builder: (context) => const ErrorScreen(isWifi: false),
    //         ),
    //       );
    //     });
    //   }
    // });
  }

  Future<MatchDetails?> _fetchMatchDetails(String hubId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not authenticated");
      return null;
    }

    final token = await user.getIdToken();
    if (token == null) {
      print("Unable to retrieve token");
      return null;
    }

    try {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      UserProfile? userProfile = userProfileProvider.userProfile;

      if (userProfile != null) {
        final currentMatchId =
            Provider.of<DatabaseListenerService>(context, listen: false)
                .currentMatchValue;
        return await _arcadiaCloud.getMatch(
            userProfile.playerCurrentHub, currentMatchId, token);
      }
    } catch (e) {
      print("Error fetching match details: $e");
    }
    return null;
  }

  Future<Bounty?> _fetchBountyDetails(String bountyId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not authenticated");
      return null;
    }

    final token = await user.getIdToken();
    if (token == null) {
      print("Unable to retrieve token");
      return null;
    }

    try {
      return await _arcadiaCloud.fetchBountyDetails(token, bountyId);
    } catch (e) {
      print("Error fetching bounty details: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseListenerService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);
    late int winStreak;
    String currentValue = databaseService.currentMatchValue;

    if (currentValue.isNotEmpty && int.tryParse(currentValue) != null) {
      winStreak = int.parse(currentValue);
    } else {
      winStreak = 0;
    }

    // Initialize the listener
    databaseService.initializeListener();

    // Set up the match details fetching when currentMatchValue changes
    if (databaseService.currentMatchValue.length > 4) {
      _matchDetailsFuture =
          _fetchMatchDetails(databaseService.currentMatchValue);
    }

    if (databaseService.thirdListenerValue.isNotEmpty) {
      final bountyId = databaseService.thirdListenerValue;
      _bountyDetailsFuture = _fetchBountyDetails(bountyId);
    }

    // Handle navigation based on secondListenerValue
    if (databaseService.secondListenerValue) {
      Future.microtask(() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print("User not authenticated");
          return;
        }

        await firebaseService.writeToDatabase(
          '/users/${user.uid}/refresh',
          false,
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (Route<dynamic> route) => false,
        );
      });
    }

    return Stack(
      children: [
        widget.child,
        if (databaseService.currentMatchValue.length > 4)
          FutureBuilder<MatchDetails?>(
            future: _matchDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(
                  child: Text(
                    'Failed to load match details',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.8),
                    child: MatchInProgressModal(
                      matchDetails: snapshot.data!,
                    ),
                  ),
                );
              }
            },
          ),
        if (winStreak > 0)
          MatchWonModal(
            firebaseService: firebaseService,
            winXp: winStreak * 100,
          ),
        if (winStreak == -100)
          FinalCompetitionModal(firebaseService: firebaseService),
        if (winStreak == -1) MatchLostModal(firebaseService: firebaseService),
        if (databaseService.thirdListenerValue.isNotEmpty)
          FutureBuilder<Bounty?>(
            future: _bountyDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(
                  child: Text(
                    'Failed to load bounty details',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return BountyCountdownModal(
                  firebaseService: firebaseService,
                  bounty: snapshot.data!,
                );
              }
            },
          ),
      ],
    );
  }
}
