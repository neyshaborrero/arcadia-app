import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/token_entries_container.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showPrizeDialog(
  BuildContext context, {
  required String title,
  required String image,
  required int token,
  required String prizeId,
  required String description,
  required String poweredby,
  required String termsurl,
  required String eventId,
  required int userTokens,
  required bool canUserParticipate,
}) {
  final firebaseService = Provider.of<FirebaseService>(context, listen: false);
  final ArcadiaCloud arcadiaCloud = ArcadiaCloud(firebaseService);

  showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      int currentTokens = userTokens;
      int entries = 0;

      return StatefulBuilder(
        builder: (context, setState) {
          void updateTokens(int countChange) {
            setState(() {
              entries += countChange;
              currentTokens = userTokens - (entries * token);
            });
          }

          Future<void> handlePurchase() async {
            try {
              final User? user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final userToken = await user.getIdToken();
              if (userToken == null) return;

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Call buyRaffleTickets API
              final result = await arcadiaCloud.buyRaffleTickets(
                prizeId: prizeId, // Replace with actual prizeId
                ticketCount: entries,
                eventId: eventId, // Replace with actual eventId
                tokenCost: token,
                token: userToken,
              );

              // Update user tokens and entries
              final userProfileProvider =
                  Provider.of<UserProfileProvider>(context, listen: false);
              setState(() {
                currentTokens = result.remainingTokens;
                entries = result.entries; // Reset entries after purchase
              });

              userProfileProvider.setTokens(result.remainingTokens);
              userProfileProvider.updateRaffleEntries(
                  result.entries, result.dayOne, result.dayTwo);

              Navigator.of(context).pop(); // Close loading dialog
              Navigator.of(context).pop(); // Close loading dialog

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully purchased ${result.entries} tickets!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFD20E0D),
                ),
              );
            } catch (e) {
              Navigator.of(context).pop(); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to purchase tickets: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          return Dialog(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TokenEntriesWidget(
                      tokens: currentTokens,
                      entries: entries.toString(),
                      onTokensUpdated: updateTokens,
                    ),
                    const SizedBox(height: 16),
                    _buildPrizeContainer(
                      title: title,
                      image: image,
                      token: token,
                      description: description,
                      poweredby: poweredby,
                      doesUserHaveTokens: token <= userTokens,
                      canParticipate: canUserParticipate,
                    ),
                    const SizedBox(height: 8),
                    _buildIncrementDecrementWidget(
                      tokenValue: token,
                      entries: entries,
                      onCountChanged: updateTokens,
                      userTokens: userTokens,
                    ),
                    const SizedBox(height: 20),
                    if (canUserParticipate && (token <= userTokens))
                      _buildActionButtons(
                        context: context,
                        count: entries,
                        onPurchasePressed: entries > 0 ? handlePurchase : null,
                      ),
                    if (!canUserParticipate || (token > userTokens))
                      _buildCloseButton(context)
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildIncrementDecrementWidget({
  required int tokenValue,
  required int entries,
  required ValueChanged<int> onCountChanged,
  required int userTokens,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      // Calculate remaining tokens
      final int remainingTokens = userTokens - (entries * tokenValue);

      return Column(
        children: [
          Text(
            'Entries',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  color:
                      entries > 0 ? const Color(0xFFD20E0D) : Colors.grey[800],
                  onPressed: entries > 0
                      ? () {
                          setState(() {
                            onCountChanged(-1); // Decrement count
                          });
                        }
                      : null, // Disable if entries are 0
                ),
                Text(
                  entries.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: remainingTokens >= tokenValue
                      ? const Color(0xFFD20E0D)
                      : Colors.grey[800],
                  onPressed: remainingTokens >= tokenValue
                      ? () {
                          setState(() {
                            onCountChanged(1); // Increment count
                          });
                        }
                      : null, // Disable if insufficient tokens
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (entries <= 0) ? '0 Tokens' : '- ${entries * tokenValue} Tokens',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildPrizeContainer({
  required String title,
  required String image,
  required int token,
  required bool canParticipate,
  required bool doesUserHaveTokens,
  required String description,
  required String poweredby,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD20E0D).withOpacity(0.85),
          const Color(0xFF020202).withOpacity(0.85),
        ],
      ),
      borderRadius: BorderRadius.circular(10.0),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(title),
        const SizedBox(height: 12),
        _buildPrizeImage(image),
        const SizedBox(height: 15),
        _buildTokenRow('$token'),
        const SizedBox(height: 5),
        _buildDescription(description),
        const SizedBox(height: 2),
        _buildSponsorRow(poweredby),
        if (!canParticipate)
          const Text(
            'Converting your tokens for entries will be enable later in the evening.',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        if (canParticipate && !doesUserHaveTokens)
          const Text(
            'You don\'t have enough tokens to participate in this prize.',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    ),
  );
}

Widget _buildTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
    ),
    textAlign: TextAlign.center,
  );
}

Widget _buildPrizeImage(String imageUrl) {
  return CachedNetworkImage(
    width: 214,
    height: 118,
    imageUrl: "$imageUrl&w=400",
    fit: BoxFit.fitWidth,
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}

Widget _buildTokenRow(String token) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/tokenization.png',
        width: 20,
        height: 20,
        fit: BoxFit.cover,
      ),
      const SizedBox(width: 5),
      Text(
        '$token Tokens',
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Text(
        ' / entry',
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Widget _buildDescription(String description) {
  return Text(
    description,
    style: const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
    ),
    textAlign: TextAlign.center,
  );
}

Widget _buildSponsorRow(String poweredByUrl) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Sponsored by:',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 10),
      CachedNetworkImage(
        width: 100,
        height: 60,
        imageUrl: "$poweredByUrl&w=400",
        fit: BoxFit.fitWidth,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    ],
  );
}

Widget _buildRaffleInfo() {
  return const Text(
    'Raffle entries unlock in Arcadia on Dec 7 & 8!',
    style: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w800,
    ),
    textAlign: TextAlign.center,
  );
}

Widget _buildCloseButton(BuildContext context) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      backgroundColor: const Color(0xFFD20E0D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onPressed: () => Navigator.of(context).pop(),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        "Close",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ),
  );
}

Widget _buildActionButtons({
  required BuildContext context,
  required int count,
  required VoidCallback? onPurchasePressed,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD20E0D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: onPurchasePressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Purchase $count Entries",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Close",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
      ),
    ],
  );
}
