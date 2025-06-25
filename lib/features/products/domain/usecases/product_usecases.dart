import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/base_classes.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

// Get products use case
class GetProductsUseCase implements UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;

  const GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) async {
    return await repository.getProducts(
      page: params.page,
      limit: params.limit,
      categoryId: params.categoryId,
      searchQuery: params.searchQuery,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      sortBy: params.sortBy,
    );
  }
}

class GetProductsParams extends Equatable {
  final int page;
  final int limit;
  final String? categoryId;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const GetProductsParams({
    this.page = 1,
    this.limit = 20,
    this.categoryId,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        categoryId,
        searchQuery,
        minPrice,
        maxPrice,
        sortBy,
      ];
}

// Get product by ID use case
class GetProductByIdUseCase implements UseCase<ProductEntity, String> {
  final ProductRepository repository;

  const GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(String productId) async {
    return await repository.getProductById(productId);
  }
}

// Get featured products use case
class GetFeaturedProductsUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  const GetFeaturedProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getFeaturedProducts();
  }
}

// Search products use case
class SearchProductsUseCase implements UseCase<List<ProductEntity>, String> {
  final ProductRepository repository;

  const SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(String query) async {
    return await repository.searchProducts(query);
  }
}
