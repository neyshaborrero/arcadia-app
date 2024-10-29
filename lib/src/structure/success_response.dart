class SuccessResponse {
  final bool success;

  SuccessResponse({
    required this.success,
  });

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'],
    );
  }
}
