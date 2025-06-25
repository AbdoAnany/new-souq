import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/usecases/tracking_usecases.dart';

// Tracking Events
abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object> get props => [];
}

class TrackOrderEvent extends TrackingEvent {
  final String orderNumber;

  const TrackOrderEvent(this.orderNumber);

  @override
  List<Object> get props => [orderNumber];
}

class ClearTrackingEvent extends TrackingEvent {}

// Tracking States
abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {}

class TrackingLoading extends TrackingState {}

class TrackingLoaded extends TrackingState {
  final OrderTrackingEntity tracking;

  const TrackingLoaded(this.tracking);

  @override
  List<Object> get props => [tracking];
}

class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object> get props => [message];
}

// Tracking BLoC
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackOrderUseCase trackOrderUseCase;

  TrackingBloc({
    required this.trackOrderUseCase,
  }) : super(TrackingInitial()) {
    on<TrackOrderEvent>(_onTrackOrder);
    on<ClearTrackingEvent>(_onClearTracking);
  }

  Future<void> _onTrackOrder(
    TrackOrderEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(TrackingLoading());

    final result = await trackOrderUseCase(event.orderNumber);

    result.fold(
      (failure) => emit(TrackingError(_mapFailureToMessage(failure))),
      (tracking) => emit(TrackingLoaded(tracking)),
    );
  }

  void _onClearTracking(
    ClearTrackingEvent event,
    Emitter<TrackingState> emit,
  ) {
    emit(TrackingInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case NetworkFailure:
        return 'Please check your internet connection';
      default:
        return 'Unexpected error occurred';
    }
  }
}
