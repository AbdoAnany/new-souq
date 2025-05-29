import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_order.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  String selectedPeriod = 'Last 30 Days';
  final List<String> periods = ['Last 7 Days', 'Last 30 Days', 'Last 3 Months', 'Last Year'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminAnalyticsProvider.notifier).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(adminAnalyticsProvider);
    final orders = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: selectedPeriod,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Theme.of(context).primaryColor,
              style: const TextStyle(color: Colors.white),
              items: periods.map((String period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPeriod = newValue;
                  });
                  // Reload analytics for new period
                  ref.read(adminAnalyticsProvider.notifier).loadAnalytics();
                }
              },
            ),
          ),
        ],
      ),
      body: analytics.when(
        data: (data) => _buildAnalytics(context, data, orders.value ?? []),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading analytics: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(adminAnalyticsProvider.notifier).loadAnalytics(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, Map<String, dynamic> analytics, List<UserOrder> orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          _buildKeyMetrics(analytics),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildRevenueChart(context, orders),
          const SizedBox(height: 24),

          // Orders Status Chart
          _buildOrdersStatusChart(context, orders),
          const SizedBox(height: 24),

          // Top Products
          _buildTopProducts(context, analytics),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(context, orders),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Revenue',
          '\$${analytics['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Orders',
          '${analytics['totalOrders'] ?? 0}',
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildMetricCard(
          'Active Users',
          '${analytics['activeUsers'] ?? 0}',
          Icons.people,
          Colors.orange,
        ),
        _buildMetricCard(
          'Products Sold',
          '${analytics['productsSold'] ?? 0}',
          Icons.inventory,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context, List<UserOrder> orders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Simple day labels
                          return Text('Day ${value.toInt()}');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateRevenueSpots(orders),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateRevenueSpots(List<UserOrder> orders) {
    // Generate dummy revenue data for demo
    return List.generate(7, (index) {
      double revenue = 100 + (index * 50) + (index % 2 == 0 ? 25 : 0);
      return FlSpot(index.toDouble(), revenue);
    });
  }

  Widget _buildOrdersStatusChart(BuildContext context, List<UserOrder> orders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders by Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _generateOrderStatusSections(orders),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateOrderStatusSections(List<UserOrder> orders) {
    Map<String, int> statusCounts = {
      'pending': 5,
      'processing': 8,
      'shipped': 12,
      'delivered': 25,
      'cancelled': 2,
    };

    List<Color> colors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
    ];

    return statusCounts.entries.map((entry) {
      int index = statusCounts.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: colors[index % colors.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildStatusLegend() {
    List<String> statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    List<Color> colors = [Colors.orange, Colors.blue, Colors.purple, Colors.green, Colors.red];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: statuses.map((status) {
        int index = statuses.indexOf(status);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(status.toUpperCase()),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTopProducts(BuildContext context, Map<String, dynamic> analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Product ${index + 1}'),
                  subtitle: Text('Category: Electronics'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${50 - (index * 8)} sold',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${(500 - (index * 50)).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<UserOrder> orders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActivityColor(index),
                    child: Icon(
                      _getActivityIcon(index),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(_getActivityTitle(index)),
                  subtitle: Text(_getActivitySubtitle(index)),
                  trailing: Text(
                    _getActivityTime(index),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(int index) {
    List<Color> colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.red];
    return colors[index % colors.length];
  }

  IconData _getActivityIcon(int index) {
    List<IconData> icons = [
      Icons.shopping_cart,
      Icons.person_add,
      Icons.inventory,
      Icons.local_shipping,
      Icons.cancel,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    List<String> titles = [
      'New order received',
      'New user registered',
      'Product updated',
      'Order shipped',
      'Order cancelled',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    List<String> subtitles = [
      'Order #12345 - \$125.99',
      'John Doe joined',
      'iPhone 13 Pro stock updated',
      'Order #12344 shipped to customer',
      'Order #12343 cancelled by user',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityTime(int index) {
    List<String> times = [
      '2 min ago',
      '15 min ago',
      '1 hour ago',
      '3 hours ago',
      '5 hours ago',
    ];
    return times[index % times.length];
  }
}
