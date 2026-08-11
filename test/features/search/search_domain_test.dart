import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/search/domain/entities/search_filter.dart';
import 'package:winger/features/search/domain/entities/search_history.dart';
import 'package:winger/features/search/domain/entities/search_query.dart';
import 'package:winger/features/search/domain/entities/search_sort.dart';

void main() {
  group('Search Domain Entity Tests', () {
    test('SearchSort maps from code correctly', () {
      expect(SearchSort.fromCode('PRICE_ASC'), SearchSort.priceLowToHigh);
      expect(SearchSort.fromCode('NEWEST'), SearchSort.newest);
      expect(SearchSort.fromCode('INVALID'), SearchSort.relevance);
    });

    test('SearchHistory adds query and maintains bounded max size', () {
      var history = const SearchHistory();
      expect(history.items, isEmpty);

      for (int i = 1; i <= 15; i++) {
        history = history.add('query_$i');
      }

      expect(history.items.length, 10);
      expect(history.items.first, 'query_15');
    });

    test('SearchHistory removes query and clears correctly', () {
      var history = const SearchHistory().add('phone').add('watch');
      expect(history.items, ['watch', 'phone']);

      history = history.remove('phone');
      expect(history.items, ['watch']);

      history = history.clear();
      expect(history.items, isEmpty);
    });

    test('SearchQuery reports empty status accurately', () {
      const emptyQuery = SearchQuery(term: '   ');
      const validQuery = SearchQuery(term: 'shoes');

      expect(emptyQuery.isEmpty, isTrue);
      expect(validQuery.isNotEmpty, isTrue);
    });

    test('SearchFilter supports copyWith immutability', () {
      const filter = SearchFilter(inStockOnly: false);
      final updated =
          filter.copyWith(inStockOnly: true, sort: SearchSort.priceHighToLow);

      expect(updated.inStockOnly, isTrue);
      expect(updated.sort, SearchSort.priceHighToLow);
    });
  });
}
