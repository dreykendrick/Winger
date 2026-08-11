import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../entities/marketplace_filter.dart';
import '../entities/product.dart';

/// Abstract contract for Marketplace Product Catalog repository.
abstract class MarketplaceRepository {
  Future<Result<List<Product>, Failure>> fetchProducts({
    int page = 1,
    int pageSize = 20,
    MarketplaceFilter? filter,
  });

  Future<Result<Product, Failure>> fetchProductDetail(String productId);

  Future<Result<List<Category>, Failure>> fetchCategories();

  Future<Result<List<Product>, Failure>> fetchFeaturedProducts();
}
