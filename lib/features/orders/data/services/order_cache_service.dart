import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

/// Service for caching order data to improve performance
class OrderCacheService {
  static const String _orderCacheKey = 'cached_orders';
  static const String _cacheTimestampKey = 'cache_timestamps';
  static const Duration _cacheTimeout = Duration(minutes: 5);
  static const int _maxCacheSize = 50;

  final SharedPreferences _prefs;
  final Map<String, OrderEntity> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  OrderCacheService(this._prefs) {
    _loadCacheFromStorage();
  }

  /// Get cached order by ID
  OrderEntity? getCachedOrder(String orderId) {
    final timestamp = _cacheTimestamps[orderId];
    if (timestamp == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(timestamp) > _cacheTimeout) {
      _removeCachedOrder(orderId);
      return null;
    }

    return _memoryCache[orderId];
  }

  /// Cache an order
  Future<void> cacheOrder(OrderEntity order) async {
    // Ensure cache size doesn't exceed limit
    _ensureCacheSize();

    _memoryCache[order.id] = order;
    _cacheTimestamps[order.id] = DateTime.now();

    await _saveCacheToStorage();
  }

  /// Cache multiple orders
  Future<void> cacheOrders(List<OrderEntity> orders) async {
    for (final order in orders) {
      _memoryCache[order.id] = order;
      _cacheTimestamps[order.id] = DateTime.now();
    }

    _ensureCacheSize();
    await _saveCacheToStorage();
  }

  /// Remove specific order from cache
  void _removeCachedOrder(String orderId) {
    _memoryCache.remove(orderId);
    _cacheTimestamps.remove(orderId);
  }

  /// Clear all cached orders
  Future<void> clearCache() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    await _prefs.remove(_orderCacheKey);
    await _prefs.remove(_cacheTimestampKey);
  }

  /// Get all cached order IDs
  List<String> getCachedOrderIds() {
    return _memoryCache.keys.toList();
  }

  /// Check if order is cached and valid
  bool isOrderCached(String orderId) {
    final timestamp = _cacheTimestamps[orderId];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) <= _cacheTimeout;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final validOrders = _cacheTimestamps.entries
        .where(
            (entry) => DateTime.now().difference(entry.value) <= _cacheTimeout)
        .length;

    return {
      'total_cached': _memoryCache.length,
      'valid_cached': validOrders,
      'expired_cached': _memoryCache.length - validOrders,
      'cache_size_limit': _maxCacheSize,
      'cache_timeout_minutes': _cacheTimeout.inMinutes,
    };
  }

  /// Ensure cache doesn't exceed maximum size
  void _ensureCacheSize() {
    if (_memoryCache.length <= _maxCacheSize) return;

    // Remove oldest entries
    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final entriesToRemove =
        sortedEntries.take(_memoryCache.length - _maxCacheSize);
    for (final entry in entriesToRemove) {
      _removeCachedOrder(entry.key);
    }
  }

  /// Load cache from persistent storage
  void _loadCacheFromStorage() {
    try {
      final cachedOrdersJson = _prefs.getStringList(_orderCacheKey) ?? [];
      final timestampsJson = _prefs.getString(_cacheTimestampKey);

      // Load timestamps
      if (timestampsJson != null) {
        final timestampMap =
            json.decode(timestampsJson) as Map<String, dynamic>;
        timestampMap.forEach((key, value) {
          _cacheTimestamps[key] = DateTime.parse(value as String);
        });
      }

      // Load orders
      for (final orderJson in cachedOrdersJson) {
        try {
          final orderMap = json.decode(orderJson) as Map<String, dynamic>;
          final order = OrderModel.fromJson(orderMap);

          // Only load if not expired
          if (isOrderCached(order.id)) {
            _memoryCache[order.id] = order;
          }
        } catch (e) {
          // Skip corrupted entries
          continue;
        }
      }

      // Clean up expired entries
      _cleanupExpiredEntries();
    } catch (e) {
      // If loading fails, start with empty cache
      _memoryCache.clear();
      _cacheTimestamps.clear();
    }
  }

  /// Save cache to persistent storage
  Future<void> _saveCacheToStorage() async {
    try {
      final orderJsonList = _memoryCache.values
          .map((order) => json.encode(_orderToJson(order)))
          .toList();

      final timestampMap = <String, String>{};
      _cacheTimestamps.forEach((key, value) {
        timestampMap[key] = value.toIso8601String();
      });

      await _prefs.setStringList(_orderCacheKey, orderJsonList);
      await _prefs.setString(_cacheTimestampKey, json.encode(timestampMap));
    } catch (e) {
      // Handle storage errors silently
    }
  }

  /// Remove expired entries from cache
  void _cleanupExpiredEntries() {
    final now = DateTime.now();
    final expiredIds = <String>[];

    _cacheTimestamps.forEach((orderId, timestamp) {
      if (now.difference(timestamp) > _cacheTimeout) {
        expiredIds.add(orderId);
      }
    });

    for (final orderId in expiredIds) {
      _removeCachedOrder(orderId);
    }
  }

  /// Preload orders into cache
  Future<void> preloadOrders(List<OrderEntity> orders) async {
    await cacheOrders(orders);
  }

  /// Invalidate cache for specific order
  Future<void> invalidateOrder(String orderId) async {
    _removeCachedOrder(orderId);
    await _saveCacheToStorage();
  }

  /// Update cached order
  Future<void> updateCachedOrder(OrderEntity order) async {
    if (_memoryCache.containsKey(order.id)) {
      await cacheOrder(order);
    }
  }

  /// Convert OrderEntity to JSON map for caching
  Map<String, dynamic> _orderToJson(OrderEntity order) {
    if (order is OrderModel) {
      return order.toJson();
    }

    // Create OrderModel from OrderEntity for serialization
    final orderModel = OrderModel(
      id: order.id,
      userId: order.userId,
      orderNumber: order.orderNumber,
      items: order.items,
      subtotal: order.subtotal,
      shipping: order.shipping,
      tax: order.tax,
      total: order.total,
      status: order.status,
      paymentStatus: order.paymentStatus,
      paymentMethod: order.paymentMethod,
      shippingAddress: order.shippingAddress,
      orderDate: order.orderDate,
      shippedDate: order.shippedDate,
      deliveredDate: order.deliveredDate,
      trackingNumber: order.trackingNumber,
      notes: order.notes,
    );

    return orderModel.toJson();
  }
}

/// Pagination metadata for order lists
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.empty() {
    return const PaginationMeta(
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      itemsPerPage: 20,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  factory PaginationMeta.fromData({
    required int currentPage,
    required int totalItems,
    required int itemsPerPage,
  }) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    return PaginationMeta(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    );
  }

  PaginationMeta copyWith({
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? itemsPerPage,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PaginationMeta(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalItems: json['totalItems'] as int,
      itemsPerPage: json['itemsPerPage'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage/$totalPages, items: $totalItems)';
  }
}

/// Result wrapper for paginated data
class PaginatedResult<T> {
  final List<T> data;
  final PaginationMeta pagination;

  const PaginatedResult({
    required this.data,
    required this.pagination,
  });

  factory PaginatedResult.empty() {
    return PaginatedResult<T>(
      data: [],
      pagination: PaginationMeta.empty(),
    );
  }

  PaginatedResult<T> copyWith({
    List<T>? data,
    PaginationMeta? pagination,
  }) {
    return PaginatedResult<T>(
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(items: ${data.length}, pagination: $pagination)';
  }
}
