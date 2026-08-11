/// Domain entity representing Backend-Authoritative Affiliate Earnings.
class AffiliateEarnings {
  final double pendingCommissions;
  final double approvedCommissions;
  final double availableEarnings;
  final double paidEarnings;
  final String currency;

  const AffiliateEarnings({
    this.pendingCommissions = 0.0,
    this.approvedCommissions = 0.0,
    this.availableEarnings = 0.0,
    this.paidEarnings = 0.0,
    this.currency = 'TZS',
  });

  double get totalLifetimeEarnings => approvedCommissions + paidEarnings;

  factory AffiliateEarnings.fromJson(Map<String, dynamic> json) {
    return AffiliateEarnings(
      pendingCommissions:
          (json['pending_commissions'] as num? ?? 0.0).toDouble(),
      approvedCommissions:
          (json['approved_commissions'] as num? ?? 0.0).toDouble(),
      availableEarnings: (json['available_earnings'] as num? ?? 0.0).toDouble(),
      paidEarnings: (json['paid_earnings'] as num? ?? 0.0).toDouble(),
      currency: json['currency'] as String? ?? 'TZS',
    );
  }

  Map<String, dynamic> toJson() => {
        'pending_commissions': pendingCommissions,
        'approved_commissions': approvedCommissions,
        'available_earnings': availableEarnings,
        'paid_earnings': paidEarnings,
        'currency': currency,
      };
}
