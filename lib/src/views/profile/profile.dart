import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/no_activity.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/events/loot_screen.dart';
import 'package:arcadia_mobile/src/views/events/raffle_view.dart';
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
  String? _selectedUserType;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeArcadiaCloud();
    _fetchInitialUserActivity();
    _scrollController.addListener(_onScroll);
  }

  void _initializeArcadiaCloud() {
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
  }

  void _fetchInitialUserActivity() {
    final isProviderEmpty =
        Provider.of<UserActivityProvider>(context, listen: false)
            .isProviderEmpty();
    _fetchUserActivity(isProviderEmpty);
  }

  Future<void> _fetchUserActivity(bool isActivityProviderEmpty,
      {String? startAfter}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null) return;

    setState(() {
      _isLoading = startAfter == null;
      _isLoadingMore = startAfter != null;
    });

    final response =
        await _arcadiaCloud.fetchUserActivity(token, startAfter: startAfter);
    if (response != null) {
      _handleUserActivityResponse(response, startAfter);
    }

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _handleUserActivityResponse(
      Map<String, dynamic> response, String? startAfter) {
    final activities = response['activities'] as List<UserActivity>;
    final lastKey = response['lastKey'] as String;

    final activityProvider =
        Provider.of<UserActivityProvider>(context, listen: false);
    if (startAfter != null) {
      activityProvider.addUserActivities(activities);
    } else {
      activityProvider.setUserActivities(activities);
    }

    _lastKey = lastKey;
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        !_scrollController.position.outOfRange &&
        !_isLoadingMore) {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchUserActivity(true, startAfter: _lastKey);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = userProfileProvider.userProfile;
    final userActivityProvider = Provider.of<UserActivityProvider>(context);
    final userActivities = userActivityProvider.userActivities;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Constrained Row for Avatar and Icons
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // if (userProfile != null && userProfile.checkedin.isNotEmpty)
                //   SizedBox(
                //     width: 10,
                //   ),
                _buildProfileAvatar(userProfile),
                // if (userProfile != null && userProfile.checkedin.isNotEmpty)
                //   const SizedBox(width: 40), // Space between avatar and icons

                // if (userProfile != null && userProfile.checkedin.isNotEmpty)
                //   Flexible(
                //     // Ensures proper constraints
                //     child: _buildProfileIcons(userProfile),
                //   ),
                // if (userProfile != null && userProfile.checkedin.isNotEmpty)
                //   SizedBox(
                //     width: 10,
                //   ),
              ],
            ),
            _buildDropdownFormField(
              value: _selectedUserType,
              label: 'User Type *',
              items: ['Player', 'Cosplayer', 'Placeholder'],
              onChanged: (value) => setState(() => _selectedUserType = value),
            ),

            // SizedBox(
            //     height: userProfile != null && userProfile.checkedin ? 35 : 20),
            SizedBox(
              height: 20,
            ),
            _buildXpTokensContainer(userProfile),
            const SizedBox(height: 7),
            _buildPrizesContainer(),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)))
                  : userActivities.isEmpty
                      ? buildNoActivityWidget()
                      : _buildUserActivityList(userActivities),
            ),
            const AdsCarouselComponent(viewType: ViewType.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        filled: true,
        fillColor: const Color(0xFF2C2B2B),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: const Color(0xFFD20E0D),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      validator: validator,
    );
  }

  Widget _buildProfileAvatar(UserProfile? userProfile) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Ensures no clipping of Positioned widget
        children: [
          CircleAvatar(
            radius: 73,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 70,
              backgroundImage: userProfile?.profileImageUrl.isNotEmpty == true
                  ? CachedNetworkImageProvider(userProfile!.profileImageUrl)
                  : const AssetImage('assets/hambopr.jpg') as ImageProvider,
            ),
          ),
          Positioned(
            bottom: -10, // Slightly outside the avatar for better positioning
            right: -10, // Slightly outside the avatar for better positioning
            child: GestureDetector(
              onTap: () => _navigateUpWithSlideTransition(
                  context, const QRCodeScreen(viewType: ViewType.profile)),
              child: Container(
                width: 54.0,
                height: 54.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFD20E0D),
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
    );
  }

  Widget _buildProfileIcons(UserProfile? userProfile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment
                          .topRight, // Position the text on the top-right
                      children: [
                        Image.asset(
                          'assets/level-shield.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 5, // Adjust the text position
                          right: 10,
                          child: _buildTextBadge(
                              '${userProfile?.playerLevel}'), // Badge with text '1'
                        ),
                      ],
                    ),
                    Text("Level",
                        style: Theme.of(context).textTheme.titleSmall),
                  ]),
              const SizedBox(width: 20),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment
                          .center, // Position the text on the top-right
                      children: [
                        Image.asset(
                          'assets/award.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 3,
                          right: 10,
                          child: _buildTextBadge(
                              '${userProfile?.prestigeTotal}'), // Badge with text '5'
                        ),
                      ],
                    ),
                    Text("Prestige",
                        style: Theme.of(context).textTheme.titleSmall),
                  ]), // Space between icon and label
            ]),
        const SizedBox(height: 16), // Space between icons
        Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment:
                    Alignment.topRight, // Position the text on the top-right
                children: [
                  Image.asset(
                    'assets/fire.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              Text("${userProfile?.matchStreak} Win Streak",
                  style: Theme.of(context).textTheme.titleSmall)
            ]),
      ],
    );
  }

  Widget _buildTextBadge(String text) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outline text
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5 // Width of the outline
                ..color = Colors.black, // Outline color
            ),
          ),
          // Filled white text
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Fill color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpTokensContainer(UserProfile? userProfile) {
    return Stack(
      clipBehavior:
          Clip.none, // Allows the image to overflow outside the container
      children: [
        Container(
          constraints:
              const BoxConstraints(maxHeight: 50.0), // Consistent height
          padding: const EdgeInsets.all(8.0),
          decoration: _buildGradientBoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Ensures vertical alignment
            children: [
              _buildXpOrTokensColumn(
                label: 'XP',
                value: userProfile?.xp.toString() ?? '0',
                assetPath: 'assets/ribbon.png',
              ),
              _buildXpOrTokensColumn(
                label: '',
                value: userProfile?.tokens.toString() ?? '0',
                assetPath: 'assets/tokenization.png',
              ),
            ],
          ),
        ),
        Positioned(
            top: 5, // Adjust to position the image above the container
            left: 0,
            right: 0,
            child: Center(child: _buildCenterDivider())),
        // if (userProfile?.checkedin == true)
        //   Positioned(
        //     top: -25, // Adjust to position the image above the container
        //     left: 0,
        //     right: 0,
        //     child: Center(
        //       child: Image.asset(
        //         'assets/level-shield.png', // Path to your uploaded image
        //         width: 50,
        //         height: 50,
        //         fit: BoxFit.contain,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildPrizesContainer() {
    return Stack(
        clipBehavior:
            Clip.none, // Allows the image to overflow outside the container
        children: [
          Container(
            constraints: const BoxConstraints(
                maxHeight: 50.0), // Same height as _buildXpTokensContainer
            padding: const EdgeInsets.all(8.0),
            decoration: _buildGradientBoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Ensures vertical alignment
              children: [
                _buildPrizeColumn(
                  label: 'Royal Loot',
                  value: '',
                  assetPath: 'assets/loot.png',
                  onLabelTap: () {
                    _navigateUpWithSlideTransition(context, const LootView());
                  },
                ),
                _buildPrizeColumn(
                  label: 'Prizes',
                  value: '',
                  assetPath: 'assets/prize.png',
                  onLabelTap: () {
                    _navigateUpWithSlideTransition(
                        context,
                        const RaffleView(
                          viewType: ViewType.prize,
                        ));
                  },
                ),
              ],
            ),
          ),
          Positioned(
              top: 5, // Adjust to position the image above the container
              left: 0,
              right: 0,
              child: Center(child: _buildCenterDivider())),
        ]);
  }

  Widget _buildCenterDivider() {
    return Container(
      height: 40, // Consistent height for the divider
      width: 2, // Thickness of the divider
      color: Colors.white.withOpacity(0.55),
    );
  }

  BoxDecoration _buildGradientBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD20E0D).withOpacity(0.85),
          const Color(0xFF020202).withOpacity(0.85),
        ],
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildXpOrTokensColumn(
      {required String label,
      required String value,
      required String assetPath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Image.asset(assetPath, width: 30, height: 30, fit: BoxFit.cover),
            const SizedBox(width: 10),
            Row(children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 5),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ])
          ],
        ),
      ],
    );
  }

  Widget _buildPrizeColumn({
    required String label,
    required String value,
    required String assetPath,
    required VoidCallback onLabelTap, // Callback for label click
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Image.asset(assetPath, width: 30, height: 30, fit: BoxFit.cover),
            const SizedBox(width: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: onLabelTap,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserActivityList(List<UserActivity> userActivities) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: userActivities.length + 1,
      itemBuilder: (context, index) {
        if (index == userActivities.length) {
          return _isLoadingMore
              ? const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : const SizedBox.shrink();
        }
        final userActivity = userActivities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2c2b2b),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text(userActivity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge),
              subtitle: Text(userActivity.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium),
              leading: Icon(
                _getActivityIcon(userActivity.qType ?? "activity"),
                size: 35,
              ),
              trailing: Text(userActivity.getFormattedDate(),
                  style: Theme.of(context).textTheme.labelSmall),
              onTap: () => showActivityDialog(
                  context,
                  null,
                  true,
                  true,
                  userActivity.title,
                  userActivity.description,
                  userActivity.imageComplete,
                  userActivity.imageIncomplete,
                  null),
            ),
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String qType) {
    switch (qType) {
      case "checkin":
        return Icons.location_on_outlined;
      case "activity":
        return Icons.star_border_outlined;
      case "match":
        return Icons.gamepad;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
