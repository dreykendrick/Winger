import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_conversion.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_earnings.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_link.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_performance.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_product.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_profile.dart';

void main() {
  group('Affiliate Domain Entity Tests', () {
    test('AffiliateProfile deserializes JSON correctly', () {
      final json = {
        'id': 'aff_77',
        'user_id': 'u77',
        'referral_code': 'PARTNER77',
        'status': 'ACTIVE',
        'total_clicks': 100,
        'total_conversions': 10,
        'total_earnings': 250000.0,
      };

      final profile = AffiliateProfile.fromJson(json);
      expect(profile.referralCode, 'PARTNER77');
      expect(profile.isActive, isTrue);
      expect(profile.totalClicks, 100);
    });

    test('AffiliateProduct calculates estimated commission', () {
      final json = {
        'id': 'p10',
        'title': 'Camera',
        'price': 500000.0,
        'commission_rate': 0.10,
        'vendor_name': 'Tech World',
      };

      final product = AffiliateProduct.fromJson(json);
      expect(product.price, 500000.0);
      expect(product.commissionRate, 0.10);
      expect(product.estimatedCommission, 50000.0);
    });

    test('AffiliateLink holds tracking URL and click counters', () {
      final json = {
        'id': 'l1',
        'product_id': 'p1',
        'product_title': 'Shoes',
        'referral_code': 'REF1',
        'tracking_url': 'https://winger.co/affiliate/REF1?product=p1',
        'total_clicks': 45,
        'total_conversions': 5,
      };

      final link = AffiliateLink.fromJson(json);
      expect(link.trackingUrl, 'https://winger.co/affiliate/REF1?product=p1');
      expect(link.totalClicks, 45);
    });

    test('AffiliateConversion parses commission amount and status', () {
      final json = {
        'id': 'c1',
        'order_id': 'ORD_100',
        'product_title': 'Headphones',
        'order_amount': 200000.0,
        'commission_amount': 20000.0,
        'status': 'APPROVED',
      };

      final conversion = AffiliateConversion.fromJson(json);
      expect(conversion.commissionAmount, 20000.0);
      expect(conversion.status, 'APPROVED');
    });

    test('AffiliateEarnings calculates total lifetime earnings', () {
      const earnings = AffiliateEarnings(
        pendingCommissions: 20000.0,
        approvedCommissions: 100000.0,
        availableEarnings: 80000.0,
        paidEarnings: 50000.0,
      );

      expect(earnings.totalLifetimeEarnings, 150000.0);
    });

    test('AffiliatePerformanceMetrics calculates conversion rate', () {
      final json = {
        'period': '30d',
        'total_clicks': 200,
        'total_conversions': 20,
        'total_commission': 400000.0,
      };

      final perf = AffiliatePerformanceMetrics.fromJson(json);
      expect(perf.conversionRate, 10.0);
    });
  });
}
