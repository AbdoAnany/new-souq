import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int? limit,
    String? category,
    double? minPrice,
    double? maxPrice,
  });
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<String>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String category);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ProductModel>> getProducts({
    int? limit,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      Query query = firestore.collection('products');

      // Apply filters
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await firestore.collection('products').doc(id).get();

      if (!doc.exists) {
        throw const ServerException('Product not found');
      }

      return ProductModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw ServerException('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final querySnapshot = await firestore
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get featured products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Search by name (case-insensitive)
      final nameQuerySnapshot = await firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('name', isLessThan: '${query.toLowerCase()}z')
          .get();

      // Search by description
      final descriptionQuerySnapshot = await firestore
          .collection('products')
          .where('description', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('description', isLessThan: '${query.toLowerCase()}z')
          .get();

      // Combine results and remove duplicates
      final Map<String, ProductModel> productsMap = {};

      for (final doc in nameQuerySnapshot.docs) {
        productsMap[doc.id] = ProductModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }

      for (final doc in descriptionQuerySnapshot.docs) {
        if (!productsMap.containsKey(doc.id)) {
          productsMap[doc.id] = ProductModel.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }
      }

      return productsMap.values.toList();
    } catch (e) {
      throw ServerException('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await firestore.collection('categories').get();

      return querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
    } catch (e) {
      throw ServerException('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get products by category: ${e.toString()}');
    }
  }
}
