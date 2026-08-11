/// Domain entity for Multi-Tenant Workspace boundary.
class Workspace {
  final String id;
  final String organizationId;
  final String name;
  final String slug;
  final bool isDefault;

  const Workspace({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.slug,
    this.isDefault = false,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Default Store Workspace',
      slug: json['slug'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organization_id': organizationId,
        'name': name,
        'slug': slug,
        'is_default': isDefault,
      };
}
