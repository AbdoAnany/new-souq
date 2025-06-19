import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/base_classes.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product_usecases.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final int? limit;
  final String? category;
  final double? minPrice;
  final double? maxPrice;

  const GetProductsEvent({
    this.limit,
    this.category,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [limit, category, minPrice, maxPrice];
}

class GetProductByIdEvent extends ProductEvent {
  final String id;

  const GetProductByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetFeaturedProductsEvent extends ProductEvent {}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class GetCategoriesEvent extends ProductEvent {}

class GetProductsByCategoryEvent extends ProductEvent {
  final String category;

  const GetProductsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductLoaded extends ProductState {
  final ProductEntity product;

  const ProductLoaded(this.product);

  @override
  List<Object> get props => [product];
}

class FeaturedProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const FeaturedProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductSearchResults extends ProductState {
  final List<ProductEntity> products;
  final String query;

  const ProductSearchResults(this.products, this.query);

  @override
  List<Object> get props => [products, query];
}

class CategoriesLoaded extends ProductState {
  final List<String> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final GetFeaturedProductsUseCase getFeaturedProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
    required this.getFeaturedProductsUseCase,
    required this.searchProductsUseCase,
  }) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductByIdEvent>(_onGetProductById);
    on<GetFeaturedProductsEvent>(_onGetFeaturedProducts);
    on<SearchProductsEvent>(_onSearchProducts);
  }
  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductsUseCase(GetProductsParams(
      page: 1,
      limit: event.limit ?? 20,
      categoryId: event.category,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
    ));

    result.fold(
      (failure) => emit(ProductError(_mapFailureToMessage(failure))),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onGetProductById(
    GetProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductByIdUseCase(event.id);

    result.fold(
      (failure) => emit(ProductError(_mapFailureToMessage(failure))),
      (product) => emit(ProductLoaded(product)),
    );
  }

  Future<void> _onGetFeaturedProducts(
    GetFeaturedProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getFeaturedProductsUseCase(NoParams());

    result.fold(
      (failure) => emit(ProductError(_mapFailureToMessage(failure))),
      (products) => emit(FeaturedProductsLoaded(products)),
    );
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await searchProductsUseCase(event.query);

    result.fold(
      (failure) => emit(ProductError(_mapFailureToMessage(failure))),
      (products) => emit(ProductSearchResults(products, event.query)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return 'Server error occurred. Please try again.';
      case const (CacheFailure):
        return 'Local data error occurred.';
      case const (NetworkFailure):
        return 'Please check your internet connection.';
      case const (ValidationFailure):
        return 'Invalid input provided.';
      default:
        return 'Unexpected error occurred. Please try again.';
    }
  }
}
