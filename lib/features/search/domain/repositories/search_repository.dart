import 'package:winger/core/errors/failures.dart';
import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/marketplace/domain/entities/product.dart';
import '../entities/search_filter.dart';
import '../entities/search_result.dart';
import '../entities/search_suggestion.dart';

abstract class SearchRepository {
  Future<Result<SearchResult, Failure>> searchProducts({
    required String query,
    SearchFilter filter = const SearchFilter(),
    int limit = 20,
    int offset = 0,
  });

  Future<Result<List<SearchSuggestion>, Failure>> getSuggestions(String query);
  Future<Result<List<Category>, Failure>> getCategories();
  Future<Result<List<Product>, Failure>> getTrendingProducts();
  Future<Result<List<String>, Failure>> getPopularSearchTags();
}
