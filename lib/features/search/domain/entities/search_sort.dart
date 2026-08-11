/// Enum representing backend-supported search sorting options.
enum SearchSort {
  relevance('RELEVANCE', 'Relevance'),
  priceLowToHigh('PRICE_ASC', 'Price: Low to High'),
  priceHighToLow('PRICE_DESC', 'Price: High to Low'),
  newest('NEWEST', 'Newest Arrivals'),
  rating('RATING', 'Customer Rating');

  final String code;
  final String label;

  const SearchSort(this.code, this.label);

  factory SearchSort.fromCode(String? code) {
    return SearchSort.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => SearchSort.relevance,
    );
  }
}
