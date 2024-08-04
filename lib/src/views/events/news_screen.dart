import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../structure/news_article.dart';
import '../../notifiers/change_notifier.dart';
import '../../structure/view_types.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = true;
  late List<NewsArticle> newsArticle;
  Set<String> readNewsIds = {};

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    //_fetchNews();
    _fetchNewsAndReadStatus();
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

  Future<Map<String, dynamic>> _fetchReadNews() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final token = await user.getIdToken();

    if (token == null) return {};

    return await _arcadiaCloud.fetchReadNews(token);
  }

  Future<void> _fetchNewsAndReadStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null) return;

    final List<NewsArticle>? news = await _arcadiaCloud.fetchNews(token);
    final Map<String, dynamic> readNews = await _fetchReadNews();

    setState(() {
      if (news != null) {
        newsArticle = news;
      }

      if (readNews.isNotEmpty) {
        readNews.forEach((key, value) {
          readNewsIds.add(value['id']);
        });
      }

      // Mark the articles as read in the ClickedState
      final clickedState = Provider.of<ClickedState>(context, listen: false);
      for (var article in newsArticle) {
        if (readNewsIds.contains(article.id)) {
          clickedState.toggleClicked(article.id, initialState: true);
        }
      }

      _isLoading = false;
    });
  }

  Future<void> _recordNews(String qrId, String newsId, bool earn) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();

    if (token == null) return;

    final UserActivity? userActivity =
        await _arcadiaCloud.recordNews(earn, qrId, newsId, token);

    if (userActivity != null) {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      userProfileProvider.updateTokens(userActivity.value);
      Provider.of<UserActivityProvider>(context, listen: false)
          .addUserActivity(userActivity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(18.0), // Add padding around the image
          child: AdsCarouselComponent(
            viewType: ViewType.news,
          ),
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
                                            _recordNews(
                                                article.qrId,
                                                article.id,
                                                !clickedState
                                                    .isClicked(article.id));
                                            if (!clickedState
                                                .isClicked(article.id)) {
                                              clickedState
                                                  .toggleClicked(article.id);
                                            }
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
