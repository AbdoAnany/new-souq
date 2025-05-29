import '../result.dart';
import '../failure.dart';

/// Abstract base class for all use cases
abstract class UseCase<Type, Params> {
  Future<Result<Type, Failure>> call(Params params);
}

/// Use case for operations that don't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Result<Type, Failure>> call();
}

/// Use case that returns a stream
abstract class StreamUseCase<Type, Params> {
  Stream<Result<Type, Failure>> call(Params params);
}

/// Base class for parameters that don't require any data
class NoParams {
  const NoParams();
}

/// Base class for use cases with pagination
abstract class PaginatedUseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Base parameters for paginated requests
class PaginationParams {
  final int page;
  final int limit;
  final String? sortBy;
  final bool descending;
  
  const PaginationParams({
    this.page = 1,
    this.limit = 10,
    this.sortBy,
    this.descending = false,
  });
  
  PaginationParams copyWith({
    int? page,
    int? limit,
    String? sortBy,
    bool? descending,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationParams &&
      runtimeType == other.runtimeType &&
      page == other.page &&
      limit == other.limit &&
      sortBy == other.sortBy &&
      descending == other.descending;
  
  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      sortBy.hashCode ^
      descending.hashCode;
}

/// Base class for search parameters
class SearchParams extends PaginationParams {
  final String query;
  final Map<String, dynamic>? filters;
  
  const SearchParams({
    required this.query,
    this.filters,
    super.page,
    super.limit,
    super.sortBy,
    super.descending,
  });
  
  @override
  SearchParams copyWith({
    String? query,
    Map<String, dynamic>? filters,
    int? page,
    int? limit,
    String? sortBy,
    bool? descending,
  }) {
    return SearchParams(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
      other is SearchParams &&
      runtimeType == other.runtimeType &&
      query == other.query &&
      filters == other.filters;
  
  @override
  int get hashCode => super.hashCode ^ query.hashCode ^ filters.hashCode;
}
