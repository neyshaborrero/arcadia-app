import 'dart:async';

import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/survey_details.dart';
import 'package:arcadia_mobile/src/tools/loading.dart';
import 'package:arcadia_mobile/src/views/events/vote_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SurveyContainer extends StatefulWidget {
  SurveyDetails surveyDetails;
  final Function() onVoteComplete; // Add the onVoteComplete callback

  SurveyContainer(
      {super.key, required this.surveyDetails, required this.onVoteComplete});

  @override
  _SurveyContainerState createState() => _SurveyContainerState();
}

class _SurveyContainerState extends State<SurveyContainer> {
  bool hasReachedMaxVotes = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleVoteCompletion(bool reachedMaxVotes) {
    setState(() {
      hasReachedMaxVotes = reachedMaxVotes;
    });
    // Trigger the parent callback, passing the surveyId
    widget.onVoteComplete();
  }

  Future<void> _navigateToVoteScreen(BuildContext context) async {
    // Clone the survey details so that we can modify it without affecting the original data.
    SurveyDetails surveyDetailsToPass = widget.surveyDetails;

    // Check the condition and sort if true
    if (widget.surveyDetails.userHasAnswered || hasReachedMaxVotes) {
      surveyDetailsToPass = SurveyDetails(
          id: widget.surveyDetails.id,
          question: widget.surveyDetails.question,
          description: widget.surveyDetails.description,
          subtitle: widget.surveyDetails.subtitle,
          pictureUrl: widget.surveyDetails.pictureUrl,
          maxVotesPerUser: widget.surveyDetails.maxVotesPerUser,
          userHasAnswered: widget.surveyDetails.userHasAnswered,
          maxAnswers: widget.surveyDetails.maxAnswers,
          tokensEarned: widget.surveyDetails.tokensEarned,
          createdAt: widget.surveyDetails.createdAt,
          expiresAt: widget.surveyDetails.expiresAt,
          answers: List.from(widget.surveyDetails.answers)
            ..sort((a, b) => b.percentage.compareTo(a.percentage)),
          userSelectedAnswers: widget.surveyDetails.userSelectedAnswers,
          showResults: widget.surveyDetails.showResults);
    }

    // Navigate to the VoteScreen and await the result
    final updatedSurvey = await Navigator.of(context).push<SurveyDetails>(
      MaterialPageRoute(
        builder: (context) => VoteScreen(
          surveyDetails: surveyDetailsToPass,
          onVoteComplete: _handleVoteCompletion,
          showResults:
              (widget.surveyDetails.userHasAnswered || hasReachedMaxVotes),
        ),
      ),
    );

    // If updatedSurvey is not null, update the state with the new data
    if (updatedSurvey != null) {
      setState(() {
        widget.surveyDetails = updatedSurvey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = MediaQuery.of(context).size.width >= 600;
    final double scaleFactor = tablet
        ? MediaQuery.of(context).size.height / 1000
        : MediaQuery.of(context).size.height / 900;
    final double fontSizeLabel =
        Theme.of(context).textTheme.labelMedium!.fontSize! * scaleFactor;
    final double fontSizeTitle =
        Theme.of(context).textTheme.titleLarge!.fontSize! * scaleFactor;
    final double padding = 12 * scaleFactor;
    final double imageSize = 90 * scaleFactor;

    return Container(
      padding: EdgeInsets.all(padding),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Adjust this to control vertical alignment
                    children: [
                      Text(
                        widget.surveyDetails.description,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: fontSizeTitle),
                        textAlign: TextAlign.center, // Text remains centered
                      ),
                      if (widget.surveyDetails.subtitle != null)
                        Text(
                          widget.surveyDetails.subtitle ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center, // Text remains centered
                        ),
                      if (!widget.surveyDetails.userHasAnswered &&
                          !hasReachedMaxVotes)
                        Text(
                          'Win Tokens',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center, // Text remains centered
                        )
                    ]),
              ),
              Align(
                  alignment: Alignment
                      .centerRight, // Align image to the end of the row
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Adjust this to control vertical alignment
                    children: [
                      if (widget.surveyDetails.userHasAnswered ||
                          hasReachedMaxVotes)
                        Image.asset(
                          'assets/coin.gif',
                          width: 36,
                          height: 36,
                        ),
                      Text(
                        widget.surveyDetails.userHasAnswered ||
                                hasReachedMaxVotes
                            ? '${widget.surveyDetails.tokensEarned} Tokens' // Text when GIF is shown
                            : '', // Text when static image is shown
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall, // Adjust style as needed
                      ),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.surveyDetails.pictureUrl != null)
            CachedNetworkImage(
              width: imageSize,
              height: imageSize,
              imageUrl: "${widget.surveyDetails.pictureUrl!}&w=400",
              fit: BoxFit.contain,
              placeholder: (context, url) {
                return buildLoadingImageSkeleton(imageSize);
              },
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          const SizedBox(height: 10),
          Text(
            widget.surveyDetails.question,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontSize: fontSizeLabel),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 5),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tablet ? 400 : 200),
              child: ElevatedButton(
                onPressed: () => _navigateToVoteScreen(context),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (widget.surveyDetails.userHasAnswered ||
                          hasReachedMaxVotes) {
                        return const Color(
                            0xFF4BAE4F); // Green when max votes reached
                      }
                      return Theme.of(context)
                          .primaryColor; // Default color when not voted
                    },
                  ),
                  minimumSize: WidgetStateProperty.all<Size>(
                    Size.fromHeight(tablet ? 50 : 30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tablet ? 20 : 10,
                    vertical: tablet ? 20 : 10,
                  ),
                  child: Text(
                    (widget.surveyDetails.userHasAnswered || hasReachedMaxVotes)
                        ? 'See Results'
                        : 'Vote',
                    style: TextStyle(fontSize: tablet ? 24 : 18),
                  ),
                ),
              ),
            ),
          ),
          if (widget.surveyDetails.sponsorBy != null &&
              widget.surveyDetails.sponsorBy!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, -6), // Move the text 3 pixels up
                  child: Text(
                    'Sponsored by:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 10),
                CachedNetworkImage(
                  width: 90,
                  height: 60,
                  imageUrl: "${widget.surveyDetails.sponsorBy}&w=400",
                  fit: BoxFit.fitWidth,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
