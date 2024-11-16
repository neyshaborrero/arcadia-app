import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/structure/bounty.dart';
import 'package:arcadia_mobile/src/views/bounties/bounty_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BountiesView extends StatefulWidget {
  final String token;

  const BountiesView({super.key, required this.token});

  @override
  _BountiesViewState createState() => _BountiesViewState();
}

class _BountiesViewState extends State<BountiesView> {
  late Future<List<Bounty>> _bountiesFuture;
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _bountiesFuture = _fetchBounties();
  }

  Future<List<Bounty>> _fetchBounties() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken();
    if (token == null) return [];

    final List<Bounty> response = await _arcadiaCloud.getBounties(token);
    print("bounties, $response");
    return response.isNotEmpty ? response : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Bounty>>(
        future: _bountiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load bounties'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bounties available'));
          } else {
            // Pass the loaded bounties to BountiesList
            return BountiesList(bounties: snapshot.data!);
          }
        },
      ),
    );
  }
}
