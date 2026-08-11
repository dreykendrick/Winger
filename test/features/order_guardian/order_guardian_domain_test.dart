import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/order_guardian/domain/entities/dispute_info.dart';
import 'package:winger/features/order_guardian/domain/entities/guardian_protection_info.dart';
import 'package:winger/features/order_guardian/domain/entities/guardian_status.dart';

void main() {
  group('Order Guardian Domain Entity Tests', () {
    test('GuardianStatus converts from string codes', () {
      expect(GuardianStatus.fromCode('PROTECTED'), GuardianStatus.protected);
      expect(GuardianStatus.fromCode('DELIVERY_CONFIRMED'),
          GuardianStatus.deliveryConfirmed);
    });

    test('GuardianProtectionInfo calculates expiration state', () {
      final activeInfo = GuardianProtectionInfo(
        orderId: 'ord_1',
        status: GuardianStatus.protected,
        protectionExpiresAt: DateTime.now().add(const Duration(days: 1)),
        escrowAmount: 100000.0,
      );

      final expiredInfo = GuardianProtectionInfo(
        orderId: 'ord_2',
        status: GuardianStatus.protected,
        protectionExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
        escrowAmount: 100000.0,
      );

      expect(activeInfo.isExpired, isFalse);
      expect(expiredInfo.isExpired, isTrue);
    });

    test('DisputeInfo parses reason and status', () {
      final json = {
        'id': 'disp_10',
        'order_id': 'ord_10',
        'reason': 'Item defective',
        'status': 'OPEN',
      };

      final dispute = DisputeInfo.fromJson(json);
      expect(dispute.reason, 'Item defective');
      expect(dispute.status, 'OPEN');
    });
  });
}
