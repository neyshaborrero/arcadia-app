import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/survey_details.dart';
import 'package:arcadia_mobile/src/views/events/vote_screen.dart';
import 'package:flutter/material.dart';

class SurveyContainer extends StatefulWidget {
  final SurveyDetails surveyDetails;

  const SurveyContainer({super.key, required this.surveyDetails});

  @override
  _SurveyContainerState createState() => _SurveyContainerState();
}

class _SurveyContainerState extends State<SurveyContainer> {
  bool hasReachedMaxVotes = false;

  void _handleVoteCompletion(bool reachedMaxVotes) {
    setState(() {
      hasReachedMaxVotes = reachedMaxVotes;
    });
  }

  void _navigateToVoteScreen(BuildContext context) {
    // Clone the survey details so that we can modify it without affecting the original data.
    SurveyDetails surveyDetailsToPass = widget.surveyDetails;

    // Check the condition and sort if true
    if (widget.surveyDetails.userHasAnswered || hasReachedMaxVotes) {
      surveyDetailsToPass = SurveyDetails(
        id: widget.surveyDetails.id,
        question: widget.surveyDetails.question,
        description: widget.surveyDetails.description,
        pictureUrl: widget.surveyDetails.pictureUrl,
        maxVotesPerUser: widget.surveyDetails.maxVotesPerUser,
        userHasAnswered: widget.surveyDetails.userHasAnswered,
        maxAnswers: widget.surveyDetails.maxAnswers,
        tokensEarned: widget.surveyDetails.tokensEarned,
        createdAt: widget.surveyDetails.createdAt,
        expiresAt: widget.surveyDetails.expiresAt,
        answers: List.from(widget.surveyDetails.answers)
          ..sort((a, b) => b.percentage.compareTo(a.percentage)),
      );
    }

    _navigateUpWithSlideTransition(
      context,
      VoteScreen(
          surveyDetails: surveyDetailsToPass,
          onVoteComplete: _handleVoteCompletion,
          showResults:
              (widget.surveyDetails.userHasAnswered || hasReachedMaxVotes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = MediaQuery.of(context).size.width >= 600;
    final double scaleFactor = tablet
        ? MediaQuery.of(context).size.height / 1000
        : MediaQuery.of(context).size.height / 900;
    final double fontSizeLabel =
        Theme.of(context).textTheme.labelSmall!.fontSize! * scaleFactor;
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
          Text(
            widget.surveyDetails.description,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontSize: fontSizeTitle),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (widget.surveyDetails.pictureUrl != null)
            Image.network(widget.surveyDetails.pictureUrl!,
                width: imageSize, height: imageSize, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(
            widget.surveyDetails.question,
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(fontSize: fontSizeLabel),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 42, top: 5),
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
        ],
      ),
    );
  }
}

void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
}
