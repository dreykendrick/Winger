import 'package:winger/features/marketplace/domain/entities/product.dart';
import 'package:winger/features/search/domain/entities/search_filter.dart';

/// Domain entity representing Backend Search Results.
class SearchResult {
  final List<Product> products;
  final int totalCount;
  final String query;
  final SearchFilter filter;

  const SearchResult({
    required this.products,
    required this.totalCount,
    required this.query,
    required this.filter,
  });

  bool get isEmpty => products.isEmpty;
}
