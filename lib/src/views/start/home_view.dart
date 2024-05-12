import 'package:arcadia_mobile/src/structure/news_article.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/events/quests_screen.dart';
import 'package:arcadia_mobile/src/views/profile/profile.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:flutter/material.dart';
import '../events/news_screen.dart';
import '../../routes/slide_up_route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ViewType _currentView = ViewType.profile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Forces the AppBar to rebuild with the new title
        });
      }
    });
  }

  List<String> tabTitles = ['Quests', 'News'];
  List<NewsArticle> newsArticleList = [
    NewsArticle(
        id: 1,
        title: "¡Nuevos Lanzamientos!",
        subtitle: "Descubre los juegos más esperados del mes.",
        url: Uri.parse('https://twitter.com/YoSoyUnGamerTW.')),
    NewsArticle(
        id: 2,
        title: "Secretos Revelados",
        subtitle: "Los Easter Eggs más ingeniosos de los videojuegos.",
        url: Uri.parse('https://www.linkedin.com/company/yosoyungamer')),
    NewsArticle(
        id: 3,
        title: "La Evolución de los Juegos de Rol",
        subtitle: "Descubre cómo los RPG han evolucionado.",
        url: Uri.parse('https://yosoyungamer.shop/')),
    NewsArticle(
        id: 4,
        title: "Entrevista Exclusiva",
        subtitle: "Directamente de la mente maestra detras de...",
        url: Uri.parse('https://www.patreon.com/yosoyungamer')),
    NewsArticle(
        id: 5,
        title: "Personajes Legendarios",
        subtitle: "Celebra a los heroés y villanos que han dejado una...",
        url: Uri.parse('https://www.patreon.com/yosoyungamer')),
    NewsArticle(
        id: 6,
        title: "Análisis Profundo",
        subtitle: "Sumérgete en el mundo de la VR y descubre cómo...",
        url:
            Uri.parse('https://www.facebook.com/yosoyungamerfb/?locale=es_LA')),
  ];

  List<NewsArticle> questList = [
    NewsArticle(
        id: 1,
        title: "Check-in",
        subtitle: "Win 30XP for checking in to ClaroPR",
        icon: const Icon(Icons.location_on_outlined)),
    NewsArticle(
        id: 2,
        title: "Check-in",
        subtitle: "Win 50XP for checking in to Kia Motors",
        icon: const Icon(Icons.location_on_outlined)),
    NewsArticle(
        id: 3,
        title: "Check-in",
        subtitle: "Win 30XP for checking in to TacoBell",
        icon: const Icon(Icons.location_on_outlined)),
    NewsArticle(
        id: 4,
        title: "Purchase",
        subtitle: "Win 100XP for every Taco Bell purchase",
        icon: const Icon(Icons.shopping_bag)),
    NewsArticle(
        id: 5,
        title: "Purchase",
        subtitle: "Win 100XP for every Taco Bell purchase",
        icon: const Icon(Icons.shopping_bag_outlined)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _currentView == ViewType.profile
            ? <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 32,
                  ),
                  onPressed: () {
                    // Action to be performed when the info icon is pressed
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Information'),
                          content:
                              const Text('This is an info icon on AppBar.'),
                          actions: [
                            TextButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ]
            : null,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          _currentView == ViewType.events
              ? tabTitles[_tabController.index]
              : 'hambopr',
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
        toolbarHeight: 60.0,
        bottom: _currentView == ViewType.events
            ? TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Quests'),
                  Tab(text: 'News'),
                ],
              )
            : null,
      ),
      body: Builder(
        builder: (context) {
          switch (_currentView) {
            case ViewType.profile:
              return ProfileView(newsArticleList: questList);
            case ViewType.events:
              return TabBarView(
                controller: _tabController,
                children: [
                  QuestsView(newsArticleList: questList),
                  NewsScreen(newsArticleList: newsArticleList)
                ],
              );
            default:
              return ProfileView(newsArticleList: questList);
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
                  color: Colors.transparent, // Adjust color to match your theme
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
                                      ? 'assets/player_default_prof_red.png'
                                      : 'assets/player_default_prof_icon.png',
                                  width: MediaQuery.of(context).size.width *
                                      0.1, // 10% of screen width
                                  height: MediaQuery.of(context).size.height *
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
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.03), // Adjust text size relative to screen width
                            )),
                          ]),
                      const SizedBox(
                          width: 48), // Space for the floating action button
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
                                  height: MediaQuery.of(context).size.height *
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
                                fontSize: MediaQuery.of(context).size.width *
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
            _navigateUpWithSlideTransition(context, const QRCodeScreen());
          },
          backgroundColor: const Color(0xFFD20E0D),
          elevation: 5.0, // Default elevation for FAB shadow
          child: const Icon(
            Icons.qr_code_scanner,
            size: 36.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
}
