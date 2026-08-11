/// Enum representing backend notification categories.
enum NotificationType {
  order('ORDER', 'Order Update'),
  payment('PAYMENT', 'Payment Update'),
  wallet('WALLET', 'Wallet Activity'),
  withdrawal('WITHDRAWAL', 'Withdrawal Request'),
  affiliate('AFFILIATE', 'Affiliate Activity'),
  guardian('GUARDIAN', 'Order Guardian Escrow'),
  vendor('VENDOR', 'Merchant Alert'),
  system('SYSTEM', 'System Announcement'),
  unknown('UNKNOWN', 'Notification');

  final String code;
  final String label;

  const NotificationType(this.code, this.label);

  factory NotificationType.fromCode(String? code) {
    return NotificationType.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => NotificationType.unknown,
    );
  }
}
