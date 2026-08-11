import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:winger/features/marketplace/presentation/widgets/product_card.dart';
import 'package:winger/features/search/presentation/providers/search_providers.dart';
import 'package:winger/features/search/presentation/widgets/discovery_feed_widget.dart';
import 'package:winger/features/search/presentation/widgets/recent_searches_list.dart';
import 'package:winger/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:winger/features/search/presentation/widgets/search_filter_bottom_sheet.dart';
import 'package:winger/features/search/presentation/widgets/search_suggestion_tile.dart';
import 'package:winger/shared/components/winger_empty_state.dart';
import 'package:winger/shared/components/winger_loading.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(activeSearchQueryStateProvider.notifier).state = query;
    });
  }

  void _performSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _searchController.text = trimmed;
    ref.read(activeSearchQueryStateProvider.notifier).state = trimmed;

    final currentHistory = ref.read(searchHistoryStateProvider);
    ref.read(searchHistoryStateProvider.notifier).state =
        currentHistory.add(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final activeQuery = ref.watch(activeSearchQueryStateProvider);
    final activeFilter = ref.watch(activeSearchFilterStateProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final history = ref.watch(searchHistoryStateProvider);
    final popularTagsAsync = ref.watch(popularTagsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final isSearching = activeQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: SearchBarWidget(
          controller: _searchController,
          onChanged: _onQueryChanged,
          onSubmitted: _performSearch,
          onFilterTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => SearchFilterBottomSheet(
                initialFilter: activeFilter,
                onApply: (newFilter) {
                  ref.read(activeSearchFilterStateProvider.notifier).state =
                      newFilter;
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isSearching) ...[
              RecentSearchesList(
                searches: history.items,
                onSelect: (q) => _performSearch(q),
                onDelete: (q) {
                  ref.read(searchHistoryStateProvider.notifier).state =
                      history.remove(q);
                },
                onClearAll: () {
                  ref.read(searchHistoryStateProvider.notifier).state =
                      history.clear();
                },
              ),
              const SizedBox(height: 16),
              DiscoveryFeedWidget(
                categories: categoriesAsync.valueOrNull ?? const [],
                popularTags: popularTagsAsync.valueOrNull ?? const [],
                onTagTap: (tag) => _performSearch(tag),
                onCategoryTap: (cat) => context.push('/category/${cat.id}'),
              ),
            ] else ...[
              ref.watch(searchSuggestionsProvider(activeQuery)).when(
                    data: (suggestions) {
                      if (suggestions.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: suggestions
                            .map((s) => SearchSuggestionTile(
                                  suggestion: s,
                                  onTap: () => _performSearch(s.text),
                                ))
                            .toList(),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
              const SizedBox(height: 16),
              resultsAsync.when(
                data: (result) {
                  if (result.isEmpty) {
                    return WingerEmptyState(
                      title: 'No Products Found',
                      message:
                          'We couldn\'t find any products matching "$activeQuery". Try another term or clear filters.',
                      icon: Icons.search_off_outlined,
                      actionLabel: 'Clear Search',
                      onAction: () {
                        _searchController.clear();
                        _onQueryChanged('');
                      },
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Showing ${result.products.length} results for "$activeQuery"',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: result.products.length,
                        itemBuilder: (context, index) {
                          final product = result.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () =>
                                context.push('/products/${product.id}'),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () =>
                    const WingerLoading(message: 'Searching marketplace...'),
                error: (err, _) => Center(child: Text('Search failed: $err')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
