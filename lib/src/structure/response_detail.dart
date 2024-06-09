import 'error_detail.dart';

class ResponseDetail {
  final List<ErrorDetail> errors;

  ResponseDetail({
    required this.errors,
  });

  // Factory constructor to create a Response from a JSON map
  factory ResponseDetail.fromJson(Map<String, dynamic> json) {
    var errorsList = json['errors'] as List<dynamic>? ?? [];
    List<ErrorDetail> errors = errorsList
        .map((errorJson) =>
            ErrorDetail.fromJson(errorJson as Map<String, dynamic>))
        .toList();

    return ResponseDetail(
      errors: errors,
    );
  }

  // Method to convert a Response to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map((error) => error.toJson()).toList(),
    };
  }
}
