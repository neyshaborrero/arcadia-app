import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/tools/is_tablet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class AdsCarouselComponent extends StatefulWidget {
  const AdsCarouselComponent({super.key});

  @override
  _AdsCarouselComponentState createState() => _AdsCarouselComponentState();
}

class _AdsCarouselComponentState extends State<AdsCarouselComponent> {
  List<Map<String, String>> ads = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<AdsDetails> ads =
        Provider.of<AdsDetailsProvider>(context, listen: false).getEpicAds();
    final double height = isTabletCarouselAds(context) ? 180.0 : 90.0;
    return ads.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ))
        : CarouselSlider(
            options: CarouselOptions(
              height: height,
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
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )),
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
