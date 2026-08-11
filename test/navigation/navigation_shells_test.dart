import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winger/shared/screens/forbidden_screen.dart';
import 'package:winger/shared/screens/not_found_screen.dart';
import 'package:winger/shared/screens/unauthorized_screen.dart';

void main() {
  group('Error & Navigation Screen Rendering Tests', () {
    testWidgets('NotFoundScreen renders 404 message and return CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: NotFoundScreen(path: '/invalid')));
      await tester.pumpAndSettle();

      expect(find.text('404 - Page Not Found'), findsOneWidget);
      expect(find.textContaining('/invalid'), findsOneWidget);
      expect(find.text('Back to Marketplace'), findsOneWidget);
    });

    testWidgets('UnauthorizedScreen renders 401 message and sign in CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: UnauthorizedScreen()));
      await tester.pumpAndSettle();

      expect(find.text('401 - Sign In Required'), findsOneWidget);
      expect(find.text('Sign In Now'), findsOneWidget);
    });

    testWidgets('ForbiddenScreen renders 403 access denied message',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForbiddenScreen()));
      await tester.pumpAndSettle();

      expect(find.text('403 - Access Denied'), findsOneWidget);
      expect(find.text('Return to Marketplace'), findsOneWidget);
    });
  });
}
