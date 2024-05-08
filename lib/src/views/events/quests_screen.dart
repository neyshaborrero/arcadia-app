import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../structure/news_article.dart';
import '../../notifiers/change_notifier.dart';

class QuestsView extends StatelessWidget {
  final List<NewsArticle> newsArticleList;

  const QuestsView({super.key, required this.newsArticleList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Align(
              alignment: Alignment.center,
              child: Text('Points Earned',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
            )),
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '3,050',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'XP',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
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
                    '200',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Tokens',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ],
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 36.0, left: 37.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Daily Quests',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleLarge),
            )),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Consumer<ClickedState>(
                  builder: (context, clickedState, child) => ListView.builder(
                        itemCount: newsArticleList.length,
                        itemBuilder: (context, index) {
                          NewsArticle article = newsArticleList[index];
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: clickedState.isClicked(article.id)
                                        ? const Color(0xFFD20E0D)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adds rounded corners to the container
                                    border: clickedState.isClicked(article.id)
                                        ? Border.all(
                                            color: const Color(
                                                0xFFD20E0D)) // Optional: adds a border when clicked
                                        : null,
                                  ), // Conditional background color
                                  child: ListTile(
                                    leading: article.icon,
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
                                    onTap: () async {
                                      try {
                                        clickedState.toggleClicked(article.id);
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
}
