import 'package:arcadia_mobile/src/components/vote_dialog.dart';
import 'package:arcadia_mobile/src/notifiers/survey_vote_status_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/survey_answers.dart';
import 'package:arcadia_mobile/src/structure/survey_details.dart';
import 'package:arcadia_mobile/src/tools/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeIfEmpty();
    });
  }

  void _handleVoteSuccess(String answerId) {
    final voteStatusNotifier =
        Provider.of<VoteStatusNotifier>(context, listen: false);

    setState(() {
      voteStatusNotifier.updateVoteStatus(answerId, true);
    });

    // Check if the user has reached the maximum votes
    if (voteStatusNotifier.voteStatus.length >=
        widget.surveyDetails.maxVotesPerUser) {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      // Update tokens
      userProfileProvider.updateTokens(widget.surveyDetails.tokensEarned);
      widget.onVoteComplete(true);
      Navigator.of(context).pop();
    }
  }

  Future<void> _initializeIfEmpty() async {
    final voteStatusNotifier =
        Provider.of<VoteStatusNotifier>(context, listen: false);
    if (widget.surveyDetails.userSelectedAnswers.isNotEmpty) {
      voteStatusNotifier
          .initializeVoteStatus(widget.surveyDetails.userSelectedAnswers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final columnCount = isTablet ? 3 : 2;
    final voteStatusNotifier = Provider.of<VoteStatusNotifier>(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(!widget.showResults
              ? widget.surveyDetails.description
              : 'Vote Results')),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          //const AdsCarouselComponent(viewType: ViewType.voteScreen),
          Align(
            alignment: Alignment.center,
            child: Text(
                !widget.showResults ? (widget.surveyDetails.rules ?? '') : '',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleLarge),
          ),
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
                            voteStatusNotifier.isVoted(answer.answerId);

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
                              // Text(
                              //   answer.title,
                              //   style: Theme.of(context).textTheme.labelSmall,
                              //   textAlign: TextAlign.center,
                              // ),
                              const SizedBox(height: 20),
                              if (answer.pictureUrl != null)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      width: 180,
                                      height: 180,
                                      imageUrl: answer.pictureUrl!,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) {
                                        return buildLoadingImageSkeleton(
                                            (screenWidth -
                                                    (columnCount + 1) * 10) /
                                                columnCount);
                                      },
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    const SizedBox(height: 15),
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
