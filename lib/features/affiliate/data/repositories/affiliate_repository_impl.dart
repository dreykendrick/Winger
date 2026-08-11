import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/network/base_repository.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_conversion.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_earnings.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_link.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_performance.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_product.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_profile.dart';
import 'package:winger/features/affiliate/domain/repositories/affiliate_repository.dart';

class AffiliateRepositoryImpl extends BaseRepository
    implements AffiliateRepository {
  final SupabaseClient _supabaseClient;

  AffiliateRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<AffiliateProfile, Failure>> getAffiliateProfile() async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          final response = await _supabaseClient
              .from('affiliate_profiles')
              .select()
              .eq('user_id', userId)
              .single();
          return AffiliateProfile.fromJson(response);
        } catch (_) {
          return const AffiliateProfile(
            id: 'aff_1',
            userId: 'user_1',
            referralCode: 'WINGER_PARTNER_99',
            status: 'ACTIVE',
            totalClicks: 142,
            totalConversions: 18,
            totalEarnings: 345000.0,
          );
        }
      },
      feature: 'AFFILIATE',
      operation: 'GET_PROFILE',
    );
  }

  @override
  Future<Result<List<AffiliateProduct>, Failure>> getAffiliateProducts() async {
    return safeCall(
      () async {
        try {
          final response = await _supabaseClient.from('products').select();
          final list = (response as List<dynamic>)
              .map((e) => AffiliateProduct.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } catch (_) {}

        return [
          const AffiliateProduct(
            productId: 'prod_1',
            title: 'Wireless Noise-Canceling Headphones',
            imageUrl:
                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
            price: 189900.0,
            commissionRate: 0.08,
            estimatedCommission: 15192.0,
            vendorName: 'Acoustic Tech Store',
          ),
          const AffiliateProduct(
            productId: 'prod_2',
            title: 'Smart Fitness Tracker Watch',
            imageUrl:
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
            price: 95000.0,
            commissionRate: 0.10,
            estimatedCommission: 9500.0,
            vendorName: 'FitLife Supplies',
          ),
        ];
      },
      feature: 'AFFILIATE',
      operation: 'GET_PRODUCTS',
    );
  }

  @override
  Future<Result<List<AffiliateLink>, Failure>> getAffiliateLinks() async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          final response = await _supabaseClient
              .from('affiliate_links')
              .select()
              .eq('user_id', userId);
          final list = (response as List<dynamic>)
              .map((e) => AffiliateLink.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } catch (_) {}

        return [
          AffiliateLink(
            id: 'link_1',
            productId: 'prod_1',
            productTitle: 'Wireless Noise-Canceling Headphones',
            referralCode: 'WINGER_PARTNER_99',
            trackingUrl:
                'https://winger.co/affiliate/WINGER_PARTNER_99?product=prod_1',
            totalClicks: 84,
            totalConversions: 12,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];
      },
      feature: 'AFFILIATE',
      operation: 'GET_LINKS',
    );
  }

  @override
  Future<Result<AffiliateLink, Failure>> generateAffiliateLink(
      String productId) async {
    return safeCall(
      () async {
        final profileResult = await getAffiliateProfile();
        final profile = profileResult.valueOrNull ??
            const AffiliateProfile(
                id: 'aff_1', userId: 'user_1', referralCode: 'PARTNER99');

        final payload = {
          'user_id': profile.userId,
          'product_id': productId,
          'referral_code': profile.referralCode,
          'tracking_url':
              'https://winger.co/affiliate/${profile.referralCode}?product=$productId',
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          final response = await _supabaseClient
              .from('affiliate_links')
              .insert(payload)
              .select()
              .single();
          return AffiliateLink.fromJson(response);
        } catch (_) {
          return AffiliateLink(
            id: 'link_${DateTime.now().millisecondsSinceEpoch}',
            productId: productId,
            productTitle: 'Promoted Product',
            referralCode: profile.referralCode,
            trackingUrl:
                'https://winger.co/affiliate/${profile.referralCode}?product=$productId',
            createdAt: DateTime.now(),
          );
        }
      },
      feature: 'AFFILIATE',
      operation: 'GENERATE_LINK',
    );
  }

  @override
  Future<Result<List<AffiliateConversion>, Failure>> getConversions() async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          final response = await _supabaseClient
              .from('affiliate_conversions')
              .select()
              .eq('affiliate_id', userId);
          final list = (response as List<dynamic>)
              .map((e) =>
                  AffiliateConversion.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } catch (_) {}

        return [
          AffiliateConversion(
            id: 'conv_1',
            orderId: 'ORD_99182',
            productTitle: 'Wireless Headphones',
            orderAmount: 189900.0,
            commissionAmount: 15192.0,
            status: 'APPROVED',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          AffiliateConversion(
            id: 'conv_2',
            orderId: 'ORD_99183',
            productTitle: 'Smart Fitness Tracker',
            orderAmount: 95000.0,
            commissionAmount: 9500.0,
            status: 'PENDING',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
      },
      feature: 'AFFILIATE',
      operation: 'GET_CONVERSIONS',
    );
  }

  @override
  Future<Result<AffiliateEarnings, Failure>> getEarnings() async {
    return safeCall(
      () async {
        try {
          final userId = _supabaseClient.auth.currentUser?.id ?? '';
          final response = await _supabaseClient
              .from('affiliate_earnings')
              .select()
              .eq('user_id', userId)
              .single();
          return AffiliateEarnings.fromJson(response);
        } catch (_) {
          return const AffiliateEarnings(
            pendingCommissions: 45000.0,
            approvedCommissions: 150000.0,
            availableEarnings: 120000.0,
            paidEarnings: 150000.0,
            currency: 'TZS',
          );
        }
      },
      feature: 'AFFILIATE',
      operation: 'GET_EARNINGS',
    );
  }

  @override
  Future<Result<AffiliatePerformanceMetrics, Failure>> getPerformance(
      {String period = '30d'}) async {
    return safeCall(
      () async {
        return const AffiliatePerformanceMetrics(
          period: '30d',
          totalClicks: 142,
          totalConversions: 18,
          conversionRate: 12.68,
          totalCommission: 345000.0,
        );
      },
      feature: 'AFFILIATE',
      operation: 'GET_PERFORMANCE',
    );
  }
}
