import 'product_media.dart';
import 'product_review.dart';
import 'product_variant.dart';

/// Core domain entity for Marketplace Product.
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? compareAtPrice;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final String vendorName;
  final String? vendorAvatarUrl;
  final String categoryName;
  final List<ProductMedia> mediaList;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.isAvailable,
    this.rating = 5.0,
    this.reviewCount = 0,
    required this.vendorName,
    this.vendorAvatarUrl,
    required this.categoryName,
    this.mediaList = const [],
    this.variants = const [],
    this.reviews = const [],
  });

  String get primaryImageUrl => mediaList
      .firstWhere(
        (m) => m.isPrimary,
        orElse: () => mediaList.isNotEmpty
            ? mediaList.first
            : const ProductMedia(id: '0', url: ''),
      )
      .url;

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
  double get affiliateCommissionRate => 0.10;
  bool get isAffiliateEligible => true;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String? ??
          json['name'] as String? ??
          'Untitled Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num? ?? 5.0).toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      vendorName: json['vendor_name'] as String? ?? 'Vendor',
      vendorAvatarUrl: json['vendor_avatar_url'] as String?,
      categoryName: json['category_name'] as String? ?? 'General',
      mediaList: (json['media'] as List<dynamic>?)
              ?.map((e) => ProductMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'compare_at_price': compareAtPrice,
        'is_available': isAvailable,
        'rating': rating,
        'review_count': reviewCount,
        'vendor_name': vendorName,
        'vendor_avatar_url': vendorAvatarUrl,
        'category_name': categoryName,
        'media': mediaList.map((e) => e.toJson()).toList(),
        'variants': variants.map((e) => e.toJson()).toList(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
      };
}
