# Clean Architecture Implementation Guide

## Overview

This document outlines the clean architecture implementation in the Souq e-commerce Flutter app. The architecture follows Domain-Driven Design (DDD) principles with clear separation of concerns across layers.

## Architecture Layers

### 1. Domain Layer (`lib/domain/`)
The innermost layer containing business logic and entities.

#### Components:
- **Entities/Models**: Business objects (`lib/models/`)
- **Use Cases**: Business logic operations (`lib/domain/usecases/`)
- **Repository Interfaces**: Abstract contracts (`lib/domain/repositories/`)

#### Key Files:
- `repositories.dart` - Repository interfaces for all domains
- `product_usecases.dart` - Product domain use cases
- `auth_usecases.dart` - Authentication use cases
- `category_usecases.dart` - Category management use cases
- `offer_usecases.dart` - Offer/promotion use cases

### 2. Data Layer (`lib/data/`)
Handles data sources and implements repository interfaces.

#### Components:
- **Repository Implementations**: Concrete implementations of domain interfaces
- **Data Sources**: Firebase, local storage, APIs
- **Provider Aggregators**: Dependency injection setup

#### Key Files:
- `repositories/product_repository_impl.dart` - Product data operations
- `repositories/category_repository_impl.dart` - Category data operations
- `repositories/offer_repository_impl.dart` - Offer data operations
- `providers/repository_providers.dart` - Repository provider setup

### 3. Presentation Layer (`lib/presentation/`)
UI components and state management.

#### Components:
- **Providers**: State management with Riverpod
- **Screens**: UI components (legacy in `lib/screens/`)
- **Widgets**: Reusable UI components

#### Key Files:
- `providers/product_provider.dart` - Clean architecture product state management

### 4. Core Layer (`lib/core/`)
Shared utilities and configuration.

#### Components:
- **Configuration**: App-wide settings (`config/app_config.dart`)
- **Error Handling**: Result pattern and error types (`error/app_error.dart`)
- **Utilities**: Helper functions and responsive design (`utils/`)
- **Use Case Base**: Abstract use case patterns (`usecase/usecase.dart`)

## Key Patterns Implemented

### 1. Result Pattern
Type-safe error handling replacing try-catch blocks.

```dart
// Usage example
final result = await productRepository.getProductById(productId);
result.fold(
  onSuccess: (product) => updateUI(product),
  onFailure: (error) => showError(error),
);
```

### 2. Use Case Pattern
Encapsulates business logic operations.

```dart
class GetFeaturedProducts implements NoParamsUseCase<Result<List<Product>>> {
  final ProductRepository repository;
  
  GetFeaturedProducts(this.repository);
  
  @override
  Future<Result<List<Product>>> call() async {
    return await repository.getFeaturedProducts();
  }
}
```

### 3. Repository Pattern
Abstracts data access logic.

```dart
abstract class ProductRepository {
  Future<Result<List<Product>>> getFeaturedProducts();
  Future<Result<Product>> getProductById(String productId);
  // ... other methods
}
```

### 4. Dependency Injection with Riverpod
Clean provider organization with proper dependencies.

```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

final getFeaturedProductsProvider = Provider<GetFeaturedProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetFeaturedProducts(repository);
});
```

## Responsive Design Implementation

### Platform Detection
```dart
class ResponsiveHelper {
  static bool isWeb() => kIsWeb;
  static bool isMobile() => !kIsWeb && defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  static bool isDesktop() => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || ...);
}
```

### Adaptive UI Components
- Grid count based on screen size
- Pagination limits adjusted for platform
- Responsive breakpoints for mobile/tablet/desktop

## Error Handling Strategy

### 1. Structured Error Types
```dart
abstract class AppError {
  final String message;
  const AppError(this.message);
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

class AuthError extends AppError {
  const AuthError(super.message);
}
```

### 2. Result Pattern Implementation
```dart
sealed class Result<T> {
  const Result();
  
  factory Result.success(T data) = Success<T>;
  factory Result.failure(String error) = Failure<T>;
}
```

## Configuration Management

### App-wide Configuration
```dart
class AppConfig {
  static const bool enableLogging = true;
  static const int mobileProductPageSize = 10;
  static const int tabletProductPageSize = 15;
  static const int webProductPageSize = 20;
  
  // Platform detection
  static bool get isProduction => kReleaseMode;
  static bool get isWeb => kIsWeb;
}
```

## Migration Guide

### Transitioning from Legacy Providers

1. **Update Imports**:
   ```dart
   // Old
   import 'package:souq/providers/product_provider.dart';
   
   // New
   import 'package:souq/presentation/providers/product_provider.dart';
   ```

2. **Update Provider Usage**:
   ```dart
   // Old
   ref.read(productsProvider.notifier).fetchFeaturedProducts();
   
   // New
   ref.read(featuredProductsProvider.notifier).loadFeaturedProducts();
   ```

3. **Use Result Pattern**:
   ```dart
   // Old
   try {
     final products = await productService.getFeaturedProducts();
     // handle success
   } catch (e) {
     // handle error
   }
   
   // New
   final result = await getFeaturedProducts();
   result.fold(
     onSuccess: (products) => /* handle success */,
     onFailure: (error) => /* handle error */,
   );
   ```

## Performance Optimizations

### 1. Pagination
- Platform-aware page sizes
- Infinite scroll with loading states
- Memory efficient list handling

### 2. Caching Strategy
- Repository-level caching
- State persistence across navigation
- Image caching with cached_network_image

### 3. Platform-Specific Optimizations
- Web: Larger page sizes, keyboard navigation
- Mobile: Smaller pages, touch optimizations
- Tablet: Medium page sizes, adaptive layouts

## Testing Strategy

### 1. Unit Tests
- Use case testing with mock repositories
- Repository testing with mock data sources
- Utility function testing

### 2. Integration Tests
- End-to-end user flows
- State management testing
- API integration testing

### 3. Widget Tests
- UI component testing
- Provider integration testing
- Responsive design testing

## Benefits of Clean Architecture

1. **Separation of Concerns**: Clear boundaries between business logic and UI
2. **Testability**: Easy to unit test business logic in isolation
3. **Maintainability**: Changes to UI don't affect business logic
4. **Scalability**: Easy to add new features and modify existing ones
5. **Platform Independence**: Business logic works across platforms
6. **Error Handling**: Consistent error handling throughout the app
7. **Performance**: Optimized for different platforms and screen sizes

## Next Steps

1. Complete migration of all screens to clean architecture
2. Implement remaining repository implementations (Cart, Order, User, etc.)
3. Add comprehensive testing suite
4. Implement caching layer
5. Add offline support with local database
6. Optimize for web platform with PWA features
7. Add analytics and performance monitoring

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── error/
│   │   └── app_error.dart
│   ├── usecase/
│   │   └── usecase.dart
│   ├── utils/
│   │   ├── result.dart
│   │   └── responsive_helper.dart
│   └── migration/
│       └── provider_migration.dart
├── data/
│   ├── providers/
│   │   └── repository_providers.dart
│   └── repositories/
│       ├── product_repository_impl.dart
│       ├── category_repository_impl.dart
│       └── offer_repository_impl.dart
├── domain/
│   ├── repositories/
│   │   └── repositories.dart
│   └── usecases/
│       ├── product_usecases.dart
│       ├── auth_usecases.dart
│       ├── category_usecases.dart
│       └── offer_usecases.dart
├── presentation/
│   └── providers/
│       └── product_provider.dart
├── models/
├── screens/
├── widgets/
└── main.dart
```
