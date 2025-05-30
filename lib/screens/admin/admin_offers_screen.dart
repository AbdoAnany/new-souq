import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/providers/admin_provider.dart';
import 'package:souq/screens/admin/widgets/offer_form_dialog.dart';

class AdminOffersScreen extends ConsumerStatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  ConsumerState<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends ConsumerState<AdminOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  OfferType? _selectedType;
  bool? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offersAsync = ref.watch(adminOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Offers'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminOffersProvider.notifier).fetchOffers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: theme.cardColor,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search offers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<OfferType?>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...OfferType.values.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Offers list
          Expanded(
            child: offersAsync.when(
              data: (offers) {
                final filteredOffers = _filterOffers(offers);

                if (filteredOffers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _selectedType != null ||
                                  _selectedStatus != null
                              ? 'No offers found matching your filters'
                              : 'No offers available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: filteredOffers.length,
                  itemBuilder: (context, index) {
                    final offer = filteredOffers[index];
                    return _buildOfferCard(context, offer);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Error loading offers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(adminOffersProvider.notifier)
                            .fetchOffers();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOfferFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Offer> _filterOffers(List<Offer> offers) {
    return offers.where((offer) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          offer.title.toLowerCase().contains(_searchQuery) ||
          offer.description.toLowerCase().contains(_searchQuery);

      // Type filter
      final matchesType = _selectedType == null || offer.type == _selectedType;

      // Status filter
      final matchesStatus =
          _selectedStatus == null || offer.isActive == _selectedStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  Widget _buildOfferCard(BuildContext context, Offer offer) {
    final theme = Theme.of(context);
    final isExpired = offer.isExpired;
    final isUpcoming = offer.isUpcoming;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: () => _showOfferFormDialog(context, offer: offer),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status indicators
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.type.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status indicators
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'EXPIRED',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (isUpcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'UPCOMING',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (offer.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'INACTIVE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Description
              Text(
                offer.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Offer details
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            'Discount',
                            _getDiscountText(offer),
                            Icons.percent,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailItem(
                            'Usage',
                            '${offer.usedCount}${offer.usageLimit > 0 ? '/${offer.usageLimit}' : ''}',
                            Icons.people,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            'Start',
                            _formatDate(offer.startDate),
                            Icons.play_arrow,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailItem(
                            'End',
                            _formatDate(offer.endDate),
                            Icons.stop,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            _showOfferFormDialog(context, offer: offer),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      TextButton.icon(
                        onPressed: () => _toggleOfferStatus(offer),
                        icon: Icon(
                          offer.isActive
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 16,
                        ),
                        label: Text(offer.isActive ? 'Deactivate' : 'Activate'),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _deleteOffer(context, offer),
                    icon: const Icon(Icons.delete),
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDiscountText(Offer offer) {
    switch (offer.type) {
      case OfferType.percentage:
        return '${offer.discountPercentage?.toInt() ?? 0}%';
      case OfferType.fixed:
        return '\$${offer.discountAmount?.toStringAsFixed(2) ?? '0.00'}';
      case OfferType.buyOneGetOne:
        return 'BOGO';
      case OfferType.freeShipping:
        return 'Free Ship';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOfferFormDialog(BuildContext context, {Offer? offer}) {
    showDialog(
      context: context,
      builder: (context) => OfferFormDialog(offer: offer),
    );
  }

  void _toggleOfferStatus(Offer offer) {
    ref
        .read(adminOffersProvider.notifier)
        .toggleStatus(offer.id, !offer.isActive);
  }

  void _deleteOffer(BuildContext context, Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text('Are you sure you want to delete "${offer.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(adminOffersProvider.notifier)
                  .deleteOffer(offer.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
