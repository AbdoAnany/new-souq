import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/base_classes.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

// Update order with admin permissions use case
class UpdateOrderWithAdminPermissionsUseCase
    implements UseCase<OrderEntity, UpdateOrderWithAdminPermissionsParams> {
  final OrderRepository repository;

  const UpdateOrderWithAdminPermissionsUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(
      UpdateOrderWithAdminPermissionsParams params) async {
    return await repository.updateOrderStatus(
      orderId: params.orderId,
      status: params.newStatus,
      trackingNumber: params.trackingNumber,
      notes: params.adminNotes,
    );
  }
}

class UpdateOrderWithAdminPermissionsParams extends Equatable {
  final String orderId;
  final OrderStatus newStatus;
  final String? adminNotes;
  final Map<String, int>? quantityUpdates;
  final String userRole;
  final String? trackingNumber;

  const UpdateOrderWithAdminPermissionsParams({
    required this.orderId,
    required this.newStatus,
    this.adminNotes,
    this.quantityUpdates,
    required this.userRole,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [
        orderId,
        newStatus,
        adminNotes,
        quantityUpdates,
        userRole,
        trackingNumber,
      ];
}

// Update order with validation use case
class UpdateOrderWithValidationUseCase
    implements UseCase<OrderEntity, UpdateOrderWithValidationParams> {
  final OrderRepository repository;

  const UpdateOrderWithValidationUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(
      UpdateOrderWithValidationParams params) async {
    return await repository.updateOrderStatus(
      orderId: params.orderId,
      status: params.newStatus,
      notes: params.customerNotes,
    );
  }
}

class UpdateOrderWithValidationParams extends Equatable {
  final String orderId;
  final OrderStatus newStatus;
  final String? customerNotes;
  final Map<String, int>? quantityUpdates;

  const UpdateOrderWithValidationParams({
    required this.orderId,
    required this.newStatus,
    this.customerNotes,
    this.quantityUpdates,
  });

  @override
  List<Object?> get props => [
        orderId,
        newStatus,
        customerNotes,
        quantityUpdates,
      ];
}

// Get order stream use case for real-time updates
class GetOrderStreamUseCase implements UseCase<Stream<OrderEntity>, String> {
  final OrderRepository repository;

  const GetOrderStreamUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<OrderEntity>>> call(String orderId) async {
    try {
      final stream = repository.getOrderStream(orderId);
      return Right(stream.map((either) => either.fold(
            (failure) => throw Exception(failure.toString()),
            (order) => order,
          )));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// Validate order update use case
class ValidateOrderUpdateUseCase
    implements UseCase<bool, ValidateOrderUpdateParams> {
  final OrderRepository repository;

  const ValidateOrderUpdateUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ValidateOrderUpdateParams params) async {
    try {
      // Get current order
      final orderResult = await repository.getOrderById(params.orderId);

      return orderResult.fold(
        (failure) => Left(failure),
        (order) {
          // Validate status transition
          if (!_isValidStatusTransition(order.status, params.newStatus)) {
            return const Left(ValidationFailure(
              message: 'Invalid status transition',
            ));
          }

          // Validate tracking number for shipped status
          if (params.newStatus == OrderStatus.shipped &&
              (params.trackingNumber?.isEmpty ?? true)) {
            return const Left(ValidationFailure(
              message:
                  'Tracking number is required when marking order as shipped',
            ));
          }

          // Validate quantity updates
          if (params.quantityUpdates != null) {
            final totalItems = params.quantityUpdates!.values
                .where((quantity) => quantity > 0)
                .length;

            if (totalItems == 0) {
              return const Left(ValidationFailure(
                message: 'At least one item must remain in the order',
              ));
            }
          }

          return const Right(true);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  bool _isValidStatusTransition(
      OrderStatus currentStatus, OrderStatus newStatus) {
    // Define valid status transitions
    const validTransitions = {
      OrderStatus.pending: [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.cancelled
      ],
      OrderStatus.confirmed: [
        OrderStatus.confirmed,
        OrderStatus.processing,
        OrderStatus.cancelled
      ],
      OrderStatus.processing: [
        OrderStatus.processing,
        OrderStatus.shipped,
        OrderStatus.cancelled
      ],
      OrderStatus.shipped: [
        OrderStatus.shipped,
        OrderStatus.delivered,
        OrderStatus.returned
      ],
      OrderStatus.delivered: [OrderStatus.delivered, OrderStatus.returned],
      OrderStatus.cancelled: [OrderStatus.cancelled],
      OrderStatus.returned: [OrderStatus.returned],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }
}

class ValidateOrderUpdateParams extends Equatable {
  final String orderId;
  final OrderStatus newStatus;
  final String? trackingNumber;
  final Map<String, int>? quantityUpdates;

  const ValidateOrderUpdateParams({
    required this.orderId,
    required this.newStatus,
    this.trackingNumber,
    this.quantityUpdates,
  });

  @override
  List<Object?> get props =>
      [orderId, newStatus, trackingNumber, quantityUpdates];
}

// Custom validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);

  @override
  List<Object> get props => [message];
}
