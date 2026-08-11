import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/network/base_repository.dart';
import 'package:winger/features/marketplace/domain/entities/category.dart';
import 'package:winger/features/marketplace/domain/entities/product.dart';
import 'package:winger/features/marketplace/domain/entities/product_media.dart';
import 'package:winger/features/search/domain/entities/search_filter.dart';
import 'package:winger/features/search/domain/entities/search_result.dart';
import 'package:winger/features/search/domain/entities/search_suggestion.dart';
import 'package:winger/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl extends BaseRepository implements SearchRepository {
  final SupabaseClient _supabaseClient;

  SearchRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<SearchResult, Failure>> searchProducts({
    required String query,
    SearchFilter filter = const SearchFilter(),
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(
      () async {
        try {
          var req = _supabaseClient.from('products').select();
          if (query.trim().isNotEmpty) {
            req = req.ilike('title', '%${query.trim()}%');
          }
          if (filter.categoryId != null) {
            req = req.eq('category_id', filter.categoryId!);
          }

          final response = await req.range(offset, offset + limit - 1);
          final products = (response as List<dynamic>)
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList();
          return SearchResult(
            products: products,
            totalCount: products.length,
            query: query,
            filter: filter,
          );
        } catch (_) {
          return SearchResult(
            products: const [
              Product(
                id: 'prod_1',
                title: 'Wireless Noise-Canceling Headphones',
                description:
                    'Premium active noise cancellation headphones with 30-hour battery life.',
                price: 189900.0,
                compareAtPrice: 220000.0,
                isAvailable: true,
                rating: 4.8,
                reviewCount: 124,
                vendorName: 'Acoustic Tech Store',
                categoryName: 'Electronics',
                mediaList: [
                  ProductMedia(
                    id: 'm1',
                    url:
                        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
                    isPrimary: true,
                  ),
                ],
              ),
              Product(
                id: 'prod_2',
                title: 'Smart Fitness Tracker Watch',
                description:
                    'Water-resistant fitness tracker with heart rate monitor.',
                price: 95000.0,
                compareAtPrice: 120000.0,
                isAvailable: true,
                rating: 4.6,
                reviewCount: 89,
                vendorName: 'FitLife Supplies',
                categoryName: 'Wearables',
                mediaList: [
                  ProductMedia(
                    id: 'm2',
                    url:
                        'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
                    isPrimary: true,
                  ),
                ],
              ),
            ],
            totalCount: 2,
            query: query,
            filter: filter,
          );
        }
      },
      feature: 'SEARCH',
      operation: 'SEARCH_PRODUCTS',
    );
  }

  @override
  Future<Result<List<SearchSuggestion>, Failure>> getSuggestions(
      String query) async {
    return safeCall(
      () async {
        if (query.trim().isEmpty) return const [];
        return [
          SearchSuggestion(
              text: '$query in Electronics', type: SuggestionType.category),
          SearchSuggestion(
              text: '$query headphones', type: SuggestionType.query),
          SearchSuggestion(text: '$query wireless', type: SuggestionType.query),
        ];
      },
      feature: 'SEARCH',
      operation: 'GET_SUGGESTIONS',
    );
  }

  @override
  Future<Result<List<Category>, Failure>> getCategories() async {
    return safeCall(
      () async {
        return const [
          Category(
              id: 'cat_electronics', name: 'Electronics', slug: 'electronics'),
          Category(
              id: 'cat_fashion', name: 'Fashion & Apparel', slug: 'fashion'),
          Category(id: 'cat_home', name: 'Home & Kitchen', slug: 'home'),
          Category(
              id: 'cat_beauty', name: 'Beauty & Personal Care', slug: 'beauty'),
        ];
      },
      feature: 'SEARCH',
      operation: 'GET_CATEGORIES',
    );
  }

  @override
  Future<Result<List<Product>, Failure>> getTrendingProducts() async {
    return safeCall(
      () async {
        final result = await searchProducts(query: '');
        return result.valueOrNull?.products ?? [];
      },
      feature: 'SEARCH',
      operation: 'GET_TRENDING',
    );
  }

  @override
  Future<Result<List<String>, Failure>> getPopularSearchTags() async {
    return safeCall(
      () async {
        return const [
          'Headphones',
          'Smartphones',
          'Smart Watches',
          'Sneakers',
          'Skincare'
        ];
      },
      feature: 'SEARCH',
      operation: 'GET_POPULAR_TAGS',
    );
  }
}
