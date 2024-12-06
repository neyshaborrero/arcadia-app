import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/event/intercative_map_widget.dart';
import 'package:arcadia_mobile/src/notifiers/prizes_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_right_route.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/prize_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:arcadia_mobile/src/views/events/event_screen.dart';
import 'package:arcadia_mobile/src/views/events/quests_screen.dart';
import 'package:arcadia_mobile/src/views/profile/operator.dart';
import 'package:arcadia_mobile/src/views/profile/profile.dart';
import 'package:arcadia_mobile/src/views/profile/settings.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:arcadia_mobile/src/views/start/event_home.dart';
import 'package:arcadia_mobile/src/views/start/play_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../events/news_screen.dart';
import '../../routes/slide_up_route.dart';

class HomeScreen extends StatefulWidget {
  final List<MissionDetails> missions;

  const HomeScreen({super.key, required this.missions});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late final ArcadiaCloud _arcadiaCloud;
  late final UserProfile? userProfile;

  ViewType _currentView = ViewType.events;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    // _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userProfile =
        Provider.of<UserProfileProvider>(context, listen: false).userProfile;
    _tabController = TabController(
        length: userProfile != null && userProfile!.checkedin.isEmpty ? 3 : 4,
        vsync: this,
        initialIndex: 0);
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);

    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _fetchPrizes();

    if (userProfile != null) {
      firebaseService.initFirebaseNotifications(userProfile!);
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Forces the AppBar to rebuild with the new title
        });
      }
    });
  }

  Future<void> _fetchPrizes() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null) return;

    final response = await _arcadiaCloud.fetchArcadiaPrizes(token);

    if (response != null && mounted) {
      List<PrizeDetails> prizeList = response;

      Provider.of<PrizesChangeProvider>(context, listen: false)
          .setPrizeList(prizeList);
    } else {
      print("failed to load prizes");
    }

    final lootResponse = await _arcadiaCloud.fetchArcadiaLoot(token);

    if (lootResponse != null && mounted) {
      List<PrizeDetails> lootList = lootResponse;

      Provider.of<PrizesChangeProvider>(context, listen: false)
          .addPrizes(lootList);
    } else {
      print("failed to load loot prizes");
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // When the app is resumed, show the splash screen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const SplashScreen()),
  //     );
  //   }
  // }

  List<String> tabTitles = ['Quests', 'Event', 'News', 'Map'];

  @override
  Widget build(BuildContext context) {
    // final UserProfile? userProfile =
    //     Provider.of<UserProfileProvider>(context).userProfile;
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              if (_currentView == ViewType.profile)
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 32,
                  ),
                  onPressed: () {
                    _navigateWithSlideTransition(
                        context, const SettingsScreen());
                  },
                ),
              if (userProfile != null && userProfile!.checkedin.isEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.confirmation_num_outlined,
                    size: 32,
                  ),
                  onPressed: () {
                    launchURL(Uri.parse('https://prticket.sale/ARCADIA'));
                  },
                ),
            ],
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: (userProfile != null && userProfile!.checkedin.isEmpty) ||
                    (_currentView == ViewType.profile)
                ? Text(
                    _currentView == ViewType.events
                        ? tabTitles[_tabController.index]
                        : userProfile != null &&
                                userProfile!.profileImageUrl.isNotEmpty
                            ? userProfile!.gamertag
                            : 'hambopr',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight
                          .w700, // This corresponds to font-weight: 700 in CSS
                    ),
                  )
                : null,
            toolbarHeight:
                (userProfile != null && userProfile!.checkedin.isEmpty) ||
                        (_currentView == ViewType.profile)
                    ? 40.0
                    : 10.0,
            bottom: _currentView == ViewType.events
                ? TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                          text: (userProfile != null &&
                                  userProfile!.checkedin.isEmpty)
                              ? 'Quests'
                              : 'Play'),
                      Tab(
                          text: (userProfile != null &&
                                  userProfile!.checkedin.isEmpty)
                              ? 'News'
                              : 'Event'),
                      Tab(text: 'Vote'),
                      if (userProfile != null &&
                          userProfile!.checkedin.isNotEmpty)
                        Tab(text: 'Map'),
                    ],
                  )
                : null,
          ),
          body: Builder(
            builder: (context) {
              switch (_currentView) {
                case ViewType.profile:
                  if (userProfile?.userType == "operator") {
                    return const OperatorView();
                  } else {
                    return const ProfileView();
                  }

                case ViewType.events:
                  return TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      (userProfile != null && userProfile!.checkedin.isEmpty)
                          ? QuestsView(missionList: widget.missions)
                          : PlayHome(),
                      (userProfile != null && userProfile!.checkedin.isEmpty)
                          ? NewsScreen()
                          : EventHome(missionList: widget.missions),
                      const EventView(),
                      if (userProfile != null &&
                          userProfile!.checkedin.isNotEmpty)
                        const InteractiveMapWidget()
                    ],
                  );
                default:
                  return const ProfileView();
              }
            },
          ),
          bottomNavigationBar: Container(
              height: MediaQuery.of(context).size.height *
                  0.12, // 10% of screen height, // You can define the height you want
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black, // Background color of BottomAppBar
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        offset: const Offset(0, -2), // Direction of the shadow
                        spreadRadius:
                            0, // Negative spread radius to create the inner shadow effect
                        blurRadius: 10, // Blur radius
                      ),
                    ],
                  ),
                  child: BottomAppBar(
                      color: Colors
                          .transparent, // Adjust color to match your theme
                      elevation: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Image.asset(
                                      _currentView == ViewType.profile
                                          ? 'assets/headphone_red.png'
                                          : 'assets/headphone.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.1, // 10% of screen width
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3, // 5% of screen height
                                      fit: BoxFit.contain,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _currentView = ViewType.profile;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  'Profile',
                                  style: TextStyle(
                                      color: _currentView == ViewType.profile
                                          ? const Color(0xFFD20E0D)
                                          : Colors.white,
                                      fontSize: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.03), // Adjust text size relative to screen width
                                )),
                              ]),
                          const SizedBox(
                              width:
                                  48), // Space for the floating action button
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Image.asset(
                                      _currentView == ViewType.events
                                          ? 'assets/calendar_red.png'
                                          : 'assets/calendar_white.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.1, // 10% of screen width
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3, // 5% of screen height
                                      fit: BoxFit.contain,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _currentView = ViewType.events;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                    child: (Text(
                                  'Event',
                                  style: TextStyle(
                                    color: _currentView == ViewType.events
                                        ? const Color(0xFFD20E0D)
                                        : Colors.white,
                                    fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.03, // Adjust text size relative to screen width
                                  ),
                                )))
                              ]),
                        ],
                      )))),
          floatingActionButton: Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                _navigateUpWithSlideTransition(
                    context,
                    const QRCodeScreen(
                      viewType: ViewType.home,
                    ));
              },
              backgroundColor: const Color(0xFFD20E0D),
              elevation: 5.0, // Default elevation for FAB shadow
              child: const Icon(
                Icons.qr_code_scanner,
                size: 36.0,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ));
  }
}

void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
}

// Function to navigate with the slide transition
void _navigateWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideRightRoute(page: page));
}
