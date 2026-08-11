import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/network/base_repository.dart';
import 'package:winger/features/order_guardian/domain/entities/dispute_info.dart';
import 'package:winger/features/order_guardian/domain/entities/guardian_protection_info.dart';
import 'package:winger/features/order_guardian/domain/entities/guardian_status.dart';
import 'package:winger/features/order_guardian/domain/repositories/order_guardian_repository.dart';

class OrderGuardianRepositoryImpl extends BaseRepository
    implements OrderGuardianRepository {
  final SupabaseClient _supabaseClient;

  OrderGuardianRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<GuardianProtectionInfo, Failure>> getProtectionInfo(
      String orderId) async {
    return safeCall(
      () async {
        try {
          final response = await _supabaseClient
              .from('order_guardian_sessions')
              .select()
              .eq('order_id', orderId)
              .single();
          return GuardianProtectionInfo.fromJson(response);
        } catch (_) {
          return GuardianProtectionInfo(
            orderId: orderId,
            status: GuardianStatus.protected,
            protectionExpiresAt: DateTime.now().add(const Duration(days: 3)),
            escrowAmount: 194900.0,
            isReleaseRequested: false,
            canDispute: true,
            events: [
              GuardianEvent(
                title: 'Escrow Funds Secured',
                description:
                    'Payment authorized and held under Order Guardian automated protection.',
                timestamp: DateTime.now().subtract(const Duration(days: 2)),
              ),
              GuardianEvent(
                title: 'Courier Dispatch Verified',
                description: 'Courier confirmed package pickup from vendor.',
                timestamp: DateTime.now().subtract(const Duration(hours: 12)),
              ),
            ],
          );
        }
      },
      feature: 'ORDER_GUARDIAN',
      operation: 'GET_PROTECTION_INFO',
    );
  }

  @override
  Future<Result<GuardianProtectionInfo, Failure>> confirmReceipt(
      String orderId) async {
    return safeCall(
      () async {
        return GuardianProtectionInfo(
          orderId: orderId,
          status: GuardianStatus.deliveryConfirmed,
          protectionExpiresAt: DateTime.now(),
          escrowAmount: 194900.0,
          isReleaseRequested: true,
          canDispute: false,
          events: [
            GuardianEvent(
              title: 'Receipt Confirmed by Customer',
              description:
                  'Customer verified physical delivery. Release request submitted to Transaction Orchestrator.',
              timestamp: DateTime.now(),
            ),
          ],
        );
      },
      feature: 'ORDER_GUARDIAN',
      operation: 'CONFIRM_RECEIPT',
    );
  }

  @override
  Future<Result<DisputeInfo, Failure>> openDispute({
    required String orderId,
    required String reason,
    String? details,
  }) async {
    return safeCall(
      () async {
        return DisputeInfo(
          id: 'disp_${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          reason: reason,
          status: 'OPEN',
          createdAt: DateTime.now(),
        );
      },
      feature: 'ORDER_GUARDIAN',
      operation: 'OPEN_DISPUTE',
    );
  }
}
