class AdsDetails {
  final String tier;
  final String image;
  final String url;

  AdsDetails({required this.tier, required this.image, required this.url});

  factory AdsDetails.fromJson(String id, Map<String, dynamic> json) {
    return AdsDetails(
      image: json['image'],
      tier: json['tier'],
      url: json['url'],
    );
  }

  // factory AdsDetails.fromJson(Map<String, dynamic> json, String id) {
  //   return AdsDetails(
  //     id: id,
  //     image: json['image'],
  //     url: json['url'],
  //   );
  // }
}
