class Token {
  final String id;
  final int value;
  final String createdAt;
  final String imageComplete;
  final String imageIncomplete;
  final String description;
  final String title;

  Token({
    required this.id,
    required this.value,
    required this.createdAt,
    required this.imageComplete,
    required this.imageIncomplete,
    required this.description,
    required this.title,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        id: json['id'] ?? '',
        value: json['value'] ?? 0,
        createdAt: json['createdAt'] ?? '',
        imageComplete: json['imageComplete'] ?? '',
        imageIncomplete: json['imageIncomplete'] ?? '',
        description: json['description'] ?? '',
        title: json['title'] ?? '');
  }
}
