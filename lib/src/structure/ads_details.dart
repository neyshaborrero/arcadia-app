class AdsDetails {
  final String tier;
  final String image;
  final String url;
  final String partner;
  final String id;

  AdsDetails(
      {required this.tier,
      required this.image,
      required this.url,
      required this.partner,
      required this.id});

  factory AdsDetails.fromJson(String id, Map<String, dynamic> json) {
    return AdsDetails(
        image: json['image'],
        tier: json['tier'],
        url: json['url'],
        partner: json['partner'],
        id: id);
  }
}
