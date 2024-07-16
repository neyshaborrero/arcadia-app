import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../structure/news_article.dart';
import '../../notifiers/change_notifier.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = true;
  late List<NewsArticle> newsArticle;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();

    if (token == null) return;

    final List<NewsArticle>? news = await _arcadiaCloud.fetchNews(token);

    if (news != null) {
      newsArticle = news;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(18.0), // Add padding around the image
          child: AdsCarouselComponent(),
          // child: Container(
          //     decoration: BoxDecoration(
          //         borderRadius:
          //             BorderRadius.circular(10.0), // Rounded corners
          //         border: Border.all(color: Colors.grey) // Optional border
          //         ),
          //     child: ClipRRect(
          //         borderRadius: BorderRadius.circular(10.0),
          //         child: GestureDetector(
          //           onTap: () {
          //             // Define action on tap if necessary.
          //           },
          //           child: Image.asset(
          //             'assets/news_ad.png',
          //             fit: BoxFit
          //                 .cover, // this will fill the height of the ListTile and clip the width
          //             width: MediaQuery.of(context).size.width,
          //           ),
          //         )))
        ),
        Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 37.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Latest News',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleLarge),
            )),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ))
              : Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Consumer<ClickedState>(
                      builder: (context, clickedState, child) =>
                          ListView.builder(
                            itemCount: newsArticle.length,
                            itemBuilder: (context, index) {
                              NewsArticle article = newsArticle[index];
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            clickedState.isClicked(article.id)
                                                ? const Color(0xFFD20E0D)
                                                : const Color(0xFF2c2b2b),
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Adds rounded corners to the container
                                        border: clickedState
                                                .isClicked(article.id)
                                            ? Border.all(
                                                color: const Color(
                                                    0xFFD20E0D)) // Optional: adds a border when clicked
                                            : null,
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
                                          article.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                        trailing: clickedState
                                                .isClicked(article.id)
                                            ? Text(
                                                getFormattedDate(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              ) // Show today's date when clicked
                                            : const Icon(
                                                Icons.arrow_forward_ios),
                                        onTap: () async {
                                          try {
                                            _launchUrl(article.url);
                                            clickedState
                                                .toggleClicked(article.id);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Failed to open the link: $e'), // Display the error message in the SnackBar
                                                duration:
                                                    const Duration(seconds: 3),
                                                backgroundColor: Colors
                                                    .red, // Optional: Changes the background color to red for errors
                                              ),
                                            );
                                          }
                                        },
                                      )));
                            },
                          ))),
        ),
      ],
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    return DateFormat('MM/dd/yy')
        .format(now); // Example format, adjust as needed
  }
}
