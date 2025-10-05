class MapPoint {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final DateTime createdAt;
  final String? imageUrl;

  MapPoint({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'image_url': imageUrl,
      };

  factory MapPoint.fromJson(Map<String, dynamic> json) => MapPoint(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        category: json['category'] ?? 'default',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        imageUrl: json['image_url'],
      );
}

enum PointCategory {
  restaurant('restaurant', 'Restauracja', '🍴'),
  attraction('attraction', 'Atrakcja', '🎯'),
  hotel('hotel', 'Hotel', '🏨'),
  transport('transport', 'Transport', '🚌'),
  shopping('shopping', 'Zakupy', '🛍️'),
  nature('nature', 'Natura', '🌲'),
  culture('culture', 'Kultura', '🏛️'),
  other('other', 'Inne', '📍');

  const PointCategory(this.value, this.displayName, this.emoji);

  final String value;
  final String displayName;
  final String emoji;

  static PointCategory fromValue(String value) {
    return PointCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => PointCategory.other,
    );
  }
}