import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getCachedOrders(String userId);
  Future<void> cacheOrders(String userId, List<OrderModel> orders);
  Future<OrderModel?> getCachedOrder(String orderId);
  Future<void> cacheOrder(OrderModel order);
  Future<void> clearCache();
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final SharedPreferences sharedPreferences;

  OrderLocalDataSourceImpl({required this.sharedPreferences});

  static const String _cachedOrdersPrefix = 'CACHED_ORDERS_';
  static const String _cachedOrderPrefix = 'CACHED_ORDER_';

  @override
  Future<List<OrderModel>> getCachedOrders(String userId) async {
    try {
      final ordersJson =
          sharedPreferences.getString('${_cachedOrdersPrefix}$userId');
      if (ordersJson != null) {
        final ordersList = json.decode(ordersJson) as List<dynamic>;
        return ordersList
            .map((orderJson) =>
                OrderModel.fromJson(orderJson as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw CacheException('Failed to get cached orders: $e');
    }
  }

  @override
  Future<void> cacheOrders(String userId, List<OrderModel> orders) async {
    try {
      final ordersJson = orders.map((order) => order.toJson()).toList();
      await sharedPreferences.setString(
        '${_cachedOrdersPrefix}$userId',
        json.encode(ordersJson),
      );
    } catch (e) {
      throw CacheException('Failed to cache orders: $e');
    }
  }

  @override
  Future<OrderModel?> getCachedOrder(String orderId) async {
    try {
      final orderJson =
          sharedPreferences.getString('${_cachedOrderPrefix}$orderId');
      if (orderJson != null) {
        return OrderModel.fromJson(
            json.decode(orderJson) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached order: $e');
    }
  }

  @override
  Future<void> cacheOrder(OrderModel order) async {
    try {
      await sharedPreferences.setString(
        '${_cachedOrderPrefix}${order.id}',
        json.encode(order.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache order: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      final orderCacheKeys = keys.where((key) =>
          key.startsWith(_cachedOrdersPrefix) ||
          key.startsWith(_cachedOrderPrefix));

      for (final key in orderCacheKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear order cache: $e');
    }
  }
}
