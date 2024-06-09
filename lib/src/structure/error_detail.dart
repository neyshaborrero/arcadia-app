class ErrorDetail {
  final String? path;
  final String message;

  ErrorDetail({
    this.path,
    required this.message,
  });

  // Factory constructor to create an ErrorDetail from a JSON map
  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      path: json['path'] as String?,
      message: json['message'] as String,
    );
  }

  // Method to convert an ErrorDetail to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'path': path,
    };
  }

  @override
  String toString() {
    return '{path: $path, message: $message}';
  }
}
