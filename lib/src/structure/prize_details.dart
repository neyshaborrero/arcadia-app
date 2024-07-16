class PrizeDetails {
  final String id;
  final String title;
  final String image;
  final int token;
  final String poweredBy;
  final String description;
  final String termsurl;
  final String raffleDate;

  PrizeDetails(
      {required this.id,
      required this.title,
      required this.image,
      required this.token,
      required this.poweredBy,
      required this.description,
      required this.termsurl,
      required this.raffleDate});

  factory PrizeDetails.fromJson(Map<String, dynamic> json, String id) {
    return PrizeDetails(
        id: id,
        title: json['title'],
        image: json['image'],
        token: json['token'],
        poweredBy: json['poweredBy'],
        description: json['description'],
        termsurl: json['termsurl'],
        raffleDate: json['raffleDate']);
  }
}
