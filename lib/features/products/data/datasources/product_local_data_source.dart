import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<ProductModel?> getCachedProduct(String id);
  Future<void> cacheProduct(ProductModel product);
  Future<List<ProductModel>> getCachedFeaturedProducts();
  Future<void> cacheFeaturedProducts(List<ProductModel> products);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedProductsKey = 'CACHED_PRODUCTS';
  static const String _cachedFeaturedProductsKey = 'CACHED_FEATURED_PRODUCTS';
  static const String _cachedProductPrefix = 'CACHED_PRODUCT_';

  ProductLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedProductsKey);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List;
        return jsonList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached products: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final jsonString = json.encode(products.map((p) => p.toJson()).toList());
      await sharedPreferences.setString(_cachedProductsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel?> getCachedProduct(String id) async {
    try {
      final jsonString = sharedPreferences.getString('$_cachedProductPrefix$id');
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return ProductModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached product: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    try {
      final jsonString = json.encode(product.toJson());
      await sharedPreferences.setString(
          '$_cachedProductPrefix${product.id}', jsonString);
    } catch (e) {
      throw CacheException('Failed to cache product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getCachedFeaturedProducts() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedFeaturedProductsKey);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List;
        return jsonList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached featured products: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheFeaturedProducts(List<ProductModel> products) async {
    try {
      final jsonString = json.encode(products.map((p) => p.toJson()).toList());
      await sharedPreferences.setString(_cachedFeaturedProductsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache featured products: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Get all keys that start with product cache prefixes
      final keys = sharedPreferences.getKeys();
      final productKeys = keys.where((key) =>
          key == _cachedProductsKey ||
          key == _cachedFeaturedProductsKey ||
          key.startsWith(_cachedProductPrefix));

      for (final key in productKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear product cache: ${e.toString()}');
    }
  }
}
