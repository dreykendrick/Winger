enum SuggestionType { query, category, product, vendor }

/// Domain entity representing search auto-complete suggestions.
class SearchSuggestion {
  final String text;
  final SuggestionType type;
  final String? targetId;

  const SearchSuggestion({
    required this.text,
    this.type = SuggestionType.query,
    this.targetId,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      text: json['text'] as String? ?? json['title'] as String? ?? '',
      type: SuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SuggestionType.query,
      ),
      targetId: json['target_id'] as String?,
    );
  }
}
