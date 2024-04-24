import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('News'),
        bottom: TabBar(
          controller: _tabController,
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
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    child: ListTile(
                      title: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              0.3, // adjusts the width of the image, set to your preferred size
                          child: Image.asset(
                            'assets/news_ad.png',
                            fit: BoxFit
                                .cover, // this will fill the height of the ListTile and clip the width
                          ),
                        ),
                      ),
                      onTap: () {
                        // Your tap callback here
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Latest News',
                      style: Theme.of(context).textTheme.headlineLarge),
                ),
                // You can create a separate widget for this item to avoid repetition
                const ListTile(
                  title: Text('¡Nuevos Lanzamientos!'),
                  subtitle: Text('Descubre los juegos más esperados del mes.'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const ListTile(
                  title: Text('Secretos Revelados'),
                  subtitle: Text(
                      'Los Easter Eggs más ingeniosos de los videojuegos.'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const ListTile(
                  title: Text('La Evolución de los Juegos de Rol'),
                  subtitle: Text('Descubre cómo los RPG han evolucionado.'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const ListTile(
                  title: Text('Entrevista Exclusiva'),
                  subtitle:
                      Text('Directamente de la mente maestra detras de...'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const ListTile(
                  title: Text('Personajes Legendarios'),
                  subtitle: Text(
                      'Celebra a los heroés y villanos que han dejado una...'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const ListTile(
                  title: Text('Análisis Profundo'),
                  subtitle:
                      Text('Sumérgete en el mundo de la VR y descubre cómo...'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                // Add more ListTiles as needed
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
