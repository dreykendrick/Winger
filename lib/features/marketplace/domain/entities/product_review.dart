/// Domain entity for Customer Product Review.
class ProductReview {
  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Verified Buyer',
      rating: (json['rating'] as num? ?? 5.0).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_name': authorName,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };
}
