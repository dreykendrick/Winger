import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/checkout/domain/entities/checkout_order_summary.dart';
import 'package:winger/features/checkout/domain/entities/delivery_option.dart';
import 'package:winger/features/checkout/domain/entities/payment_method.dart';
import 'package:winger/features/checkout/presentation/widgets/checkout_order_summary_card.dart';
import 'package:winger/features/checkout/presentation/widgets/checkout_step_header.dart';
import 'package:winger/features/checkout/presentation/widgets/customer_info_form.dart';
import 'package:winger/features/checkout/presentation/widgets/delivery_options_list.dart';
import 'package:winger/features/checkout/presentation/widgets/payment_method_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Checkout UI Component Widget Tests', () {
    late PreferencesService prefsService;

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(sharedPrefs);
    });

    testWidgets('CheckoutStepHeader renders step labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CheckoutStepHeader(currentStep: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('CustomerInfoForm renders text fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerInfoForm(onChanged: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('DeliveryOptionsList renders shipping choices',
        (WidgetTester tester) async {
      const options = [
        DeliveryOption(
            id: 's1',
            title: 'Standard Delivery',
            fee: 5000.0,
            estimatedDeliveryTime: '2 Days'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryOptionsList(
              options: options,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.text('2 Days'), findsOneWidget);
    });

    testWidgets('PaymentMethodTile renders method name',
        (WidgetTester tester) async {
      const method = PaymentMethod(
        id: 'pm1',
        name: 'Selcom Mobile Money',
        code: 'SELCOM_MOBILE',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentMethodTile(
              method: method,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selcom Mobile Money'), findsOneWidget);
    });

    testWidgets('CheckoutOrderSummaryCard renders subtotal and total',
        (WidgetTester tester) async {
      const summary = CheckoutOrderSummary(
        subtotal: 100000.0,
        deliveryFee: 5000.0,
        totalAmount: 105000.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutOrderSummaryCard(summary: summary),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Delivery Fee'), findsOneWidget);
    });
  });
}
