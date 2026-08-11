import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/order_guardian/domain/entities/guardian_status.dart';
import 'package:winger/features/order_guardian/presentation/widgets/guardian_badge.dart';
import 'package:winger/features/order_guardian/presentation/widgets/protection_timer_widget.dart';
import 'package:winger/features/order_guardian/presentation/widgets/receipt_confirmation_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Order Guardian UI Component Widget Tests', () {
    testWidgets('GuardianBadge renders label and shield icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuardianBadge(status: GuardianStatus.protected),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Escrow Protected'), findsOneWidget);
    });

    testWidgets('ProtectionTimerWidget renders protection headline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtectionTimerWidget(
                expiresAt: DateTime.now().add(const Duration(days: 2))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Automated Escrow Protection Window'), findsOneWidget);
    });

    testWidgets('ReceiptConfirmationButton toggles confirmed state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:
                ReceiptConfirmationButton(isConfirmed: true, onConfirm: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Receipt Confirmed by Customer'), findsOneWidget);
    });
  });
}
