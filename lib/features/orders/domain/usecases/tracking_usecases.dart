import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/base_classes.dart';
import '../entities/tracking_entity.dart';
import '../repositories/order_repository.dart';

// Track order use case
class TrackOrderUseCase implements UseCase<OrderTrackingEntity, String> {
  final OrderRepository repository;

  const TrackOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderTrackingEntity>> call(String orderNumber) async {
    return await repository.trackOrder(orderNumber);
  }
}
