import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winger/app/config/env_config.dart';
import 'package:winger/app/providers/app_providers.dart';
import 'package:winger/core/storage/preferences_service.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_conversion.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_link.dart';
import 'package:winger/features/affiliate/domain/entities/affiliate_product.dart';
import 'package:winger/features/affiliate/presentation/widgets/affiliate_link_tile.dart';
import 'package:winger/features/affiliate/presentation/widgets/affiliate_metrics_card.dart';
import 'package:winger/features/affiliate/presentation/widgets/affiliate_product_card.dart';
import 'package:winger/features/affiliate/presentation/widgets/commission_badge.dart';
import 'package:winger/features/affiliate/presentation/widgets/conversion_tile.dart';

class _TestHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  group('Affiliate UI Component Widget Tests', () {
    late PreferencesService prefsService;

    setUp(() async {
      await EnvConfig.load(Environment.development);
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(sharedPrefs);
    });

    testWidgets('CommissionBadge renders APPROVED badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommissionBadge(status: 'APPROVED'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('APPROVED'), findsOneWidget);
    });

    testWidgets('AffiliateMetricsCard renders label and value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AffiliateMetricsCard(
              label: 'Total Clicks',
              value: '142',
              icon: Icons.mouse,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Clicks'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
    });

    testWidgets('AffiliateProductCard renders title, price and promote button',
        (WidgetTester tester) async {
      const product = AffiliateProduct(
        productId: 'p1',
        title: 'Smart Watch',
        imageUrl: '',
        price: 90000.0,
        commissionRate: 0.10,
        estimatedCommission: 9000.0,
        vendorName: 'Tech Merchant',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefsService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AffiliateProductCard(
                product: product,
                onGenerateLink: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Smart Watch'), findsOneWidget);
      expect(find.text('Promote'), findsOneWidget);
    });

    testWidgets('AffiliateLinkTile renders tracking URL and copy button',
        (WidgetTester tester) async {
      final link = AffiliateLink(
        id: 'l1',
        productId: 'p1',
        productTitle: 'Running Shoes',
        referralCode: 'REF99',
        trackingUrl: 'https://winger.co/affiliate/REF99',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffiliateLinkTile(link: link),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Running Shoes'), findsOneWidget);
      expect(find.text('https://winger.co/affiliate/REF99'), findsOneWidget);
    });

    testWidgets('ConversionTile renders order ID and status',
        (WidgetTester tester) async {
      final conversion = AffiliateConversion(
        id: 'c1',
        orderId: 'ORD_55',
        productTitle: 'Leather Wallet',
        orderAmount: 40000.0,
        commissionAmount: 4000.0,
        status: 'PENDING',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversionTile(conversion: conversion),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leather Wallet'), findsOneWidget);
      expect(find.text('Order ID: ORD_55'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}
