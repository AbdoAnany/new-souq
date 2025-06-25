import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import '../../data/services/order_cache_service.dart';

/// Parameters for paginated orders request
class PaginatedOrdersParams extends Equatable {
  final String userId;
  final int page;
  final int limit;
  final String? status;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final OrderSortBy sortBy;
  final SortOrder sortOrder;
  final bool useCache;

  const PaginatedOrdersParams({
    required this.userId,
    this.page = 1,
    this.limit = 20,
    this.status,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.sortBy = OrderSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
    this.useCache = true,
  });

  @override
  List<Object?> get props => [
        userId,
        page,
        limit,
        status,
        searchQuery,
        startDate,
        endDate,
        sortBy,
        sortOrder,
        useCache,
      ];

  PaginatedOrdersParams copyWith({
    String? userId,
    int? page,
    int? limit,
    String? status,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    OrderSortBy? sortBy,
    SortOrder? sortOrder,
    bool? useCache,
  }) {
    return PaginatedOrdersParams(
      userId: userId ?? this.userId,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      useCache: useCache ?? this.useCache,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'page': page,
      'limit': limit,
      'status': status,
      'searchQuery': searchQuery,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'sortBy': sortBy.name,
      'sortOrder': sortOrder.name,
      'useCache': useCache,
    };
  }
}

/// Sorting options for orders
enum OrderSortBy {
  createdAt,
  updatedAt,
  totalAmount,
  status,
  orderNumber,
}

enum SortOrder {
  ascending,
  descending,
}

/// Use case for getting paginated orders with caching support
class GetPaginatedOrdersUseCase
    implements UseCase<PaginatedResult<OrderEntity>, PaginatedOrdersParams> {
  final OrderRepository repository;
  final OrderCacheService cacheService;

  GetPaginatedOrdersUseCase({
    required this.repository,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, PaginatedResult<OrderEntity>>> call(
      PaginatedOrdersParams params) async {
    try {
      // Check cache first if enabled and it's the first page
      if (params.useCache && params.page == 1) {
        final cachedResult = _getCachedResult(params);
        if (cachedResult != null) {
          return Right(cachedResult);
        }
      }

      // Fetch from repository
      final result = await repository.getPaginatedOrders(params);

      return result.fold(
        (failure) => Left(failure),
        (paginatedResult) async {
          // Cache the result if it's the first page
          if (params.page == 1 && params.useCache) {
            await _cacheResult(paginatedResult, params);
          }

          return Right(paginatedResult);
        },
      );
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get paginated orders: ${e.toString()}'));
    }
  }

  /// Get cached result if available and valid
  PaginatedResult<OrderEntity>? _getCachedResult(PaginatedOrdersParams params) {
    try {
      final cacheKey = _generateCacheKey(params);
      final cachedOrders = <OrderEntity>[];

      // This is a simplified cache check - in reality you might want
      // to implement more sophisticated caching with query-specific keys
      final cachedOrderIds = cacheService.getCachedOrderIds();

      for (final orderId in cachedOrderIds.take(params.limit)) {
        final cachedOrder = cacheService.getCachedOrder(orderId);
        if (cachedOrder != null && _matchesFilter(cachedOrder, params)) {
          cachedOrders.add(cachedOrder);
        }
      }

      if (cachedOrders.length >= params.limit) {
        return PaginatedResult(
          data: cachedOrders.take(params.limit).toList(),
          pagination: PaginationMeta.fromData(
            currentPage: params.page,
            totalItems: cachedOrders.length,
            itemsPerPage: params.limit,
          ),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache the paginated result
  Future<void> _cacheResult(
      PaginatedResult<OrderEntity> result, PaginatedOrdersParams params) async {
    try {
      await cacheService.cacheOrders(result.data);
    } catch (e) {
      // Cache errors should not affect the main operation
    }
  }

  /// Generate cache key for the specific query
  String _generateCacheKey(PaginatedOrdersParams params) {
    return 'orders_${params.userId}_${params.status ?? 'all'}_${params.page}_${params.limit}';
  }

  /// Check if cached order matches the filter criteria
  bool _matchesFilter(OrderEntity order, PaginatedOrdersParams params) {
    // Status filter
    if (params.status != null && order.status.name != params.status) {
      return false;
    }

    // Search query filter
    if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
      final query = params.searchQuery!.toLowerCase();
      if (!order.orderNumber.toLowerCase().contains(query) &&
          !order.items
              .any((item) => item.productName.toLowerCase().contains(query))) {
        return false;
      }
    }

    // Date range filter
    if (params.startDate != null &&
        order.orderDate.isBefore(params.startDate!)) {
      return false;
    }

    if (params.endDate != null && order.orderDate.isAfter(params.endDate!)) {
      return false;
    }

    return true;
  }
}

/// Use case for preloading orders into cache
class PreloadOrdersUseCase implements UseCase<void, PreloadOrdersParams> {
  final OrderRepository repository;
  final OrderCacheService cacheService;

  PreloadOrdersUseCase({
    required this.repository,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, void>> call(PreloadOrdersParams params) async {
    try {
      final result = await repository.getRecentOrders(
        userId: params.userId,
        limit: params.limit,
      );

      return result.fold(
        (failure) => Left(failure),
        (orders) async {
          await cacheService.preloadOrders(orders);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to preload orders: ${e.toString()}'));
    }
  }
}

/// Parameters for preloading orders
class PreloadOrdersParams extends Equatable {
  final String userId;
  final int limit;

  const PreloadOrdersParams({
    required this.userId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Use case for clearing order cache
class ClearOrderCacheUseCase implements UseCase<void, NoParams> {
  final OrderCacheService cacheService;

  ClearOrderCacheUseCase(this.cacheService);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await cacheService.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to clear cache: ${e.toString()}'));
    }
  }
}

/// Use case for getting cache statistics
class GetCacheStatsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final OrderCacheService cacheService;

  GetCacheStatsUseCase(this.cacheService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    try {
      final stats = cacheService.getCacheStats();
      return Right(stats);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to get cache stats: ${e.toString()}'));
    }
  }
}
