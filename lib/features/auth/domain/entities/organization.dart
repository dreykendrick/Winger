/// Domain entity for Organization parent legal entity.
class Organization {
  final String id;
  final String name;
  final String slug;

  const Organization({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
      };
}
