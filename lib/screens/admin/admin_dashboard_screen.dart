import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/providers/admin_provider.dart';
import 'package:souq/screens/admin/admin_products_screen.dart';
import 'package:souq/screens/admin/admin_categories_screen.dart';
import 'package:souq/screens/admin/admin_offers_screen.dart';
import 'package:souq/services/dummy_data_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoadingDummyData = false;

  @override
  void initState() {
    super.initState();
    // Fetch statistics when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).fetchStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statisticsState = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: AppConstants.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Welcome, Admin!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your store inventory, categories, and offers.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dummy Data Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoadingDummyData
                                ? null
                                : _initializeDummyData,
                            icon: _isLoadingDummyData
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_box),
                            label: Text(_isLoadingDummyData
                                ? 'Loading...'
                                : 'Add Dummy Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoadingDummyData ? null : _clearDummyData,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Data'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Section
            Text(
              'Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            statisticsState.when(
              data: (stats) => _buildStatisticsGrid(stats),
              loading: () => _buildStatisticsLoading(),
              error: (error, _) => _buildErrorWidget(error.toString()),
            ),
            const SizedBox(height: 24),

            // Management Sections
            Text(
              'Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildManagementGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, int> stats) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Products',
          stats['products']?.toString() ?? '0',
          Icons.inventory_2,
          AppConstants.primaryColor,
        ),
        _buildStatCard(
          'Categories',
          stats['categories']?.toString() ?? '0',
          Icons.category,
          AppConstants.secondaryColor,
        ),
        _buildStatCard(
          'Offers',
          stats['offers']?.toString() ?? '0',
          Icons.local_offer,
          AppConstants.accentColor,
        ),
        _buildStatCard(
          'Orders',
          stats['orders']?.toString() ?? '0',
          Icons.shopping_bag,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsLoading() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        4,
        (index) => Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildManagementCard(
          'Products',
          'Manage product inventory',
          Icons.inventory_2,
          AppConstants.primaryColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminProductsScreen()),
          ),
        ),
        _buildManagementCard(
          'Categories',
          'Organize product categories',
          Icons.category,
          AppConstants.secondaryColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminCategoriesScreen()),
          ),
        ),
        _buildManagementCard(
          'Offers',
          'Create and manage offers',
          Icons.local_offer,
          AppConstants.accentColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminOffersScreen()),
          ),
        ),
        _buildManagementCard(
          'Orders',
          'View and manage orders',
          Icons.shopping_bag,
          Colors.purple,
          () => _showComingSoon('Orders'),
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppConstants.errorColor, size: 48),
            const SizedBox(height: 8),
            Text(
              'Error loading statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(statisticsProvider.notifier).fetchStatistics(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeDummyData() async {
    setState(() {
      _isLoadingDummyData = true;
    });

    try {
      await DummyDataService().initializeDummyData();

      if (mounted) {
        // Refresh all providers
        ref.read(statisticsProvider.notifier).fetchStatistics();
        ref.read(adminProductsProvider.notifier).fetchProducts();
        ref.read(adminCategoriesProvider.notifier).fetchCategories();
        ref.read(adminOffersProvider.notifier).fetchOffers();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dummy data initialized successfully!'),
            backgroundColor: AppConstants.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDummyData = false;
        });
      }
    }
  }

  Future<void> _clearDummyData() async {
    final confirmed = await _showConfirmDialog(
      'Clear All Data',
      'Are you sure you want to clear all dummy data? This action cannot be undone.',
    );

    if (!confirmed) return;

    setState(() {
      _isLoadingDummyData = true;
    });

    try {
      await DummyDataService().clearDummyData();

      if (mounted) {
        // Refresh all providers
        ref.read(statisticsProvider.notifier).fetchStatistics();
        ref.read(adminProductsProvider.notifier).fetchProducts();
        ref.read(adminCategoriesProvider.notifier).fetchCategories();
        ref.read(adminOffersProvider.notifier).fetchOffers();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully!'),
            backgroundColor: AppConstants.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDummyData = false;
        });
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature management coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
