import 'package:arcadia_mobile/src/structure/news_article.dart';
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
                  onTap: () => {},
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
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFD20E0D), // Dark red color start
                  Color(0xFF020202), // Lighter red color end
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(children: [
                      Image.asset('assets/ribbon.png'),
                      Text(
                        '3,050',
                        style: Theme.of(context).textTheme.titleSmall,
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(children: [
                      Image.asset('assets/tokenization.png'),
                      Text(
                        '200',
                        style: Theme.of(context).textTheme.titleSmall,
                      )
                    ])
                  ],
                ),
              ],
            ),
          ),
        ]));
  }
}
