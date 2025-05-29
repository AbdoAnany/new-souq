import '../../core/result.dart';
import '../../core/failure.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/repositories.dart';
import '../entities/cart.dart';

/// Parameters for getting cart
class GetCartParams {
  final String userId;

  const GetCartParams({required this.userId});
}

/// Use case for getting user's cart
class GetCartUseCase implements UseCase<Cart, GetCartParams> {
  final CartRepository _repository;

  GetCartUseCase(this._repository);

  @override
  Future<Result<Cart, Failure>> call(GetCartParams params) async {
    return await _repository.getCart(params.userId);
  }
}

/// Parameters for adding item to cart
class AddToCartParams {
  final String userId;
  final String productId;
  final int quantity;
  final Map<String, dynamic>? selectedVariants;

  const AddToCartParams({
    required this.userId,
    required this.productId,
    required this.quantity,
    this.selectedVariants,
  });
}

/// Use case for adding item to cart
class AddToCartUseCase implements UseCase<Cart, AddToCartParams> {
  final CartRepository _repository;

  AddToCartUseCase(this._repository);

  @override
  Future<Result<Cart, Failure>> call(AddToCartParams params) async {
    if (params.quantity <= 0) {
      return Result.failure(const ValidationFailure('Quantity must be greater than 0'));
    }

    return await _repository.addToCart(
      userId: params.userId,
      productId: params.productId,
      quantity: params.quantity,
      selectedVariants: params.selectedVariants,
    );
  }
}

/// Parameters for updating cart item
class UpdateCartItemParams {
  final String userId;
  final String productId;
  final int quantity;

  const UpdateCartItemParams({
    required this.userId,
    required this.productId,
    required this.quantity,
  });
}

/// Use case for updating cart item quantity
class UpdateCartItemUseCase implements UseCase<Cart, UpdateCartItemParams> {
  final CartRepository _repository;

  UpdateCartItemUseCase(this._repository);

  @override
  Future<Result<Cart, Failure>> call(UpdateCartItemParams params) async {
    if (params.quantity < 0) {
      return Result.failure(const ValidationFailure('Quantity cannot be negative'));
    }

    return await _repository.updateCartItem(
      userId: params.userId,
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}

/// Parameters for removing item from cart
class RemoveFromCartParams {
  final String userId;
  final String productId;

  const RemoveFromCartParams({
    required this.userId,
    required this.productId,
  });
}

/// Use case for removing item from cart
class RemoveFromCartUseCase implements UseCase<Cart, RemoveFromCartParams> {
  final CartRepository _repository;

  RemoveFromCartUseCase(this._repository);

  @override
  Future<Result<Cart, Failure>> call(RemoveFromCartParams params) async {
    return await _repository.removeFromCart(
      userId: params.userId,
      productId: params.productId,
    );
  }
}

/// Parameters for clearing cart
class ClearCartParams {
  final String userId;

  const ClearCartParams({required this.userId});
}

/// Use case for clearing cart
class ClearCartUseCase implements UseCase<void, ClearCartParams> {
  final CartRepository _repository;

  ClearCartUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(ClearCartParams params) async {
    return await _repository.clearCart(params.userId);
  }
}

/// Parameters for watching cart
class WatchCartParams {
  final String userId;

  const WatchCartParams({required this.userId});
}

/// Use case for watching cart changes
class WatchCartUseCase implements StreamUseCase<Cart, WatchCartParams> {
  final CartRepository _repository;

  WatchCartUseCase(this._repository);

  @override
  Stream<Result<Cart, Failure>> call(WatchCartParams params) {
    return _repository.watchCart(params.userId);
  }
}
