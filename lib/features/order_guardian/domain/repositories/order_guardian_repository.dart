import 'package:winger/core/errors/failures.dart';
import '../entities/dispute_info.dart';
import '../entities/guardian_protection_info.dart';

abstract class OrderGuardianRepository {
  Future<Result<GuardianProtectionInfo, Failure>> getProtectionInfo(
      String orderId);
  Future<Result<GuardianProtectionInfo, Failure>> confirmReceipt(
      String orderId);
  Future<Result<DisputeInfo, Failure>> openDispute({
    required String orderId,
    required String reason,
    String? details,
  });
}
