import 'search_sort.dart';

/// Domain entity representing immutable search filter parameters.
class SearchFilter {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool inStockOnly;
  final String? vendorId;
  final double? minRating;
  final SearchSort sort;

  const SearchFilter({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.inStockOnly = false,
    this.vendorId,
    this.minRating,
    this.sort = SearchSort.relevance,
  });

  SearchFilter copyWith({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    String? vendorId,
    double? minRating,
    SearchSort? sort,
  }) {
    return SearchFilter(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      vendorId: vendorId ?? this.vendorId,
      minRating: minRating ?? this.minRating,
      sort: sort ?? this.sort,
    );
  }
}
