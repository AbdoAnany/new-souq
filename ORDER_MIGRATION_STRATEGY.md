# Order Module Migration Strategy

## Overview

This document outlines the strategy for migrating from legacy Riverpod-based order screens to the new clean architecture implementation using BLoC pattern.

## Migration Phases

### Phase 1: Foundation ✅ COMPLETED

- [x] Created clean architecture structure for orders feature
- [x] Implemented enhanced use cases with validation logic
- [x] Added new BLoC events and states for order management
- [x] Updated dependency injection container
- [x] Created new clean architecture screens

### Phase 2: Route Integration ✅ COMPLETED

- [x] Added new routes for clean architecture screens
- [x] Created route wrappers with proper BLoC providers
- [x] Maintained backward compatibility with legacy routes

### Phase 3: Enhanced Business Logic ✅ COMPLETED

- [x] Implemented admin permission validation
- [x] Added order update validation use cases
- [x] Created order stream management
- [x] Enhanced error handling with specific failure types

### Phase 4: Widget Enhancement ✅ COMPLETED

- [x] Created enhanced order widgets (status management, item editor)
- [x] Improved responsive design utilities
- [x] Added proper loading and error states

## Current Implementation Status

### ✅ Completed Components

#### Core Architecture

- Clean architecture structure in `features/orders/`
- Enhanced use cases in `order_management_usecases.dart`
- Updated BLoC with new events and states
- Dependency injection integration

#### New Screens

- `OrderUpdateScreen` - Clean architecture order management
- `OrderDetailsScreenClean` - Enhanced order details with BLoC
- Route wrappers for proper provider injection

#### Enhanced Widgets

- `OrderStatusManagementWidget` - Admin controls
- `OrderItemsEditorWidget` - Quantity editing
- `OrderItemCardEnhanced` - Action-enabled item cards
- Enhanced `OrderStatusBadge` with icons

#### Business Logic

- `UpdateOrderWithAdminPermissionsUseCase`
- `UpdateOrderWithValidationUseCase`
- `GetOrderStreamUseCase`
- `ValidateOrderUpdateUseCase`
- Custom `ValidationFailure` handling

### 🔄 Next Phase: Performance & Testing

#### Performance Optimizations

1. **Caching Implementation**

   ```dart
   // Order cache service
   class OrderCacheService {
     final Map<String, OrderEntity> _orderCache = {};
     final Duration _cacheTimeout = Duration(minutes: 5);

     OrderEntity? getCachedOrder(String orderId) {
       // Implementation with timestamp validation
     }
   }
   ```

2. **Pagination Enhancement**

   ```dart
   // Paginated order loading
   class PaginatedOrdersUseCase {
     Future<Either<Failure, PaginatedResult<OrderEntity>>> call({
       required int page,
       required int limit,
       String? status,
     });
   }
   ```

3. **State Management Optimization**
   ```dart
   // Optimized BLoC state management
   class OptimizedOrderState {
     final Map<String, OrderEntity> orders;
     final PaginationMeta pagination;
     final Set<String> loadingOrderIds;
   }
   ```

#### Testing Strategy

1. **Unit Tests**

   - Use case testing
   - BLoC event/state testing
   - Widget testing

2. **Integration Tests**
   - Screen navigation testing
   - Route wrapper testing
   - End-to-end order flows

## Migration Strategy

### Gradual Migration Approach

#### Step 1: Parallel Implementation ✅ COMPLETED

- New clean architecture screens exist alongside legacy screens
- Route configuration supports both implementations
- No breaking changes to existing functionality

#### Step 2: Feature Flag Implementation (Recommended)

```dart
class FeatureFlags {
  static const bool useCleanArchitectureOrders = true;

  static Widget getOrderDetailsScreen({
    required String orderId,
    required String userId,
  }) {
    return useCleanArchitectureOrders
        ? OrderDetailsScreenClean(orderId: orderId, userId: userId)
        : OrderDetailsScreen(orderId: orderId);
  }
}
```

#### Step 3: Progressive Rollout

1. **Internal Testing** - Use clean architecture screens for admin users
2. **Beta Testing** - Gradually enable for subset of users
3. **Full Migration** - Complete switch with legacy fallback
4. **Cleanup** - Remove legacy screens and Riverpod dependencies

### Data Migration Considerations

#### State Migration

```dart
// Convert Riverpod state to BLoC state
class StateMigrationService {
  static OrderState migrateFromRiverpod(AsyncValue<List<Order>> riverpodState) {
    return riverpodState.when(
      data: (orders) => OrdersLoaded(orders.map((o) => o.toEntity()).toList()),
      loading: () => OrdersLoading(),
      error: (error, _) => OrdersError(error.toString()),
    );
  }
}
```

#### Cache Migration

```dart
// Migrate cached data between implementations
class CacheMigrationService {
  static Future<void> migrateCachedOrders() async {
    final legacyCache = await SharedPreferences.getInstance();
    final cachedOrders = legacyCache.getStringList('cached_orders') ?? [];

    // Convert to new cache format
    final orderCacheService = sl<OrderCacheService>();
    for (final orderJson in cachedOrders) {
      final order = OrderEntity.fromJson(json.decode(orderJson));
      await orderCacheService.cacheOrder(order);
    }
  }
}
```

## Performance Targets

### Loading Performance

- **Order List**: < 500ms initial load
- **Order Details**: < 300ms with cache, < 1s without cache
- **Order Updates**: < 200ms optimistic updates

### Memory Usage

- **Order Cache**: Max 50 orders in memory
- **Image Cache**: Efficient product image caching
- **State Management**: Minimal state duplication

### Network Optimization

- **Request Batching**: Combine multiple order requests
- **Incremental Loading**: Load order details on demand
- **Offline Support**: Cache critical order data

## Testing Strategy

### Test Coverage Goals

- **Use Cases**: 100% coverage
- **BLoC Logic**: 95% coverage
- **Widgets**: 90% coverage
- **Integration**: Key user flows

### Test Implementation

```dart
// Example use case test
group('UpdateOrderWithValidationUseCase', () {
  test('should validate order update permissions', () async {
    // Arrange
    final order = OrderEntity.fixture();
    final params = UpdateOrderParams(orderId: order.id, status: OrderStatus.shipped);

    // Act
    final result = await useCase(params);

    // Assert
    expect(result.isRight(), true);
  });
});
```

## Monitoring & Analytics

### Performance Monitoring

```dart
class OrderPerformanceTracker {
  static void trackOrderListLoad(Duration loadTime) {
    analytics.track('order_list_load_time', {
      'duration_ms': loadTime.inMilliseconds,
      'architecture': 'clean_bloc',
    });
  }
}
```

### Error Tracking

```dart
class OrderErrorTracker {
  static void trackOrderError(String operation, dynamic error) {
    crashlytics.recordError(error, StackTrace.current, context: {
      'operation': operation,
      'architecture': 'clean_bloc',
    });
  }
}
```

## Success Metrics

### User Experience

- Reduced loading times
- Improved error handling
- Better offline support
- Smoother navigation

### Developer Experience

- Cleaner code organization
- Better testability
- Easier feature additions
- Reduced coupling

### Technical Metrics

- Reduced memory usage
- Improved cache hit rates
- Lower network requests
- Better error recovery

## Rollback Plan

### Immediate Rollback

```dart
// Feature flag for instant rollback
class EmergencyRollback {
  static const bool forceUseLegacyOrders = false;

  static Widget getOrderScreen() {
    return forceUseLegacyOrders || !FeatureFlags.useCleanArchitectureOrders
        ? LegacyOrderScreen()
        : CleanOrderScreen();
  }
}
```

### Gradual Rollback

1. Disable new features for new users
2. Migrate active sessions back to legacy
3. Restore legacy routes as primary
4. Investigate and fix issues

## Conclusion

The order module migration to clean architecture is approximately **85% complete**. The foundation is solid with enhanced business logic, improved error handling, and better separation of concerns. The next phase focuses on performance optimizations and comprehensive testing before full production rollout.

Key achievements:

- ✅ Clean architecture implementation
- ✅ Enhanced business logic with validation
- ✅ Improved error handling
- ✅ Better state management with BLoC
- ✅ Responsive UI components
- ✅ Route integration with backward compatibility

Remaining tasks:

- 🔄 Performance optimizations (caching, pagination)
- 🔄 Comprehensive testing suite
- 🔄 Production monitoring setup
- 🔄 Final migration and cleanup
