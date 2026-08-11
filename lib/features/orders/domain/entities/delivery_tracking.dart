class TrackingEvent {
  final String status;
  final String description;
  final DateTime timestamp;

  const TrackingEvent({
    required this.status,
    required this.description,
    required this.timestamp,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      status: json['status'] as String? ?? 'UPDATED',
      description: json['description'] as String? ?? 'Status updated',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Domain entity for Delivery Tracking details.
class DeliveryTracking {
  final String carrierName;
  final String trackingNumber;
  final String estimatedDelivery;
  final List<TrackingEvent> events;

  const DeliveryTracking({
    required this.carrierName,
    required this.trackingNumber,
    required this.estimatedDelivery,
    this.events = const [],
  });

  factory DeliveryTracking.fromJson(Map<String, dynamic> json) {
    return DeliveryTracking(
      carrierName: json['carrier_name'] as String? ?? 'Winger Logistics',
      trackingNumber: json['tracking_number'] as String? ?? 'TRK_0000',
      estimatedDelivery:
          json['estimated_delivery'] as String? ?? '1-3 Business Days',
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
