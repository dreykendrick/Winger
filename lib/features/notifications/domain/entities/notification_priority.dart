/// Enum representing backend notification priority levels.
enum NotificationPriority {
  low('LOW'),
  normal('NORMAL'),
  high('HIGH'),
  critical('CRITICAL');

  final String code;

  const NotificationPriority(this.code);

  factory NotificationPriority.fromCode(String? code) {
    return NotificationPriority.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => NotificationPriority.normal,
    );
  }
}
