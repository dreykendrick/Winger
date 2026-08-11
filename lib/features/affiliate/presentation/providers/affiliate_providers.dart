import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import '../../data/repositories/affiliate_repository_impl.dart';
import '../../domain/entities/affiliate_conversion.dart';
import '../../domain/entities/affiliate_earnings.dart';
import '../../domain/entities/affiliate_link.dart';
import '../../domain/entities/affiliate_performance.dart';
import '../../domain/entities/affiliate_product.dart';
import '../../domain/entities/affiliate_profile.dart';
import '../../domain/repositories/affiliate_repository.dart';

final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {
  return AffiliateRepositoryImpl(supabaseClient: SupabaseService.client);
});

final affiliateProfileProvider = FutureProvider<AffiliateProfile>((ref) async {
  final repository = ref.watch(affiliateRepositoryProvider);
  final result = await repository.getAffiliateProfile();
  return result.valueOrNull ??
      const AffiliateProfile(
        id: 'aff_1',
        userId: 'user_1',
        referralCode: 'WINGER_PARTNER_99',
      );
});

final affiliateProductsProvider =
    FutureProvider<List<AffiliateProduct>>((ref) async {
  final repository = ref.watch(affiliateRepositoryProvider);
  final result = await repository.getAffiliateProducts();
  return result.valueOrNull ?? const [];
});

final affiliateLinksProvider = FutureProvider<List<AffiliateLink>>((ref) async {
  final repository = ref.watch(affiliateRepositoryProvider);
  final result = await repository.getAffiliateLinks();
  return result.valueOrNull ?? const [];
});

final affiliateConversionsProvider =
    FutureProvider<List<AffiliateConversion>>((ref) async {
  final repository = ref.watch(affiliateRepositoryProvider);
  final result = await repository.getConversions();
  return result.valueOrNull ?? const [];
});

final affiliateEarningsProvider =
    FutureProvider<AffiliateEarnings>((ref) async {
  final repository = ref.watch(affiliateRepositoryProvider);
  final result = await repository.getEarnings();
  return result.valueOrNull ?? const AffiliateEarnings();
});

final affiliatePerformanceProvider =
    FutureProvider<AffiliatePerformanceMetrics>((ref) async {
  final repository = ref.watch(affiliateRepositoryProvider);
  final result = await repository.getPerformance();
  return result.valueOrNull ?? const AffiliatePerformanceMetrics();
});
