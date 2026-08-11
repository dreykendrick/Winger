/// Domain entity for local recent search history.
class SearchHistory {
  final List<String> items;

  const SearchHistory({this.items = const []});

  SearchHistory add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return this;
    final updated =
        [trimmed, ...items.where((e) => e != trimmed)].take(10).toList();
    return SearchHistory(items: updated);
  }

  SearchHistory remove(String query) {
    return SearchHistory(items: items.where((e) => e != query).toList());
  }

  SearchHistory clear() => const SearchHistory(items: []);
}
