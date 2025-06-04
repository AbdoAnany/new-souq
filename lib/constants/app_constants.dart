import 'package:flutter/material.dart';
class AppConstants {
  // App Info
  static const String appName = 'Souq';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF1565C0);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimaryColor = Colors.white;
  static const Color darkTextSecondaryColor = Color(0xFFBDBDBD);
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // API
  static const String baseUrl = 'https://api.souq.com/v1/';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String cartsCollection = 'carts';
  static const String wishlistsCollection = 'wishlists';
  static const String reviewsCollection = 'reviews';
  static const String offersCollection = 'offers';
  
  // SharedPreferences Keys
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String fcmTokenKey = 'fcm_token';
  
  // Product Categories
  static const List<String> productCategories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Beauty',
    'Automotive',
    'Food',
  ];
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  
  // Payment Methods
  static const String cashOnDelivery = 'cash_on_delivery';
  static const String creditCard = 'credit_card';
  static const String paypal = 'paypal';
  static const String stripe = 'stripe';
  
  // Languages
  static const String arabicLanguageCode = 'ar';
  static const String englishLanguageCode = 'en';
  
  // Image Placeholders
  static const String productPlaceholder = 'assets/images/product_placeholder.png';
  static const String userPlaceholder = 'assets/images/user_placeholder.png';
  static const String logoPath = 'assets/images/logo.png';
  
  // Max Values
  static const int maxCartQuantity = 10;
  static const int maxWishlistItems = 100;
  static const double maxProductRating = 5.0;
  
  // Pagination
  static const int productsPerPage = 20;
  static const int ordersPerPage = 10;
  static const int reviewsPerPage = 10;
  static const int pageSize = 20;

  static var noImageUri=Uri.parse("https://souq.com.sa/images/no-image.jpg");
}

class AppStrings {
  // General
  static const String appName = 'Souq';
  static const String welcome = 'Welcome';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String tryAgain = 'Try Again';
  static const String noData = 'No data available';
  static const String noInternet = 'No internet connection';
  
  // Authentication
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String signInWithGoogle = 'Sign in with Google';
  static const String phoneNumber = 'Phone Number';
  static const String verificationCode = 'Verification Code';
  
  // Navigation
  static const String home = 'Home';
  static const String categories = 'Categories';
  static const String cart = 'Cart';
  static const String profile = 'Profile';
  static const String orders = 'Orders';
  static const String wishlist = 'Wishlist';
  static const String settings = 'Settings';
  static const String offers = 'Offers';
  
  // Product
  static const String products = 'Products';
  static const String productDetails = 'Product Details';
  static const String addToCart = 'Add to Cart';
  static const String buyNow = 'Buy Now';
  static const String price = 'Price';
  static const String description = 'Description';
  static const String reviews = 'Reviews';
  static const String rating = 'Rating';
  static const String inStock = 'In Stock';
  static const String outOfStock = 'Out of Stock';
  static const String quantity = 'Quantity';
  
  // Cart & Checkout
  static const String shoppingCart = 'Shopping Cart';
  static const String checkout = 'Checkout';
  static const String total = 'Total';
  static const String subtotal = 'Subtotal';
  static const String shipping = 'Shipping';
  static const String tax = 'Tax';
  static const String placeOrder = 'Place Order';
  static const String orderSummary = 'Order Summary';
  static const String paymentMethod = 'Payment Method';
  static const String shippingAddress = 'Shipping Address';
  static const String billingAddress = 'Billing Address';
  
  // Order
  static const String orderHistory = 'Order History';
  static const String orderDetails = 'Order Details';
  static const String orderNumber = 'Order Number';
  static const String orderDate = 'Order Date';
  static const String orderStatus = 'Order Status';
  static const String trackOrder = 'Track Order';
  static const String cancelOrder = 'Cancel Order';
  
  // Profile
  static const String myProfile = 'My Profile';
  static const String personalInfo = 'Personal Information';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String address = 'Address';
  static const String city = 'City';
  static const String country = 'Country';
  static const String postalCode = 'Postal Code';
  
  // Settings
  static const String appSettings = 'App Settings';
  static const String language = 'Language';
  static const String theme = 'Theme';
  static const String notifications = 'Notifications';
  static const String privacy = 'Privacy';
  static const String terms = 'Terms & Conditions';
  static const String aboutUs = 'About Us';
  static const String contactUs = 'Contact Us';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  
  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidPhoneNumber = 'Please enter a valid phone number';
  
  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String orderPlacedSuccess = 'Order placed successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String passwordResetSent = 'Password reset email sent';
  
  // Error Messages
  static const String loginFailed = 'Login failed';
  static const String registrationFailed = 'Registration failed';
  static const String orderFailed = 'Failed to place order';
  static const String networkError = 'Network error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String sessionExpired = 'Session expired. Please login again';
}
