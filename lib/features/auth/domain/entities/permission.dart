/// Domain entity for Granular Fine-Grained Permission capability.
class Permission {
  final String key;
  final String? name;

  const Permission({
    required this.key,
    this.name,
  });

  factory Permission.fromJson(dynamic json) {
    if (json is String) {
      return Permission(key: json);
    } else if (json is Map<String, dynamic>) {
      return Permission(
        key: json['key'] as String,
        name: json['name'] as String?,
      );
    }
    return const Permission(key: '');
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
      };
}
