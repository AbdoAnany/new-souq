import 'package:equatable/equatable.dart';

// Analytics data entity for admin dashboard
class AnalyticsEntity extends Equatable {
  final double totalRevenue;
  final double monthlyRevenue;
  final double dailyRevenue;
  final int totalOrders;
  final int monthlyOrders;
  final int dailyOrders;
  final int totalCustomers;
  final int monthlyCustomers;
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double averageOrderValue;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final List<CategorySalesEntity> topCategories;
  final List<ProductSalesEntity> topProducts;
  final List<MonthlySalesEntity> monthlySales;
  final DateTime lastUpdated;

  const AnalyticsEntity({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.dailyRevenue,
    required this.totalOrders,
    required this.monthlyOrders,
    required this.dailyOrders,
    required this.totalCustomers,
    required this.monthlyCustomers,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.averageOrderValue,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.topCategories,
    required this.topProducts,
    required this.monthlySales,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [
        totalRevenue,
        monthlyRevenue,
        dailyRevenue,
        totalOrders,
        monthlyOrders,
        dailyOrders,
        totalCustomers,
        monthlyCustomers,
        totalProducts,
        lowStockProducts,
        outOfStockProducts,
        averageOrderValue,
        pendingOrders,
        completedOrders,
        cancelledOrders,
        topCategories,
        topProducts,
        monthlySales,
        lastUpdated,
      ];
}

// Category sales data
class CategorySalesEntity extends Equatable {
  final String categoryId;
  final String categoryName;
  final double revenue;
  final int orderCount;

  const CategorySalesEntity({
    required this.categoryId,
    required this.categoryName,
    required this.revenue,
    required this.orderCount,
  });

  @override
  List<Object> get props => [categoryId, categoryName, revenue, orderCount];
}

// Product sales data
class ProductSalesEntity extends Equatable {
  final String productId;
  final String productName;
  final double revenue;
  final int unitsSold;

  const ProductSalesEntity({
    required this.productId,
    required this.productName,
    required this.revenue,
    required this.unitsSold,
  });

  @override
  List<Object> get props => [productId, productName, revenue, unitsSold];
}

// Monthly sales data for charts
class MonthlySalesEntity extends Equatable {
  final int month;
  final int year;
  final double revenue;
  final int orderCount;

  const MonthlySalesEntity({
    required this.month,
    required this.year,
    required this.revenue,
    required this.orderCount,
  });

  @override
  List<Object> get props => [month, year, revenue, orderCount];
}
