import '../../core/usecase/usecase.dart';
import '../../core/utils/result.dart';
import '../repositories/repositories.dart';
import '../../models/product.dart';

class GetFeaturedProducts implements NoParamsUseCase<Result<List<Product>>> {
  final ProductRepository repository;
  
  GetFeaturedProducts(this.repository);
  
  @override
  Future<Result<List<Product>>> call() async {
    return await repository.getFeaturedProducts();
  }
}

class GetProductById implements UseCase<Result<Product>, String> {
  final ProductRepository repository;
  
  GetProductById(this.repository);
  
  @override
  Future<Result<Product>> call(String productId) async {
    return await repository.getProductById(productId);
  }
}

class SearchProducts implements UseCase<Result<List<Product>>, SearchProductsParams> {
  final ProductRepository repository;
  
  SearchProducts(this.repository);
  
  @override
  Future<Result<List<Product>>> call(SearchProductsParams params) async {
    return await repository.getProducts(
      page: params.page,
      limit: params.limit,
      search: params.query,
      categoryId: params.categoryId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      minRating: params.minRating,
      sortBy: params.sortBy,
      descending: params.descending,
    );
  }
}

class GetProductsByCategory implements UseCase<Result<List<Product>>, GetProductsByCategoryParams> {
  final ProductRepository repository;
  
  GetProductsByCategory(this.repository);
  
  @override
  Future<Result<List<Product>>> call(GetProductsByCategoryParams params) async {
    return await repository.getProducts(
      categoryId: params.categoryId,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
      descending: params.descending,
    );
  }
}

class GetNewArrivals implements NoParamsUseCase<Result<List<Product>>> {
  final ProductRepository repository;
  
  GetNewArrivals(this.repository);
  
  @override
  Future<Result<List<Product>>> call() async {
    return await repository.getNewArrivals();
  }
}

class GetRelatedProducts implements UseCase<Result<List<Product>>, String> {
  final ProductRepository repository;
  
  GetRelatedProducts(this.repository);
  
  @override
  Future<Result<List<Product>>> call(String productId) async {
    return await repository.getRelatedProducts(productId);
  }
}

// Parameter classes
class SearchProductsParams extends SearchParams {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  
  const SearchProductsParams({
    required super.query,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    super.page,
    super.limit,
    super.sortBy,
    super.descending,
  });
  
  @override
  SearchProductsParams copyWith({
    String? query,
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

class GetProductsByCategoryParams extends PaginationParams {
  final String categoryId;
  
  const GetProductsByCategoryParams({
    required this.categoryId,
    super.page,
    super.limit,
    super.sortBy,
    super.descending,
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
