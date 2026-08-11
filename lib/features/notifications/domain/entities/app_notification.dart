import 'notification_priority.dart';
import 'notification_type.dart';

/// Domain entity representing a Backend Notification.
class AppNotification {
  final String id;
  final String actorId;
  final String? workspaceId;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final String? entityType;
  final String? entityId;
  final String? deepLink;
  final Map<String, dynamic> metadata;

  const AppNotification({
    required this.id,
    required this.actorId,
    this.workspaceId,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    this.entityType,
    this.entityId,
    this.deepLink,
    this.metadata = const {},
  });

  AppNotification copyWith({
    String? id,
    String? actorId,
    String? workspaceId,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    String? entityType,
    String? entityId,
    String? deepLink,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deepLink: deepLink ?? this.deepLink,
      metadata: metadata ?? this.metadata,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readAtStr = json['read_at'] as String?;
    final isReadBool = json['is_read'] as bool? ?? (readAtStr != null);

    return AppNotification(
      id: json['id'] as String? ?? '',
      actorId: json['actor_id'] as String? ?? json['user_id'] as String? ?? '',
      workspaceId: json['workspace_id'] as String?,
      type: NotificationType.fromCode(json['type'] as String?),
      priority: NotificationPriority.fromCode(json['priority'] as String?),
      title: json['title'] as String? ?? 'Winger Notification',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      readAt: readAtStr != null ? DateTime.parse(readAtStr) : null,
      isRead: isReadBool,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      deepLink: json['deep_link'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'actor_id': actorId,
        'workspace_id': workspaceId,
        'type': type.code,
        'priority': priority.code,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'read_at': readAt?.toIso8601String(),
        'is_read': isRead,
        'entity_type': entityType,
        'entity_id': entityId,
        'deep_link': deepLink,
        'metadata': metadata,
      };
}
