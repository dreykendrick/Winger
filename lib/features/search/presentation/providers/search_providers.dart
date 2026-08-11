import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winger/core/network/supabase_client_provider.dart';
import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/search/data/repositories/search_repository_impl.dart';
import 'package:winger/features/search/domain/entities/search_filter.dart';
import 'package:winger/features/search/domain/entities/search_history.dart';
import 'package:winger/features/search/domain/entities/search_result.dart';
import 'package:winger/features/search/domain/entities/search_suggestion.dart';
import 'package:winger/features/search/domain/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(supabaseClient: SupabaseService.client);
});

final searchHistoryStateProvider =
    StateProvider<SearchHistory>((ref) => const SearchHistory());

final activeSearchQueryStateProvider = StateProvider<String>((ref) => '');

final activeSearchFilterStateProvider =
    StateProvider<SearchFilter>((ref) => const SearchFilter());

final searchResultsProvider = FutureProvider<SearchResult>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  final query = ref.watch(activeSearchQueryStateProvider);
  final filter = ref.watch(activeSearchFilterStateProvider);

  final result = await repository.searchProducts(query: query, filter: filter);
  return result.valueOrNull ??
      SearchResult(
          products: const [], totalCount: 0, query: query, filter: filter);
});

final searchSuggestionsProvider =
    FutureProvider.family<List<SearchSuggestion>, String>((ref, query) async {
  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.getSuggestions(query);
  return result.valueOrNull ?? const [];
});

final popularTagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.getPopularSearchTags();
  return result.valueOrNull ?? const [];
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.getCategories();
  return result.valueOrNull ?? const [];
});
