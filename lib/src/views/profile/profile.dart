import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/no_activity.dart';
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

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
                            viewType: ViewType.profile,
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
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 80.0, // Set the maximum height
                ),
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
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 5),
                        Row(children: [
                          Image.asset(
                            'assets/ribbon.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 25),
                          Text(
                            userProfile != null
                                ? userProfile.xp.toString()
                                : '0',
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
                        //TokenInfo(tokens: userProfile?.tokens ?? 0)
                        Text(
                          'Tokens',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 5),
                        Row(children: [
                          Image.asset(
                            'assets/tokenization.png',
                            width: 30,
                            height: 30,
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
                    ? const Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ))
                    : userActivities.isEmpty
                        ? buildNoActivityWidget()
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
              const AdsCarouselComponent(
                viewType: ViewType.profile,
              )
            ],
          ),
        ));
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
