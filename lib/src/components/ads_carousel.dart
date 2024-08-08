import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/ads_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/is_tablet.dart';
import 'package:arcadia_mobile/src/tools/url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:provider/provider.dart';

class AdsCarouselComponent extends StatefulWidget {
  final ViewType viewType;
  const AdsCarouselComponent({super.key, required this.viewType});

  @override
  _AdsCarouselComponentState createState() => _AdsCarouselComponentState();
}

class _AdsCarouselComponentState extends State<AdsCarouselComponent> {
  List<AdsDetails> ads = [];
  late final ArcadiaCloud _arcadiaCloud;
  late final User? user;
  late Future<void> _loadAdsFuture;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
    user = FirebaseAuth.instance.currentUser;
    _loadAdsFuture = _loadAds();
  }

  Future<void> _loadAds() async {
    ads = Provider.of<AdsDetailsProvider>(context, listen: false).getEpicAds();
    // Notify the widget to rebuild with the new ads data
    setState(() {});

    if (user == null) return;

    final token = await user?.getIdToken();

    if (token == null) return;

    // Record the view of the first ad
    if (ads.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _arcadiaCloud.recordAdView(widget.viewType.toString().split('.').last,
            ads[0].partner, ads[0].id, token);
      });
    }
  }

  void _onPageChanged(
      int index, CarouselPageChangedReason reason, ViewType viewType) async {
    if (user == null) return;

    final token = await user?.getIdToken();

    if (token == null) return;

    final String partnerId = ads[index].partner;
    final String adId = ads[index].id;

    _arcadiaCloud.recordAdView(
        viewType.toString().split('.').last, partnerId, adId, token);
  }

  void _onAdTap(int index, Uri url, ViewType viewType) async {
    if (user == null) return;

    final token = await user?.getIdToken();

    if (token == null) return;

    final String partnerId = ads[index].partner;
    final String adId = ads[index].id;

    _arcadiaCloud.recordAdClick(
        viewType.toString().split('.').last, partnerId, adId, token);

    launchURL(url);
  }

  @override
  Widget build(BuildContext context) {
    final double height = isTabletCarouselAds(context) ? 180.0 : 90.0;

    return FutureBuilder(
      future: _loadAdsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading ads'));
        } else if (ads.isEmpty) {
          return const Center(child: Text('No ads available'));
        } else {
          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              autoPlay: ads.length > 1,
              autoPlayInterval: const Duration(seconds: 8),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) =>
                  _onPageChanged(index, reason, widget.viewType),
            ),
            items: ads.asMap().entries.map((entry) {
              // items: ads.map((ad) {
              int index = entry.key;
              AdsDetails ad = entry.value;
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                      onTap: () =>
                          _onAdTap(index, Uri.parse(ad.url), widget.viewType),
                      child: Container(
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
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ));
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}
