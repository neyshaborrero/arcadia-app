import 'package:flutter/material.dart';

class VoteStatusNotifier extends ChangeNotifier {
  final Map<String, bool> _voteStatus = {};
  Map<String, bool> get voteStatus => _voteStatus;

  // Initialize the vote status based on userSelectedAnswers
  void initializeVoteStatus(List<String> userSelectedAnswers) {
    for (String answerId in userSelectedAnswers) {
      _voteStatus[answerId] = true; // Mark the answerId as voted
    }
    notifyListeners(); // Notify listeners that vote status has been updated
  }

  void updateVoteStatus(String answerId, bool status) {
    _voteStatus[answerId] = status;
    notifyListeners();
  }

  bool isVoted(String answerId) {
    return _voteStatus[answerId] ?? false;
  }
}
