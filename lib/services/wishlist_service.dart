import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/models/wishlist.dart';
import 'package:souq/services/product_service.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductService _productService = ProductService();

  String? get _userId => _auth.currentUser?.uid;

  // Get user's wishlist
  Future<Wishlist> getWishlist() async {
    if (_userId == null) {
      throw Exception("User not logged in");
    }

    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_userId)
          .get();

      if (!docSnapshot.exists) {
        // Create an empty wishlist if it doesn't exist
        final newWishlist = Wishlist(userId: _userId!, items: []);
        await _firestore
            .collection(AppConstants.wishlistsCollection)
            .doc(_userId)
            .set(newWishlist.toJson());
        return newWishlist;
      }

      return Wishlist.fromJson({...docSnapshot.data()!, 'userId': _userId});
    } catch (e) {
      throw Exception('Failed to fetch wishlist: ${e.toString()}');
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    if (_userId == null) {
      throw Exception("User not logged in");
    }

    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_userId);
      
      final docSnapshot = await wishlistRef.get();
      
      if (!docSnapshot.exists) {
        // Create a new wishlist with this item
        final newWishlist = Wishlist(
          userId: _userId!,
          items: [WishlistItem(productId: productId, addedAt: DateTime.now())],
        );
        await wishlistRef.set(newWishlist.toJson());
      } else {
        // Update existing wishlist
        final wishlist = Wishlist.fromJson({...docSnapshot.data()!, 'userId': _userId});
        
        // Check if product already in wishlist
        if (!wishlist.contains(productId)) {
          final items = [...wishlist.items, WishlistItem(productId: productId, addedAt: DateTime.now())];
          await wishlistRef.update({
            'items': items.map((item) => item.toJson()).toList(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to add to wishlist: ${e.toString()}');
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    if (_userId == null) {
      throw Exception("User not logged in");
    }

    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_userId);
      
      final docSnapshot = await wishlistRef.get();
      
      if (docSnapshot.exists) {
        final wishlist = Wishlist.fromJson({...docSnapshot.data()!, 'userId': _userId});
        final updatedItems = wishlist.items.where((item) => item.productId != productId).toList();
        
        await wishlistRef.update({
          'items': updatedItems.map((item) => item.toJson()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove from wishlist: ${e.toString()}');
    }
  }

  // Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    if (_userId == null) {
      return false;
    }

    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_userId)
          .get();
      
      if (!docSnapshot.exists) {
        return false;
      }
      
      final wishlist = Wishlist.fromJson({...docSnapshot.data()!, 'userId': _userId});
      return wishlist.contains(productId);
    } catch (e) {
      throw Exception('Failed to check wishlist: ${e.toString()}');
    }
  }

  // Clear wishlist
  Future<void> clearWishlist() async {
    if (_userId == null) {
      throw Exception("User not logged in");
    }

    try {
      await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_userId)
          .update({
            'items': [],
          });
    } catch (e) {
      throw Exception('Failed to clear wishlist: ${e.toString()}');
    }
  }

  // Get products in wishlist
  Future<List<Product>> getWishlistProducts() async {
    try {
      final wishlist = await getWishlist();
      
      if (wishlist.isEmpty) {
        return [];
      }
      
      final List<Product> products = [];
      
      for (final item in wishlist.items) {
        try {
          final product = await _productService.getProductById(item.productId);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          // Skip products that couldn't be loaded
        }
      }
      
      return products;
    } catch (e) {
      throw Exception('Failed to get wishlist products: ${e.toString()}');
    }
  }
}
