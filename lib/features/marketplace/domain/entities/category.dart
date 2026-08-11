/// Domain entity representing a Marketplace Product Category.
class Category {
  final String id;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? parentId;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'General',
      slug: json['slug'] as String? ?? '',
      iconUrl: json['icon_url'] as String?,
      parentId: json['parent_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'icon_url': iconUrl,
        'parent_id': parentId,
      };
}
