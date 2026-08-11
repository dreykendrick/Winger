import 'package:flutter/material.dart';
import 'package:winger/features/search/domain/entities/search_suggestion.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class SearchSuggestionTile extends StatelessWidget {
  final SearchSuggestion suggestion;
  final VoidCallback onTap;

  const SearchSuggestionTile({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (suggestion.type) {
      case SuggestionType.category:
        icon = Icons.category_outlined;
        break;
      case SuggestionType.product:
        icon = Icons.shopping_bag_outlined;
        break;
      case SuggestionType.vendor:
        icon = Icons.storefront_outlined;
        break;
      default:
        icon = Icons.search;
        break;
    }

    return ListTile(
      leading: Icon(icon, color: WingerTokens.primaryEmerald, size: 20),
      title: Text(suggestion.text, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
