import '../../core/result.dart';
import '../../core/failure.dart';
import '../entities/user.dart';
import '../entities/product.dart';
import '../entities/order.dart';
import '../entities/cart.dart';
import '../entities/wishlist.dart';
import '../entities/category.dart';
import '../entities/offer.dart';
import '../entities/notification.dart';

/// Repository interface for User domain
abstract class UserRepository {
  Future<Result<User?, Failure>> getCurrentUser();
  Future<Result<User, Failure>> getUserById(String userId);
  Future<Result<User, Failure>> updateUser(User user);
  Future<Result<void, Failure>> deleteUser(String userId);
  Future<Result<List<User>, Failure>> getUsers({
    int? limit,
    String? startAfter,
    String? searchQuery,
  });
  Future<Result<User, Failure>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  });
}

/// Repository interface for Authentication domain
abstract class AuthRepository {
  Future<Result<User, Failure>> signInWithEmailAndPassword(String email, String password);
  Future<Result<User, Failure>> signUpWithEmailAndPassword(String email, String password, String firstName, String lastName);
  Future<Result<User, Failure>> signInWithGoogle();
  Future<Result<void, Failure>> signOut();
  Future<Result<void, Failure>> resetPassword(String email);
  Future<Result<User?, Failure>> getCurrentUser();
  Stream<Result<User?, Failure>> get authStateChanges;
}

/// Repository interface for Product domain
abstract class ProductRepository {
  Future<Result<Product, Failure>> getProductById(String productId);
  Future<Result<List<Product>, Failure>> getProducts({
    int? limit,
    String? startAfter,
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? descending,
  });
  Future<Result<List<Product>, Failure>> getFeaturedProducts({int? limit});
  Future<Result<List<Product>, Failure>> getNewArrivals({int? limit});
  Future<Result<List<Product>, Failure>> getRelatedProducts(String productId, {int? limit});
  Future<Result<Product, Failure>> createProduct(Product product);
  Future<Result<Product, Failure>> updateProduct(Product product);
  Future<Result<void, Failure>> deleteProduct(String productId);
}

/// Repository interface for Category domain
abstract class CategoryRepository {
  Future<Result<Category, Failure>> getCategoryById(String categoryId);
  Future<Result<List<Category>, Failure>> getCategories();
  Future<Result<List<Category>, Failure>> getParentCategories();
  Future<Result<List<Category>, Failure>> getSubcategories(String parentCategoryId);
  Future<Result<int, Failure>> getProductCount(String categoryId);
  Future<Result<Category, Failure>> createCategory(Category category);
  Future<Result<Category, Failure>> updateCategory(Category category);
  Future<Result<void, Failure>> deleteCategory(String categoryId);
}

/// Repository interface for Order domain
abstract class OrderRepository {
  Future<Result<Order, Failure>> getOrderById(String orderId);
  Future<Result<List<Order>, Failure>> getUserOrders(String userId, {int? limit});
  Future<Result<List<Order>, Failure>> getAllOrders({
    int? page,
    int? limit,
    OrderStatus? status,
    String? search,
  });
  Future<Result<Order, Failure>> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
  });
  Future<Result<Order, Failure>> updateOrder(Order order);
  Future<Result<Order, Failure>> updateOrderStatus(String orderId, OrderStatus status);
  Future<Result<Order, Failure>> cancelOrder(String orderId);
  Stream<Result<List<Order>, Failure>> watchUserOrders(String userId);
  Stream<Order> watchOrder(String orderId);
}

/// Repository interface for Cart domain
abstract class CartRepository {
  Future<Result<Cart, Failure>> getCart(String userId);
  Future<Result<Cart, Failure>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    Map<String, dynamic>? selectedVariants,
  });
  Future<Result<Cart, Failure>> updateCartItem({
    required String userId,
    required String productId,
    required int quantity,
  });
  Future<Result<Cart, Failure>> removeFromCart({
    required String userId,
    required String productId,
  });
  Future<Result<void, Failure>> clearCart(String userId);
  Stream<Result<Cart, Failure>> watchCart(String userId);
}

/// Repository interface for Wishlist domain
abstract class WishlistRepository {
  Future<Result<Wishlist, Failure>> getWishlist(String userId);
  Future<Result<Wishlist, Failure>> addToWishlist(String userId, String productId);
  Future<Result<Wishlist, Failure>> removeFromWishlist(String userId, String productId);
  Future<Result<Wishlist, Failure>> clearWishlist(String userId);
  Future<Result<Wishlist, Failure>> toggleWishlist(String userId, String productId);
  Future<Result<bool, Failure>> isInWishlist(String userId, String productId);
  Stream<Result<Wishlist, Failure>> watchWishlist(String userId);
}

/// Repository interface for Notification domain
abstract class NotificationRepository {
  Future<Result<List<AppNotification>, Failure>> getNotifications(String userId, {int? limit});
  Future<Result<void, Failure>> markAsRead(String notificationId);
  Future<Result<void, Failure>> markAllAsRead(String userId);
  Future<Result<void, Failure>> deleteNotification(String notificationId);
  Future<Result<int, Failure>> getUnreadCount(String userId);
  Future<Result<AppNotification, Failure>> createNotification(AppNotification notification);
  Stream<Result<List<AppNotification>, Failure>> watchNotifications(String userId);
}

/// Repository interface for Offer domain
abstract class OfferRepository {
  Future<Result<List<Offer>, Failure>> getActiveOffers();
  Future<Result<Offer, Failure>> getOfferById(String offerId);
  Future<Result<List<Offer>, Failure>> getOffersByCategory(String categoryId);
  Future<Result<List<Offer>, Failure>> getOffersByProduct(String productId);
  Future<Result<bool, Failure>> validateOffer(String offerId, String productId);  Future<Result<Offer, Failure>> createOffer(Offer offer);
  Future<Result<Offer, Failure>> updateOffer(Offer offer);
  Future<Result<void, Failure>> deleteOffer(String offerId);
}
