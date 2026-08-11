/// Sort options supported by Winger Backend V2.
enum MarketplaceSortOption {
  newest('created_at.desc', 'Newest Arrivals'),
  priceLowToHigh('price.asc', 'Price: Low to High'),
  priceHighToLow('price.desc', 'Price: High to Low'),
  rating('rating.desc', 'Highest Rated');

  final String queryParam;
  final String label;
  const MarketplaceSortOption(this.queryParam, this.label);
}

/// Filter state object for Marketplace search and feed queries.
class MarketplaceFilter {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool inStockOnly;
  final double? minRating;
  final String? searchQuery;
  final MarketplaceSortOption sortOption;

  const MarketplaceFilter({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.inStockOnly = false,
    this.minRating,
    this.searchQuery,
    this.sortOption = MarketplaceSortOption.newest,
  });

  MarketplaceFilter copyWith({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    double? minRating,
    String? searchQuery,
    MarketplaceSortOption? sortOption,
  }) {
    return MarketplaceFilter(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      minRating: minRating ?? this.minRating,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
