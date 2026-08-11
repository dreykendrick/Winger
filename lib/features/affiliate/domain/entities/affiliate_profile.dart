/// Domain entity representing an Authenticated Affiliate Profile.
class AffiliateProfile {
  final String id;
  final String userId;
  final String referralCode;
  final String status;
  final int totalClicks;
  final int totalConversions;
  final double totalEarnings;

  const AffiliateProfile({
    required this.id,
    required this.userId,
    required this.referralCode,
    this.status = 'ACTIVE',
    this.totalClicks = 0,
    this.totalConversions = 0,
    this.totalEarnings = 0.0,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory AffiliateProfile.fromJson(Map<String, dynamic> json) {
    return AffiliateProfile(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      referralCode: json['referral_code'] as String? ??
          json['code'] as String? ??
          'AFFILIATE',
      status: json['status'] as String? ?? 'ACTIVE',
      totalClicks: json['total_clicks'] as int? ?? 0,
      totalConversions: json['total_conversions'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'referral_code': referralCode,
        'status': status,
        'total_clicks': totalClicks,
        'total_conversions': totalConversions,
        'total_earnings': totalEarnings,
      };
}
