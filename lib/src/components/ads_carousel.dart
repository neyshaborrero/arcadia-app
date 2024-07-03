import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class AdsCarouselComponent extends StatefulWidget {
  @override
  _AdsCarouselComponentState createState() => _AdsCarouselComponentState();
}

class _AdsCarouselComponentState extends State<AdsCarouselComponent> {
  List<Map<String, String>> ads = [];
  @override
  void initState() {
    super.initState();
    fetchAds();
  }

  void fetchAds() async {
    // final snapshot = await adsRef.once();
    // final data = snapshot.value as Map;
    // final currentDate = DateTime.now().toIso8601String();

    // final filteredAds = data.entries
    //     .where((entry) => entry.value['expires'] > currentDate)
    //     .map((entry) => {
    //           'image': entry.value['image'],
    //           'tier': entry.value['tier'],
    //         })
    //     .toList();

    final filteredAds = [
      {
        "id": "12345",
        "image":
            "https://firebasestorage.googleapis.com/v0/b/ysug-arcadia-46a15.appspot.com/o/ads%2Fnews_ad.png?alt=media&token=91fc471c-0e56-461b-a030-9f50d8cd1c6c",
        "url": "google.com"
      }
    ];

    setState(() {
      ads = filteredAds;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<AdsDetails> ads =
        Provider.of<AdsDetailsProvider>(context, listen: false).adsDetails;
    return ads.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : CarouselSlider(
            options: CarouselOptions(
              height: 90.0,
              autoPlay: ads.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              scrollDirection: Axis.horizontal,
            ),
            items: ads.map((ad) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF000000),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: ad.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ));
                },
              );
            }).toList(),
          );
  }
}
