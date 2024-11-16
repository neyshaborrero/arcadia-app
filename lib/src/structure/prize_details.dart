class PrizeDetails {
  final String id;
  final String title;
  final String image;
  final int token;
  final String poweredBy;
  final String description;
  final String termsurl;
  final String raffleDate;
  final bool? lootPrize;

  PrizeDetails(
      {required this.id,
      required this.title,
      required this.image,
      required this.token,
      required this.poweredBy,
      required this.description,
      required this.termsurl,
      required this.raffleDate,
      this.lootPrize});

  factory PrizeDetails.fromJson(Map<String, dynamic> json, String id) {
    return PrizeDetails(
        id: id,
        title: json['title'],
        image: json['image'],
        token: json['token'] ?? 0,
        poweredBy: json['poweredBy'] ?? "",
        description: json['description'],
        termsurl: json['termsurl'] ?? "",
        raffleDate: json['raffleDate'] ?? "",
        lootPrize: json['lootPrize'] ?? false);
  }
}
