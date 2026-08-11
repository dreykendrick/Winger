import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import '../../data/repositories/order_guardian_repository_impl.dart';
import '../../domain/entities/guardian_protection_info.dart';
import '../../domain/repositories/order_guardian_repository.dart';

final orderGuardianRepositoryProvider =
    Provider<OrderGuardianRepository>((ref) {
  return OrderGuardianRepositoryImpl(supabaseClient: SupabaseService.client);
});

final orderGuardianProtectionProvider =
    FutureProvider.family<GuardianProtectionInfo?, String>(
        (ref, orderId) async {
  final repository = ref.watch(orderGuardianRepositoryProvider);
  final result = await repository.getProtectionInfo(orderId);
  return result.valueOrNull;
});
