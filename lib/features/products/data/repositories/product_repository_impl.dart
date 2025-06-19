import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts(
          limit: limit,
          category: categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
        await localDataSource.cacheProducts(products);
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedProducts = await localDataSource.getCachedProducts();
        return Right(cachedProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final product = await remoteDataSource.getProductById(productId);
        await localDataSource.cacheProduct(product);
        return Right(product);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedProduct = await localDataSource.getCachedProduct(productId);
        if (cachedProduct != null) {
          return Right(cachedProduct);
        } else {
          return const Left(CacheFailure(message: 'Product not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getFeaturedProducts();
        await localDataSource.cacheFeaturedProducts(products);
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedProducts = await localDataSource.getCachedFeaturedProducts();
        return Right(cachedProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals() async {
    // TODO: Implement new arrivals logic
    return getProducts(limit: 10, sortBy: 'createdAt');
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers() async {
    // TODO: Implement best sellers logic
    return getProducts(limit: 10, sortBy: 'popularity');
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRecommendedProducts(String userId) async {
    // TODO: Implement recommendations based on user preferences
    return getFeaturedProducts();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String categoryId) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProductsByCategory(categoryId);
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedProducts = await localDataSource.getCachedProducts();
        final filteredProducts = cachedProducts
            .where((product) => product.categoryId == categoryId)
            .toList();
        return Right(filteredProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.searchProducts(query);
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedProducts = await localDataSource.getCachedProducts();
        // Simple local search in cached products
        final filteredProducts = cachedProducts.where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
        return Right(filteredProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product) async {
    // TODO: Implement product creation (admin functionality)
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product) async {
    // TODO: Implement product update (admin functionality)
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    // TODO: Implement product deletion (admin functionality)
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, void>> updateProductStock({
    required String productId,
    required int quantity,
  }) async {
    // TODO: Implement stock update
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
