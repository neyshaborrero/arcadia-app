import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool?> showVoteDialog(BuildContext context, String answer, String? image,
    String surveyId, String answerId) {
  final firebaseService = Provider.of<FirebaseService>(context, listen: false);
  final ArcadiaCloud arcadiaCloud = ArcadiaCloud(firebaseService);

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: IntrinsicHeight(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildVoteContent(
                    context, answer, image, answerId, surveyId),
              ),
              const SizedBox(
                height: 10,
              ),
              _buildActionButton(context, arcadiaCloud, answerId, surveyId),
            ],
          ),
        )),
      );
    },
  );
}

Widget _buildVoteContent(
  BuildContext context,
  String answer,
  String? image,
  String answerId,
  String surveyId,
) {
  return Container(
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
    padding: const EdgeInsets.all(16.0), // Add padding
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Confirm',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: image != null
                ? CachedNetworkImage(
                    width: 95,
                    height: 95,
                    imageUrl: image,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : Image.asset('assets/game_controller_white.png',
                    width: 95, height: 95),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You are voting for',
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          answer,
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildActionButton(BuildContext context, ArcadiaCloud arcadiaCloud,
    String answerId, String surveyId) {
  const buttonText = "Vote";

  return Column(
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: Colors.black,
        ),
        onPressed: () async {
          bool success =
              await _submitSurveyAnswer(arcadiaCloud, surveyId, [answerId]);
          if (success) {
            Navigator.of(context).pop(true); // Close the dialog and return true
          } else {
            // Handle the case when the survey submission fails (e.g., show an error message)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed to submit your vote. Try again later')),
            );
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 225, maxWidth: 225),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFD20E0D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Future<bool> _submitSurveyAnswer(
  ArcadiaCloud arcadiaCloud,
  String surveyId,
  List<String> selectedAnswers,
) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final token = await user.getIdToken();

  if (token == null) return false;
  try {
    final success =
        await arcadiaCloud.submitSurveyAnswer(surveyId, selectedAnswers, token);

    return success;
  } catch (e) {
    // Handle error
    print('Failed to submit survey answer: $e');
    return false;
  }
}
