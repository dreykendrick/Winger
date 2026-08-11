/// Domain entity for Workspace Role.
class Role {
  final String id;
  final String name;
  final String key;

  const Role({
    required this.id,
    required this.name,
    required this.key,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['key'] as String? ?? 'Member',
      key: json['key'] as String? ?? 'MEMBER',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'key': key,
      };
}
