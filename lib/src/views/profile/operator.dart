import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OperatorView extends StatefulWidget {
  const OperatorView({super.key});

  @override
  _OperatorViewState createState() => _OperatorViewState();
}

class _OperatorViewState extends State<OperatorView> {
  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _lastKey;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);

    _fetchUserActivity(Provider.of<UserActivityProvider>(context, listen: false)
        .isProviderEmpty());
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchUserActivity(bool isActivityProviderEmpty,
      {String? startAfter}) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final token = await user.getIdToken();

    if (token == null) return;

    setState(() {
      if (startAfter == null) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    final response =
        await _arcadiaCloud.fetchUserActivity(token, startAfter: startAfter);

    if (response != null) {
      final List<UserActivity> activities = response['activities'];
      final String lastKey = response['lastKey'];

      if (startAfter != null) {
        Provider.of<UserActivityProvider>(context, listen: false)
            .addUserActivities(activities);
      } else {
        Provider.of<UserActivityProvider>(context, listen: false)
            .setUserActivities(activities);
      }

      setState(() {
        _lastKey = lastKey;
      });
    }

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _fetchUserActivity(true, startAfter: _lastKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userActivityProvider =
        Provider.of<UserActivityProvider>(context, listen: true);
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    final userActivities = userActivityProvider.userActivities;

    return Container(
        margin:
            const EdgeInsets.only(top: 10.0).copyWith(left: 16.0, right: 16.0),
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
                          context,
                          const QRCodeScreen(
                            viewType: ViewType.operatorProfile,
                          )),
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
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ))
                    : userActivities.isEmpty
                        ? _buildNoActivityWidget()
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: userActivities.length + 1,
                            itemBuilder: (context, index) {
                              if (index == userActivities.length) {
                                return _isLoadingMore
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              final userActivity = userActivities[index];
                              print(userActivity.qType);
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
                                    leading: userActivity.qType == "checkin"
                                        ? const Icon(
                                            Icons.location_on_outlined,
                                            size: 35,
                                          )
                                        : userActivity.qType == "activity"
                                            ? const Icon(
                                                Icons.star_border_outlined,
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
                                        null,
                                        true,
                                        true,
                                        userActivity.title,
                                        userActivity.description,
                                        userActivity.imageComplete,
                                        userActivity.imageIncomplete,
                                        null,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 20),
              _buildCheckInTicketsButton(),
              const SizedBox(height: 37),
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

  Widget _buildCheckInTicketsButton() {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isTablet ? 400 : 200),
      child: ElevatedButton(
        onPressed: () => _navigateUpWithSlideTransition(
            context,
            const QRCodeScreen(
              viewType: ViewType.operatorProfile,
            )),
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(isTablet ? 70 : 50),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 10,
            vertical: isTablet ? 20 : 10,
          ),
          child: Text(
            'Check In Hub',
            style: TextStyle(fontSize: isTablet ? 24 : 18),
          ),
        ),
      ),
    );
  }
}
