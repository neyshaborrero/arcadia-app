import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/news_article.dart';
import 'package:arcadia_mobile/src/views/qrcode/qrcode_view.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final List<NewsArticle> newsArticleList;

  const ProfileView({super.key, required this.newsArticleList});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Aligns children along the main axis
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Stack(
            alignment: Alignment.center, // Aligns the '+' icon over the avatar
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/hambopr.jpg'), // Fallback to default asset image
                          fit: BoxFit
                              .contain, // Fills the space, you could use BoxFit.contain to maintain aspect ratio
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
                  onTap: () => {
                    _navigateUpWithSlideTransition(
                        context, const QRCodeScreen())
                  },
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
                        '200',
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    ])
                  ],
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 9.0, left: 37.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Activity',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleLarge),
              )),
          const SizedBox(height: 10),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ListView.builder(
                      itemCount: newsArticleList.length,
                      itemBuilder: (context, index) {
                        NewsArticle article = newsArticleList[index];
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2c2b2b),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adds rounded corners to the container
                                ), // Conditional background color
                                child: ListTile(
                                    title: Text(
                                      article.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    subtitle: Text(
                                      article.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    leading: article.icon,
                                    onTap: () async {
                                      showActivityDialog(
                                          context,
                                          true,
                                          article.title,
                                          article.subtitle,
                                          article.imageComplete,
                                          article.imageIncomplete);
                                    })));
                      })))
        ]));
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
