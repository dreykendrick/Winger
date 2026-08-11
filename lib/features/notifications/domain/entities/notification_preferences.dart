/// Domain entity for Notification Category Preferences.
class NotificationPreferences {
  final bool orderUpdates;
  final bool paymentUpdates;
  final bool walletUpdates;
  final bool affiliateUpdates;
  final bool guardianUpdates;
  final bool systemAnnouncements;

  const NotificationPreferences({
    this.orderUpdates = true,
    this.paymentUpdates = true,
    this.walletUpdates = true,
    this.affiliateUpdates = true,
    this.guardianUpdates = true,
    this.systemAnnouncements = true,
  });

  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? paymentUpdates,
    bool? walletUpdates,
    bool? affiliateUpdates,
    bool? guardianUpdates,
    bool? systemAnnouncements,
  }) {
    return NotificationPreferences(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      paymentUpdates: paymentUpdates ?? this.paymentUpdates,
      walletUpdates: walletUpdates ?? this.walletUpdates,
      affiliateUpdates: affiliateUpdates ?? this.affiliateUpdates,
      guardianUpdates: guardianUpdates ?? this.guardianUpdates,
      systemAnnouncements: systemAnnouncements ?? this.systemAnnouncements,
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      orderUpdates: json['order_updates'] as bool? ?? true,
      paymentUpdates: json['payment_updates'] as bool? ?? true,
      walletUpdates: json['wallet_updates'] as bool? ?? true,
      affiliateUpdates: json['affiliate_updates'] as bool? ?? true,
      guardianUpdates: json['guardian_updates'] as bool? ?? true,
      systemAnnouncements: json['system_announcements'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_updates': orderUpdates,
        'payment_updates': paymentUpdates,
        'wallet_updates': walletUpdates,
        'affiliate_updates': affiliateUpdates,
        'guardian_updates': guardianUpdates,
        'system_announcements': systemAnnouncements,
      };
}
