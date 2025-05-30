import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository_impl.dart';
import '../repositories/category_repository_impl.dart';
import '../repositories/offer_repository_impl.dart';
import '../repositories/cart_repository_impl.dart';
import '../repositories/user_repository_impl.dart';
import '../repositories/order_repository_impl.dart';
import '../repositories/wishlist_repository_impl.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/notification_repository_impl.dart';
import '../../domain/repositories/repositories.dart';

/// Data layer provider aggregator
/// This file provides all repository implementations for dependency injection

// Repository Providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl();
});

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepositoryImpl();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    productRepository: ref.read(productRepositoryProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(
    productRepository: ref.read(productRepositoryProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});
