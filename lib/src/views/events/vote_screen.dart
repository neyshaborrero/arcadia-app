import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/vote_dialog.dart';
import 'package:arcadia_mobile/src/structure/survey_answers.dart';
import 'package:arcadia_mobile/src/structure/survey_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VoteScreen extends StatefulWidget {
  final SurveyDetails surveyDetails;
  final Function(bool) onVoteComplete;
  final bool showResults;

  const VoteScreen({
    super.key,
    required this.surveyDetails,
    required this.onVoteComplete,
    required this.showResults,
  });

  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  Map<String, bool> voteStatus = {};
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the vote status for each answer
    for (var answer in widget.surveyDetails.answers) {
      voteStatus[answer.answerId] = false;
    }
  }

  void _handleVoteSuccess(String answerId) {
    setState(() {
      voteStatus[answerId] = true;
      totalVotes += 1;

      if (totalVotes >= widget.surveyDetails.maxVotesPerUser) {
        widget.onVoteComplete(true); // Notify the parent widget
        Navigator.of(context).pop(); // Close the screen when max votes reached
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final columnCount = isTablet ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: !widget.showResults
            ? Text(widget.surveyDetails.description)
            : const Text("Survey Results"),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          const AdsCarouselComponent(viewType: ViewType.voteScreen),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: List.generate(
                          widget.surveyDetails.answers.length, (index) {
                        final SurveyAnswer answer =
                            widget.surveyDetails.answers[index];
                        final bool isVoted =
                            voteStatus[answer.answerId] ?? false;

                        return Container(
                          width: (screenWidth - (columnCount + 1) * 10) /
                              columnCount,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFFD20E0D).withOpacity(0.85),
                                const Color(0xFF020202).withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                answer.title,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 10),
                              if (answer.pictureUrl != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      width: 100,
                                      height: 85,
                                      imageUrl: answer.pictureUrl!,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    if (widget.showResults)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '${answer.percentage.toStringAsFixed(1)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 15),
                              if (!widget.showResults)
                                FractionallySizedBox(
                                  widthFactor: 0.9,
                                  child: ElevatedButton(
                                    onPressed: isVoted
                                        ? null
                                        : () async {
                                            final bool? success =
                                                await showVoteDialog(
                                              context,
                                              answer.title,
                                              answer.pictureUrl,
                                              widget.surveyDetails.id,
                                              answer.answerId,
                                            );

                                            if (success != null && success) {
                                              _handleVoteSuccess(
                                                  answer.answerId);
                                            }
                                          },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty
                                          .resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.disabled)) {
                                            return const Color(
                                                0xFF4BAE4F); // Color when disabled (voted)
                                          }
                                          return const Color(
                                              0xFFD20E0D); // Default color (not voted)
                                        },
                                      ),
                                    ),
                                    child: Text(
                                      isVoted ? 'Voted' : 'Vote',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
