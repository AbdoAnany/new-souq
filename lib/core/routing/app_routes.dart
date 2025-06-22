// App route names
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Product routes
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String productSearch = '/product-search';
  static const String categoryProducts = '/category-products';

  // Cart routes
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';

  // Order routes
  static const String orders = '/orders';
  static const String orderHistory = '/order-history';
  static const String orderDetails = '/order-details';
  static const String orderTracking = '/order-tracking';
  static const String orderUpdate = '/orders/update';
  static const String orderDetailsClean = '/orders/details-clean';

  // Wishlist routes
  static const String wishlist = '/wishlist';

  // Admin routes
  static const String adminDashboard = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminAddProduct = '/admin/add-product';
  static const String adminEditProduct = '/admin/edit-product';
}
