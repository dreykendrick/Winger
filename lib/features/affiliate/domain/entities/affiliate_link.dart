/// Domain entity representing a generated Affiliate Referral Link.
class AffiliateLink {
  final String id;
  final String productId;
  final String productTitle;
  final String referralCode;
  final String trackingUrl;
  final int totalClicks;
  final int totalConversions;
  final DateTime createdAt;

  const AffiliateLink({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.referralCode,
    required this.trackingUrl,
    this.totalClicks = 0,
    this.totalConversions = 0,
    required this.createdAt,
  });

  factory AffiliateLink.fromJson(Map<String, dynamic> json) {
    return AffiliateLink(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productTitle: json['product_title'] as String? ?? 'Promoted Product',
      referralCode: json['referral_code'] as String? ?? '',
      trackingUrl: json['tracking_url'] as String? ??
          'https://winger.co/affiliate/${json['referral_code']}',
      totalClicks: json['total_clicks'] as int? ?? 0,
      totalConversions: json['total_conversions'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_title': productTitle,
        'referral_code': referralCode,
        'tracking_url': trackingUrl,
        'total_clicks': totalClicks,
        'total_conversions': totalConversions,
        'created_at': createdAt.toIso8601String(),
      };
}
