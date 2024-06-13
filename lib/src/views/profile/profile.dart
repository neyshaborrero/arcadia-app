import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _fetchUserActivity();
  }

  Future<void> _fetchUserActivity() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();

    if (token == null) return;

    final List<UserActivity>? activities =
        await _arcadiaCloud.fetchUserActivity(token);

    if (activities != null) {
      Provider.of<UserActivityProvider>(context, listen: false)
          .setUserActivities(activities);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userActivityProvider = Provider.of<UserActivityProvider>(context);
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    final userActivities = userActivityProvider.userActivities;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0), // Add margin here
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment:
                    Alignment.center, // Aligns the '+' icon over the avatar
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                        2), // This value is the width of the border
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 4.0, // Border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 70, // Adjust the radius to your preference
                      backgroundColor: const Color(
                          0xFF2C2B2B), // Background color for the avatar
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: userProfile != null &&
                                      userProfile.profileImageUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      userProfile.profileImageUrl)
                                  : const AssetImage('assets/hambopr.jpg')
                                      as ImageProvider, // Fallback to default asset image
                              fit: BoxFit
                                  .cover, // Fills the space, you could use BoxFit.contain to maintain aspect ratio
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // Adjust the position as per your design
                    right: 0, // Adjust the position as per your design
                    child: GestureDetector(
                      onTap: () => _navigateUpWithSlideTransition(
                          context, const QRCodeScreen()),
                      child: Container(
                        width: 54.0,
                        height: 54.0,
                        decoration: const BoxDecoration(
                          color: Color(
                              0xFFD20E0D), // Background color of the '+' icon circle
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFD20E0D)
                          .withOpacity(0.85), // Dark red color start
                      const Color(0xFF020202)
                          .withOpacity(0.85), // Lighter red color end
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'XP',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(children: [
                          Image.asset(
                            'assets/ribbon.png',
                            width: 39,
                            height: 39,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 25),
                          Text(
                            '0',
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        ])
                      ],
                    ),
                    Container(
                      height: 50, // Adjust the height according to your needs
                      width: 2, // Width of the line
                      color: Colors.white, // Color of the line
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Tokens',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(children: [
                          Image.asset(
                            'assets/tokenization.png',
                            width: 41,
                            height: 41,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 25),
                          Text(
                            userProfile != null
                                ? userProfile.tokens.toString()
                                : '0',
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        ])
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : userActivities.isEmpty
                        ? _buildNoActivityWidget()
                        : ListView(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 9.0, left: 37.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Activity',
                                    textAlign: TextAlign.left,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...userActivities.map((userActivity) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2c2b2b),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Adds rounded corners to the container
                                    ), // Conditional background color
                                    child: ListTile(
                                      title: Text(
                                        userActivity.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                      subtitle: Text(
                                        userActivity.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      leading: userActivity.type == "checkin"
                                          ? const Icon(
                                              Icons.location_on_outlined,
                                              size: 35,
                                            )
                                          : const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 35,
                                            ),
                                      trailing: Text(
                                        userActivity.getFormattedDate(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      onTap: () async {
                                        showActivityDialog(
                                          context,
                                          true,
                                          true,
                                          userActivity.title,
                                          userActivity.description,
                                          userActivity.imageComplete,
                                          userActivity.imageIncomplete,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
              ),
            ],
          ),
        ));
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }

  Widget _buildNoActivityWidget() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;

        // Adjust sizes based on screen size
        double imageSize = screenWidth * 0.25;
        double paddingSize = screenHeight * 0.05;
        // double buttonPaddingHorizontal = screenWidth * 0.15;
        // double buttonPaddingVertical = screenHeight * 0.02;
        double textFontSize = screenHeight * 0.07;

        return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2B2B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/scan_activity.png', // Replace with your image asset path
                    width: imageSize,
                    height: imageSize,
                  ),
                  SizedBox(height: paddingSize),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Text(
                      'You have no recent activity.\nComplete daily quests and play to get started.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: textFontSize,
                          ),
                    ),
                  ),
                  // SizedBox(height: paddingSize),
                  // ElevatedButton(
                  //   onPressed: () => _navigateUpWithSlideTransition(
                  //       context, const QRCodeScreen()),
                  //   style: ElevatedButton.styleFrom(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: buttonPaddingHorizontal,
                  //       vertical: buttonPaddingVertical,
                  //     ),
                  //     backgroundColor: const Color(0xFFD20E0D), // Background color
                  //   ),
                  //   child: Text(
                  //     'Scan QR',
                  //     style: TextStyle(fontSize: textFontSize),
                  //   ),
                  // ),
                ],
              ),
            ));
      },
    );
  }
}
