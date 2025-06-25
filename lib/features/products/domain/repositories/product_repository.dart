import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

// Product repository interface
abstract class ProductRepository {
  // Get products
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String productId);

  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts();

  Future<Either<Failure, List<ProductEntity>>> getNewArrivals();

  Future<Either<Failure, List<ProductEntity>>> getBestSellers();

  Future<Either<Failure, List<ProductEntity>>> getRecommendedProducts(String userId);

  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String categoryId);

  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);

  // Admin operations
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product);

  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product);

  Future<Either<Failure, void>> deleteProduct(String productId);

  Future<Either<Failure, void>> updateProductStock({
    required String productId,
    required int quantity,
  });

  // Categories
  Future<Either<Failure, List<String>>> getCategories();
}
