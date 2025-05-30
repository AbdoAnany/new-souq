import '../../core/result.dart';
import '../../core/failure.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/repositories.dart';
import '../entities/wishlist.dart';

/// Use case for getting user's wishlist
class GetWishlistUseCase implements UseCase<Wishlist, String> {
  final WishlistRepository _repository;

  GetWishlistUseCase(this._repository);

  @override
  Future<Result<Wishlist, Failure>> call(String userId) async {
    return await _repository.getWishlist(userId);
  }
}

/// Parameters for adding item to wishlist
class AddToWishlistParams {
  final String userId;
  final String productId;

  const AddToWishlistParams({
    required this.userId,
    required this.productId,
  });
}

/// Use case for adding item to wishlist
class AddToWishlistUseCase implements UseCase<void, AddToWishlistParams> {
  final WishlistRepository _repository;

  AddToWishlistUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(AddToWishlistParams params) async {
    return await _repository.addToWishlist(
      params.userId,
      params.productId,
    );
  }
}

/// Parameters for removing item from wishlist
class RemoveFromWishlistParams {
  final String userId;
  final String productId;

  const RemoveFromWishlistParams({
    required this.userId,
    required this.productId,
  });
}

/// Use case for removing item from wishlist
class RemoveFromWishlistUseCase implements UseCase<void, RemoveFromWishlistParams> {
  final WishlistRepository _repository;

  RemoveFromWishlistUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(RemoveFromWishlistParams params) async {
    return await _repository.removeFromWishlist(
      params.userId,
      params.productId,
    );
  }
}

/// Use case for clearing wishlist
class ClearWishlistUseCase implements UseCase<void, String> {
  final WishlistRepository _repository;

  ClearWishlistUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(String userId) async {
    return await _repository.clearWishlist(userId);
  }
}

/// Parameters for checking if product is in wishlist
class IsInWishlistParams {
  final String userId;
  final String productId;

  const IsInWishlistParams({
    required this.userId,
    required this.productId,
  });
}

/// Use case for checking if product is in wishlist
class IsInWishlistUseCase implements UseCase<bool, IsInWishlistParams> {
  final WishlistRepository _repository;

  IsInWishlistUseCase(this._repository);

  @override
  Future<Result<bool, Failure>> call(IsInWishlistParams params) async {
    return await _repository.isInWishlist(
      params.userId,
      params.productId,
    );
  }
}

/// Use case for toggling wishlist status
class ToggleWishlistUseCase {
  final WishlistRepository _repository;

  ToggleWishlistUseCase(this._repository);

  Future<Result<bool, Failure>> call(String userId, String productId) async {
    final isInWishlistResult = await _repository.isInWishlist(userId, productId);
    
    return isInWishlistResult.fold(
      (failure) => Result.failure(failure),
      (isInWishlist) async {
        if (isInWishlist) {
          final removeResult = await _repository.removeFromWishlist(userId, productId);
          return removeResult.fold(
            (failure) => Result.failure(failure),
            (_) => Result.success(false)
          );
        } else {
          final addResult = await _repository.addToWishlist(userId, productId);
          return addResult.fold(
            (failure) => Result.failure(failure),
            (_) => Result.success(true)
          );
        }
      },
    );
  }
}
