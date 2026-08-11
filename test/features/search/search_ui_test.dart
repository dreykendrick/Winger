import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/search/domain/entities/search_suggestion.dart';
import 'package:winger/features/search/presentation/widgets/recent_searches_list.dart';
import 'package:winger/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:winger/features/search/presentation/widgets/search_suggestion_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Search UI Component Widget Tests', () {
    testWidgets('SearchBarWidget renders input text field',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'headphones');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              controller: controller,
              onChanged: (_) {},
              onSubmitted: (_) {},
              onFilterTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('headphones'), findsOneWidget);
    });

    testWidgets('RecentSearchesList renders search chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentSearchesList(
              searches: const ['headphones', 'watch'],
              onSelect: (_) {},
              onDelete: (_) {},
              onClearAll: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('headphones'), findsOneWidget);
      expect(find.text('watch'), findsOneWidget);
    });

    testWidgets('SearchSuggestionTile renders text',
        (WidgetTester tester) async {
      const suggestion = SearchSuggestion(text: 'headphones in Electronics');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchSuggestionTile(
              suggestion: suggestion,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('headphones in Electronics'), findsOneWidget);
    });
  });
}
