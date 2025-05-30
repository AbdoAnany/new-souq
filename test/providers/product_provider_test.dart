import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/core/result.dart';
import 'package:souq/core/failure.dart';
import 'package:souq/services/product_service.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/models/product.dart';
import 'package:mocktail/mocktail.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService mockProductService;
  late ProviderContainer container;

  setUp(() {
    mockProductService = MockProductService();
    container = ProviderContainer(overrides: [
      productServiceProvider.overrideWithValue(mockProductService),
    ]);
    addTearDown(container.dispose);
  });

  test('initial state is loading', () {
    final notifier = container.read(productsProvider.notifier);
    expect(container.read(productsProvider), const AsyncValue<List<Product>>.loading());
  });

  group('fetchFeaturedProducts', () {
    test('success case updates state with products', () async {
      final products = [
        Product(id: '1', name: 'Test Product 1', price: 100),
        Product(id: '2', name: 'Test Product 2', price: 200),
      ];

      when(() => mockProductService.getFeaturedProducts())
          .thenAnswer((_) async => Result.success(products));

      final notifier = container.read(productsProvider.notifier);
      await notifier.fetchFeaturedProducts();

      expect(
        container.read(productsProvider),
        AsyncValue.data(products),
      );
    });

    test('failure case updates state with error', () async {
      final failure = NetworkFailure('Network error');
      when(() => mockProductService.getFeaturedProducts())
          .thenAnswer((_) async => Result.failure(failure));

      final notifier = container.read(productsProvider.notifier);
      await notifier.fetchFeaturedProducts();

      expect(
        container.read(productsProvider),
        isA<AsyncError>(),
      );
    });
  });

  group('fetchProductsByCategory', () {
    test('success case updates state with products', () async {
      final products = [
        Product(id: '1', name: 'Category Product 1', price: 100),
        Product(id: '2', name: 'Category Product 2', price: 200),
      ];

      when(() => mockProductService.getProductsByCategory(categoryId: any(named: 'categoryId')))
          .thenAnswer((_) async => Result.success(products));

      final notifier = container.read(productsProvider.notifier);
      await notifier.fetchProductsByCategory('test-category');

      expect(
        container.read(productsProvider),
        AsyncValue.data(products),
      );
    });

    test('failure case updates state with error', () async {
      final failure = NetworkFailure('Network error');
      when(() => mockProductService.getProductsByCategory(categoryId: any(named: 'categoryId')))
          .thenAnswer((_) async => Result.failure(failure));

      final notifier = container.read(productsProvider.notifier);
      await notifier.fetchProductsByCategory('test-category');

      expect(
        container.read(productsProvider),
        isA<AsyncError>(),
      );
    });
  });
}
