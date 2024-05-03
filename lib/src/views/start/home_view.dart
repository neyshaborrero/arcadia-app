import 'package:arcadia_mobile/src/structure/news_article.dart';
import 'package:flutter/material.dart';
import '../events/news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          tabTitles[_tabController.index],
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
        toolbarHeight: 30.0,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Quests'),
            Tab(text: 'News'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Quests Content')),
          NewsScreen(newsArticleList: newsArticleList)
        ],
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
                                  'assets/player_default_prof_icon.png',
                                  width: MediaQuery.of(context).size.width *
                                      0.1, // 10% of screen width
                                  height: MediaQuery.of(context).size.height *
                                      0.3, // 5% of screen height
                                  fit: BoxFit.contain,
                                ),
                                onPressed: () {},
                              ),
                            ),
                            Expanded(
                                child: Text(
                              'Profile',
                              style: TextStyle(
                                  color: Colors.white,
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
                                  'assets/calendar_red.png',
                                  width: MediaQuery.of(context).size.width *
                                      0.1, // 10% of screen width
                                  height: MediaQuery.of(context).size.height *
                                      0.3, // 5% of screen height
                                  fit: BoxFit.contain,
                                ),
                                onPressed: () {
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //       builder: (context) => QRViewExample()),
                                  // );
                                },
                              ),
                            ),
                            Expanded(
                                child: (Text(
                              'Event',
                              style: TextStyle(
                                color: const Color(0xFFD20E0D),
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
            // Add action for your floating button here
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
