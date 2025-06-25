import 'dart:async';

import 'package:flutter/foundation.dart';

/// Service for monitoring and tracking order-related performance metrics
class OrderPerformanceMonitor {
  static final OrderPerformanceMonitor _instance =
      OrderPerformanceMonitor._internal();
  factory OrderPerformanceMonitor() => _instance;
  OrderPerformanceMonitor._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final List<PerformanceMetric> _metrics = [];
  final StreamController<PerformanceMetric> _metricsController =
      StreamController.broadcast();

  /// Stream of performance metrics
  Stream<PerformanceMetric> get metricsStream => _metricsController.stream;

  /// Start tracking an operation
  void startOperation(String operationId, String operationType,
      {Map<String, dynamic>? context}) {
    _operationStartTimes[operationId] = DateTime.now();

    if (kDebugMode) {
      print('📊 Starting operation: $operationType ($operationId)');
    }
  }

  /// End tracking an operation and record the metric
  void endOperation(
    String operationId,
    String operationType, {
    bool success = true,
    String? errorMessage,
    Map<String, dynamic>? context,
  }) {
    final startTime = _operationStartTimes.remove(operationId);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    final metric = PerformanceMetric(
      operationId: operationId,
      operationType: operationType,
      duration: duration,
      success: success,
      errorMessage: errorMessage,
      context: context ?? {},
      timestamp: DateTime.now(),
    );

    _metrics.add(metric);
    _metricsController.add(metric);

    if (kDebugMode) {
      final status = success ? '✅' : '❌';
      print(
          '📊 $status $operationType completed in ${duration.inMilliseconds}ms');
      if (!success && errorMessage != null) {
        print('📊 Error: $errorMessage');
      }
    }

    // Clean up old metrics (keep last 1000)
    if (_metrics.length > 1000) {
      _metrics.removeRange(0, _metrics.length - 1000);
    }
  }

  /// Track a simple operation with automatic timing
  Future<T> trackOperation<T>(
    String operationId,
    String operationType,
    Future<T> Function() operation, {
    Map<String, dynamic>? context,
  }) async {
    startOperation(operationId, operationType, context: context);

    try {
      final result = await operation();
      endOperation(operationId, operationType, success: true, context: context);
      return result;
    } catch (e) {
      endOperation(
        operationId,
        operationType,
        success: false,
        errorMessage: e.toString(),
        context: context,
      );
      rethrow;
    }
  }

  /// Get performance statistics for a specific operation type
  OperationStats getStats(String operationType) {
    final operationMetrics = _metrics
        .where((metric) => metric.operationType == operationType)
        .toList();

    if (operationMetrics.isEmpty) {
      return OperationStats.empty(operationType);
    }

    final durations =
        operationMetrics.map((m) => m.duration.inMilliseconds).toList();
    durations.sort();

    final successCount = operationMetrics.where((m) => m.success).length;
    final errorCount = operationMetrics.length - successCount;

    return OperationStats(
      operationType: operationType,
      totalOperations: operationMetrics.length,
      successCount: successCount,
      errorCount: errorCount,
      averageDuration: Duration(
          milliseconds:
              (durations.reduce((a, b) => a + b) / durations.length).round()),
      medianDuration: Duration(milliseconds: durations[durations.length ~/ 2]),
      minDuration: Duration(milliseconds: durations.first),
      maxDuration: Duration(milliseconds: durations.last),
      p95Duration:
          Duration(milliseconds: durations[(durations.length * 0.95).floor()]),
      successRate: successCount / operationMetrics.length,
    );
  }

  /// Get all performance statistics
  Map<String, OperationStats> getAllStats() {
    final operationTypes = _metrics.map((m) => m.operationType).toSet();
    final stats = <String, OperationStats>{};

    for (final operationType in operationTypes) {
      stats[operationType] = getStats(operationType);
    }

    return stats;
  }

  /// Get recent metrics (last N metrics)
  List<PerformanceMetric> getRecentMetrics([int count = 50]) {
    return _metrics.reversed.take(count).toList();
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _operationStartTimes.clear();
  }

  /// Check if any operation is currently being tracked
  bool hasActiveOperations() {
    return _operationStartTimes.isNotEmpty;
  }

  /// Get list of currently active operations
  List<String> getActiveOperations() {
    return _operationStartTimes.keys.toList();
  }

  /// Dispose resources
  void dispose() {
    _metricsController.close();
    clearMetrics();
  }
}

/// Represents a single performance metric
class PerformanceMetric {
  final String operationId;
  final String operationType;
  final Duration duration;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  const PerformanceMetric({
    required this.operationId,
    required this.operationType,
    required this.duration,
    required this.success,
    this.errorMessage,
    required this.context,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'operationType': operationType,
      'duration': duration.inMilliseconds,
      'success': success,
      'errorMessage': errorMessage,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PerformanceMetric(type: $operationType, duration: ${duration.inMilliseconds}ms, success: $success)';
  }
}

/// Statistics for a specific operation type
class OperationStats {
  final String operationType;
  final int totalOperations;
  final int successCount;
  final int errorCount;
  final Duration averageDuration;
  final Duration medianDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration p95Duration;
  final double successRate;

  const OperationStats({
    required this.operationType,
    required this.totalOperations,
    required this.successCount,
    required this.errorCount,
    required this.averageDuration,
    required this.medianDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.p95Duration,
    required this.successRate,
  });

  factory OperationStats.empty(String operationType) {
    return OperationStats(
      operationType: operationType,
      totalOperations: 0,
      successCount: 0,
      errorCount: 0,
      averageDuration: Duration.zero,
      medianDuration: Duration.zero,
      minDuration: Duration.zero,
      maxDuration: Duration.zero,
      p95Duration: Duration.zero,
      successRate: 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operationType': operationType,
      'totalOperations': totalOperations,
      'successCount': successCount,
      'errorCount': errorCount,
      'averageDuration': averageDuration.inMilliseconds,
      'medianDuration': medianDuration.inMilliseconds,
      'minDuration': minDuration.inMilliseconds,
      'maxDuration': maxDuration.inMilliseconds,
      'p95Duration': p95Duration.inMilliseconds,
      'successRate': successRate,
    };
  }

  @override
  String toString() {
    return 'OperationStats(type: $operationType, '
        'total: $totalOperations, '
        'success: ${(successRate * 100).toStringAsFixed(1)}%, '
        'avg: ${averageDuration.inMilliseconds}ms)';
  }
}

/// Common operation types for tracking
class OrderOperationTypes {
  static const String loadOrderList = 'load_order_list';
  static const String loadOrderDetails = 'load_order_details';
  static const String updateOrderStatus = 'update_order_status';
  static const String placeOrder = 'place_order';
  static const String cancelOrder = 'cancel_order';
  static const String searchOrders = 'search_orders';
  static const String cacheOperation = 'cache_operation';
  static const String networkRequest = 'network_request';
  static const String databaseQuery = 'database_query';
  static const String validation = 'validation';
  static const String imageLoad = 'image_load';
  static const String paginatedLoad = 'paginated_load';
}

/// Extension for easy performance tracking
extension PerformanceTrackingExtension on Future {
  /// Track this future operation with performance monitoring
  Future<T> trackPerformance<T>(
    String operationType, {
    String? operationId,
    Map<String, dynamic>? context,
  }) async {
    final id = operationId ??
        '${operationType}_${DateTime.now().millisecondsSinceEpoch}';
    return OrderPerformanceMonitor().trackOperation<T>(
      id,
      operationType,
      () => this as Future<T>,
      context: context,
    );
  }
}
