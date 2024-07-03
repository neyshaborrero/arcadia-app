class AdsDetails {
  final String id;
  final String image;
  final String url;

  AdsDetails({required this.id, required this.image, required this.url});

  // factory AdsDetails.fromJson(Map<String, dynamic> json, String id) {
  //   return AdsDetails(
  //     id: id,
  //     image: json['image'],
  //     url: json['url'],
  //   );
  // }
}
