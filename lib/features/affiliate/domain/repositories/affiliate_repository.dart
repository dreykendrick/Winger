import 'package:winger/core/errors/failures.dart';
import '../entities/affiliate_conversion.dart';
import '../entities/affiliate_earnings.dart';
import '../entities/affiliate_link.dart';
import '../entities/affiliate_performance.dart';
import '../entities/affiliate_product.dart';
import '../entities/affiliate_profile.dart';

abstract class AffiliateRepository {
  Future<Result<AffiliateProfile, Failure>> getAffiliateProfile();

  Future<Result<List<AffiliateProduct>, Failure>> getAffiliateProducts();

  Future<Result<List<AffiliateLink>, Failure>> getAffiliateLinks();

  Future<Result<AffiliateLink, Failure>> generateAffiliateLink(
      String productId);

  Future<Result<List<AffiliateConversion>, Failure>> getConversions();

  Future<Result<AffiliateEarnings, Failure>> getEarnings();

  Future<Result<AffiliatePerformanceMetrics, Failure>> getPerformance(
      {String period = '30d'});
}
