/// Domain entity representing aggregated Affiliate Performance Metrics.
class AffiliatePerformanceMetrics {
  final String period;
  final int totalClicks;
  final int totalConversions;
  final double conversionRate;
  final double totalCommission;

  const AffiliatePerformanceMetrics({
    this.period = '30d',
    this.totalClicks = 0,
    this.totalConversions = 0,
    this.conversionRate = 0.0,
    this.totalCommission = 0.0,
  });

  factory AffiliatePerformanceMetrics.fromJson(Map<String, dynamic> json) {
    final clicks = json['total_clicks'] as int? ?? 0;
    final conversions = json['total_conversions'] as int? ?? 0;
    final rate = clicks > 0 ? (conversions / clicks) * 100 : 0.0;

    return AffiliatePerformanceMetrics(
      period: json['period'] as String? ?? '30d',
      totalClicks: clicks,
      totalConversions: conversions,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? rate,
      totalCommission: (json['total_commission'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'total_clicks': totalClicks,
        'total_conversions': totalConversions,
        'conversion_rate': conversionRate,
        'total_commission': totalCommission,
      };
}
