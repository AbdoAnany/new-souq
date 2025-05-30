import '../../core/usecase/usecase.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../repositories/repositories.dart';
import '../entities/product.dart';

class GetFeaturedProducts implements NoParamsUseCase<List<Product>> {
  final ProductRepository repository;
  
  GetFeaturedProducts(this.repository);
    @override
  Future<Result<List<Product>, Failure>> call() async {
    return await repository.getFeaturedProducts();
  }
}

class GetProductById implements UseCase<Product, String> {
  final ProductRepository repository;
  
  GetProductById(this.repository);
    @override
  Future<Result<Product, Failure>> call(String productId) async {
    return await repository.getProductById(productId);
  }
}

class SearchProducts implements UseCase<List<Product>, SearchProductsParams> {
  final ProductRepository repository;
  
  SearchProducts(this.repository);
    @override
  Future<Result<List<Product>, Failure>> call(SearchProductsParams params) async {
    return await repository.getProducts(
      limit: params.limit,
      searchQuery: params.query,
      categoryId: params.categoryId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      minRating: params.minRating,
      sortBy: params.sortBy,
      descending: params.descending,
    );
  }
}

class GetProductsByCategory implements UseCase<List<Product>, GetProductsByCategoryParams> {
  final ProductRepository repository;
  
  GetProductsByCategory(this.repository);
    @override
  Future<Result<List<Product>, Failure>> call(GetProductsByCategoryParams params) async {
    return await repository.getProducts(
      categoryId: params.categoryId,
      limit: params.limit,
      sortBy: params.sortBy,
      descending: params.descending,
    );
  }
}

class GetNewArrivals implements NoParamsUseCase<List<Product>> {
  final ProductRepository repository;
  
  GetNewArrivals(this.repository);
    @override
  Future<Result<List<Product>, Failure>> call() async {
    return await repository.getNewArrivals();
  }
}

class GetRelatedProducts implements UseCase<List<Product>, String> {
  final ProductRepository repository;
  
  GetRelatedProducts(this.repository);
    @override
  Future<Result<List<Product>, Failure>> call(String productId) async {
    return await repository.getRelatedProducts(productId);
  }
}

// Parameter classes
class SearchProductsParams {
  final String query;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final int? page;
  final int? limit;
  final String? sortBy;
  final bool? descending;
  
  const SearchProductsParams({
    required this.query,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.page,
    this.limit,
    this.sortBy,
    this.descending,
  });
    @override
  SearchProductsParams copyWith({
    String? query,
    Map<String, dynamic>? filters,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int? page,
    int? limit,
    String? sortBy,
    bool? descending,
  }) {
    return SearchProductsParams(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
}

class GetProductsByCategoryParams {
  final String categoryId;
  final int? page;
  final int? limit;
  final String? sortBy;
  final bool? descending;
  
  const GetProductsByCategoryParams({
    required this.categoryId,
    this.page,
    this.limit,
    this.sortBy,
    this.descending,
  });
  
  @override
  GetProductsByCategoryParams copyWith({
    String? categoryId,
    int? page,
    int? limit,
    String? sortBy,
    bool? descending,
  }) {
    return GetProductsByCategoryParams(
      categoryId: categoryId ?? this.categoryId,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
}
