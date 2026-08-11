import 'search_filter.dart';

/// Domain entity representing a search request payload.
class SearchQuery {
  final String term;
  final SearchFilter filter;

  const SearchQuery({
    this.term = '',
    this.filter = const SearchFilter(),
  });

  bool get isEmpty => term.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  SearchQuery copyWith({
    String? term,
    SearchFilter? filter,
  }) {
    return SearchQuery(
      term: term ?? this.term,
      filter: filter ?? this.filter,
    );
  }
}
