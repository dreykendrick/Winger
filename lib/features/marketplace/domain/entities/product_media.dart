/// Domain entity for Product Images and Video Media.
class ProductMedia {
  final String id;
  final String url;
  final bool isPrimary;
  final String mediaType;

  const ProductMedia({
    required this.id,
    required this.url,
    this.isPrimary = false,
    this.mediaType = 'image',
  });

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      mediaType: json['media_type'] as String? ?? 'image',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'is_primary': isPrimary,
        'media_type': mediaType,
      };
}
