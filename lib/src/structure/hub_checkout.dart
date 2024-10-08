class HubCheckOut {
  final bool success;

  HubCheckOut({required this.success});

  factory HubCheckOut.fromJson(Map<String, dynamic> json) {
    return HubCheckOut(
      success: json['success'] ?? false,
    );
  }
}
