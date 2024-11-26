class HubCheckin {
  final String hubId;

  HubCheckin({required this.hubId});

  factory HubCheckin.fromJson(Map<String, dynamic> json) {
    return HubCheckin(
      hubId: json['hubId'] ?? '',
    );
  }
}
