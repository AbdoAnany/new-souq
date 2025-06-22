# Order Feature Migration Guide

## 📋 Overview

This guide helps you migrate from the existing order service and providers to the new clean architecture implementation for the orders feature.

## 🏗️ Architecture Comparison

### Before (Legacy)

```
lib/
├── services/
│   ├── order_service.dart
│   └── tracking_service.dart
├── providers/
│   ├── order_provider.dart
│   └── admin_order_provider.dart
├── models/
│   └── order.dart
└── screens/
    ├── order_history_screen.dart
    ├── order_details_screen.dart
    └── order_confirmation_screen.dart
```

### After (Clean Architecture)

```
lib/features/orders/
├── domain/
│   ├── entities/
│   │   ├── order_entity.dart
│   │   └── tracking_entity.dart
│   ├── repositories/
│   │   └── order_repository.dart
│   └── usecases/
│       ├── order_usecases.dart
│       └── tracking_usecases.dart
├── data/
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── order_item_model.dart
│   │   ├── shipping_address_model.dart
│   │   └── tracking_model.dart
│   ├── datasources/
│   │   ├── order_remote_data_source.dart
│   │   └── order_local_data_source.dart
│   └── repositories/
│       └── order_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── order_bloc.dart
    │   ├── order_event.dart
    │   ├── order_state.dart
    │   └── tracking_bloc.dart
    ├── screens/
    │   ├── order_list_screen.dart
    │   └── order_details_screen.dart
    └── widgets/
        ├── order_list_item.dart
        ├── order_status_badge.dart
        ├── order_item_card.dart
        ├── order_timeline.dart
        ├── order_search_bar.dart
        └── order_status_filter.dart
```

## 🔄 Migration Steps

### Step 1: Update Dependencies

Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  dartz: ^0.10.1
  equatable: ^2.0.5
  get_it: ^7.6.4
  internet_connection_checker: ^1.0.0+1
```

### Step 2: Replace Provider Usage with BLoC

#### Old Provider Usage:

```dart
// Old way using Riverpod
final ordersAsyncValue = ref.watch(ordersProvider);

ordersAsyncValue.when(
  data: (orders) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

#### New BLoC Usage:

```dart
// New way using BLoC
BlocBuilder<OrderBloc, OrderState>(
  builder: (context, state) {
    if (state is OrdersLoaded) {
      return ListView.builder(...);
    } else if (state is OrderLoading) {
      return CircularProgressIndicator();
    } else if (state is OrderError) {
      return Text('Error: ${state.message}');
    }
    return SizedBox.shrink();
  },
);
```

### Step 3: Update Screen Implementations

#### Replace Order History Screen:

```dart
// Old screen usage
class OrderHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(ordersProvider);
    // ... existing implementation
  }
}

// New screen usage
class OrderListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()
        ..add(GetUserOrdersEvent(userId: userId)),
      child: Scaffold(
        // ... new implementation
      ),
    );
  }
}
```

### Step 4: Update Order Operations

#### Placing Orders:

```dart
// Old way
final order = await ref.read(ordersProvider.notifier).placeOrder(
  userId: userId,
  cart: cart,
  shippingAddress: address,
  paymentMethod: paymentMethod,
);

// New way
context.read<OrderBloc>().add(PlaceOrderEvent(
  userId: userId,
  items: items,
  shippingAddress: address,
  paymentMethod: paymentMethod,
));
```

#### Canceling Orders:

```dart
// Old way
await ref.read(ordersProvider.notifier).cancelOrder(orderId);

// New way
context.read<OrderBloc>().add(CancelOrderEvent(orderId));
```

### Step 5: Update Navigation

#### Order Details Navigation:

```dart
// Old way
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrderDetailsScreen(orderId: orderId),
  ),
);

// New way - same, but using new screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrderDetailsScreen(orderId: orderId),
  ),
);
```

## 🔧 Key Differences

### 1. State Management

- **Before**: Riverpod with AsyncValue
- **After**: BLoC with explicit states

### 2. Error Handling

- **Before**: Exception throwing with try-catch
- **After**: Either<Failure, Success> pattern

### 3. Data Flow

- **Before**: Service → Provider → UI
- **After**: UseCase → Repository → DataSource → UI (via BLoC)

### 4. Caching

- **Before**: Manual caching in services
- **After**: Automatic caching in repository layer

## 📝 Code Examples

### Complete Order List Implementation:

```dart
class OrderListScreen extends StatelessWidget {
  final String userId;

  const OrderListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()
        ..add(GetUserOrdersEvent(userId: userId)),
      child: Scaffold(
        appBar: AppBar(title: Text('My Orders')),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is OrdersLoaded) {
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  return OrderListItem(
                    order: state.orders[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(
                          orderId: state.orders[index].id,
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is OrderError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

### Complete Order Details Implementation:

```dart
class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()
        ..add(GetOrderByIdEvent(orderId)),
      child: Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is OrderLoaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    OrderStatusBadge(status: state.order.status),
                    OrderTimeline(order: state.order),
                    ...state.order.items.map(
                      (item) => OrderItemCard(item: item),
                    ),
                  ],
                ),
              );
            } else if (state is OrderError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

## 🚀 Benefits of Migration

1. **Better Separation of Concerns**: Each layer has a clear responsibility
2. **Improved Testability**: Easy to unit test business logic
3. **Error Handling**: Consistent error handling with Either pattern
4. **Caching**: Automatic offline support
5. **Scalability**: Easy to add new features and modify existing ones
6. **Type Safety**: Better type safety with entities and models

## 📋 Checklist

- [ ] Update dependencies in pubspec.yaml
- [ ] Replace Riverpod providers with BLoC providers
- [ ] Update screen implementations
- [ ] Update navigation calls
- [ ] Test order placement flow
- [ ] Test order cancellation flow
- [ ] Test offline functionality
- [ ] Update admin order management (if applicable)

## 🔄 Gradual Migration

You can migrate gradually by:

1. Start with new order screens using the new architecture
2. Keep old screens working while implementing new ones
3. Gradually replace old screens with new implementations
4. Remove old code once everything is working

This approach ensures your app continues working during the migration process.
