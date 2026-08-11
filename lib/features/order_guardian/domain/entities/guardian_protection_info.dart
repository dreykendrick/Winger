import 'guardian_status.dart';

class GuardianEvent {
  final String title;
  final String description;
  final DateTime timestamp;

  const GuardianEvent({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory GuardianEvent.fromJson(Map<String, dynamic> json) {
    return GuardianEvent(
      title: json['title'] as String? ?? 'Escrow Event',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Domain entity for Order Guardian Protection details.
class GuardianProtectionInfo {
  final String orderId;
  final GuardianStatus status;
  final DateTime protectionExpiresAt;
  final double escrowAmount;
  final bool isReleaseRequested;
  final bool canDispute;
  final List<GuardianEvent> events;

  const GuardianProtectionInfo({
    required this.orderId,
    required this.status,
    required this.protectionExpiresAt,
    required this.escrowAmount,
    this.isReleaseRequested = false,
    this.canDispute = true,
    this.events = const [],
  });

  bool get isExpired => DateTime.now().isAfter(protectionExpiresAt);

  factory GuardianProtectionInfo.fromJson(Map<String, dynamic> json) {
    return GuardianProtectionInfo(
      orderId: json['order_id'] as String? ?? '',
      status: GuardianStatus.fromCode(json['status'] as String?),
      protectionExpiresAt: json['protection_expires_at'] != null
          ? DateTime.parse(json['protection_expires_at'] as String)
          : DateTime.now().add(const Duration(days: 3)),
      escrowAmount: (json['escrow_amount'] as num? ?? 0.0).toDouble(),
      isReleaseRequested: json['is_release_requested'] as bool? ?? false,
      canDispute: json['can_dispute'] as bool? ?? true,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => GuardianEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
