/// Domain entity for Customer Order Dispute details.
class DisputeInfo {
  final String id;
  final String orderId;
  final String reason;
  final String status; // e.g. OPEN, UNDER_REVIEW, RESOLVED, REJECTED
  final DateTime createdAt;
  final String? resolutionNotes;

  const DisputeInfo({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolutionNotes,
  });

  factory DisputeInfo.fromJson(Map<String, dynamic> json) {
    return DisputeInfo(
      id: json['id'] as String? ?? 'disp_1',
      orderId: json['order_id'] as String? ?? '',
      reason: json['reason'] as String? ?? 'Item damaged or not received',
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      resolutionNotes: json['resolution_notes'] as String?,
    );
  }
}
