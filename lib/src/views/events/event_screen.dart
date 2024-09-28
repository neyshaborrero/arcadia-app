import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/survey_container.dart';
import 'package:arcadia_mobile/src/structure/survey_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/loading.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arcadia_mobile/src/tools/is_tablet.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  Future<List<SurveyDetails>>? _surveyDetailsFuture;
  late final ArcadiaCloud _arcadiaCloud;
  late final User? user;

  @override
  void initState() {
    super.initState();

    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);

    // Fetch the surveys when the state initializes
    _surveyDetailsFuture = _fetchSurveys();
  }

  // Callback to be triggered when a vote is completed with the surveyId
  void _onVoteComplete(String surveyId) {
    // Re-fetch the survey details to update the UI with new percentages
    setState(() {
      _surveyDetailsFuture = _fetchSurveyDetails(surveyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = isTablet(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          const AdsCarouselComponent(viewType: ViewType.quest),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  // Fetch and display surveys
                  Expanded(
                    child: FutureBuilder<List<SurveyDetails>>(
                      future: _surveyDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Show shimmer effect while loading
                          return ListView.builder(
                            itemCount: 6, // Number of shimmer loading cards
                            itemBuilder: (context, index) {
                              return buildShimmerSurveyContainer();
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No surveys available.');
                        } else {
                          final surveyDetailsList = snapshot.data!;
                          return ListView.builder(
                            itemCount: surveyDetailsList.length,
                            itemBuilder: (context, index) {
                              return SurveyContainer(
                                surveyDetails: surveyDetailsList[index],
                                onVoteComplete: (String surveyId) {
                                  // Handle the vote completion, such as re-fetching the survey details
                                  _onVoteComplete(
                                      surveyId); // This can re-fetch updated survey data
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: tablet ? 400 : 200),
                    child: ElevatedButton(
                      onPressed: () =>
                          launchURL(Uri.parse('https://prticket.sale/ARCADIA')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(tablet ? 70 : 50),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tablet ? 20 : 10,
                          vertical: tablet ? 20 : 10,
                        ),
                        child: Text(
                          'Buy Tickets',
                          style: TextStyle(fontSize: tablet ? 24 : 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<SurveyDetails>> _fetchSurveys() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken();

    if (token == null) return [];

    final List<SurveyDetails> surveys = await _arcadiaCloud.fetchSurveys(token);
    return surveys;
  }

  // Method to fetch the specific survey details (this will include updated percentages)
  Future<List<SurveyDetails>> _fetchSurveyDetails(String surveyId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken();

    if (token == null) return [];

    final List<SurveyDetails> surveys =
        await _arcadiaCloud.fetchSurveyDetails(token, surveyId);
    return surveys;
  }
}
