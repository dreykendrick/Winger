import 'package:flutter_test/flutter_test.dart';
import 'package:winger/app/router/route_guards.dart';
import 'package:winger/app/router/route_names.dart';
import 'package:winger/app/router/route_parameters.dart';

void main() {
  group('Navigation Architecture & Route Guard Tests', () {
    test(
        'Public and Checkout routes evaluate as public without authentication requirement',
        () {
      expect(RouteGuards.isPublicOrCheckoutRoute(RouteNames.home), isTrue);
      expect(
          RouteGuards.isPublicOrCheckoutRoute(RouteNames.marketplace), isTrue);
      expect(RouteGuards.isPublicOrCheckoutRoute('/product/prod_123'), isTrue);
      expect(
          RouteGuards.isPublicOrCheckoutRoute('/categories/fashion'), isTrue);
      expect(RouteGuards.isPublicOrCheckoutRoute('/affiliate/REF123'), isTrue);
      expect(RouteGuards.isPublicOrCheckoutRoute(RouteNames.checkout), isTrue);
    });

    test('RouteParameters constants resolve parameter keys', () {
      expect(RouteParameters.productId, 'productId');
      expect(RouteParameters.affiliateCode, 'affiliateCode');
      expect(RouteParameters.checkoutSessionId, 'sessionId');
    });

    test('Guest checkout is recognized as independent of main app auth', () {
      expect(RouteGuards.isPublicOrCheckoutRoute(RouteNames.checkout), isTrue);
    });
  });
}
