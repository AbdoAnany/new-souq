// API Constants
class ApiConstants {
  static const String baseUrl = 'https://api.souq.com/v1/';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Auth endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refreshToken = 'auth/refresh';
  static const String logout = 'auth/logout';
  
  // Product endpoints
  static const String products = 'products';
  static const String categories = 'categories';
  static const String productSearch = 'products/search';
  
  // Order endpoints
  static const String orders = 'orders';
  static const String orderHistory = 'orders/history';
  
  // Cart endpoints
  static const String cart = 'cart';
  static const String addToCart = 'cart/add';
  static const String removeFromCart = 'cart/remove';
  
  // Wishlist endpoints
  static const String wishlist = 'wishlist';
  static const String addToWishlist = 'wishlist/add';
  static const String removeFromWishlist = 'wishlist/remove';
  
  // Admin endpoints
  static const String adminProducts = 'admin/products';
  static const String adminOrders = 'admin/orders';
  static const String adminUsers = 'admin/users';
  static const String adminAnalytics = 'admin/analytics';
}
