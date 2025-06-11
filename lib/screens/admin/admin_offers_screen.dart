import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/providers/admin_provider.dart';
import 'package:souq/screens/admin/widgets/offer_form_dialog.dart';

import '../../core/widgets/my_app_bar.dart';
import '../../utils/responsive_util.dart';

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
      appBar: MyAppBar(
        title: Text(
          'Manage Offers',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: ResponsiveUtil.iconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
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
            padding: EdgeInsets.all(ResponsiveUtil.spacing(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            )),
            color: theme.cardColor,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search offers...',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: ResponsiveUtil.iconSize(
                        mobile: 20,
                        tablet: 22,
                        desktop: 24,
                      ),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: ResponsiveUtil.iconSize(
                                mobile: 20,
                                tablet: 22,
                                desktop: 24,
                              ),
                            ),
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
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(
                    height: ResponsiveUtil.spacing(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                )),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<OfferType?>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'All Types',
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                            ),
                          ),
                          ...OfferType.values.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14,
                                      tablet: 15,
                                      desktop: 16,
                                    ),
                                  ),
                                ),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'All Status',
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                              'Active',
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                            ),
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
                          size: ResponsiveUtil.iconSize(
                            mobile: 64,
                            tablet: 72,
                            desktop: 80,
                          ),
                          color: theme.disabledColor,
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        )),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _selectedType != null ||
                                  _selectedStatus != null
                              ? 'No offers found matching your filters'
                              : 'No offers available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.disabledColor,
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(ResponsiveUtil.spacing(
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  )),
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
                      size: ResponsiveUtil.iconSize(
                        mobile: 64,
                        tablet: 72,
                        desktop: 80,
                      ),
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                    Text(
                      'Error loading offers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    )),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.disabledColor,
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(adminOffersProvider.notifier).fetchOffers();
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                        ),
                      ),
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
        child: Icon(
          Icons.add,
          size: ResponsiveUtil.iconSize(
            mobile: 24,
            tablet: 26,
            desktop: 28,
          ),
        ),
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
      margin: EdgeInsets.only(
        bottom: ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        ),
      ),
      child: InkWell(
        onTap: () => _showOfferFormDialog(context, offer: offer),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtil.spacing(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          )),
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
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        )),
                        Text(
                          offer.type.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                            ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtil.spacing(
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                            vertical: ResponsiveUtil.spacing(
                              mobile: 4,
                              tablet: 5,
                              desktop: 6,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'EXPIRED',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 10,
                                tablet: 11,
                                desktop: 12,
                              ),
                            ),
                          ),
                        )
                      else if (isUpcoming)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtil.spacing(
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                            vertical: ResponsiveUtil.spacing(
                              mobile: 4,
                              tablet: 5,
                              desktop: 6,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'UPCOMING',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 10,
                                tablet: 11,
                                desktop: 12,
                              ),
                            ),
                          ),
                        )
                      else if (offer.isActive)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtil.spacing(
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                            vertical: ResponsiveUtil.spacing(
                              mobile: 4,
                              tablet: 5,
                              desktop: 6,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 10,
                                tablet: 11,
                                desktop: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtil.spacing(
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                            vertical: ResponsiveUtil.spacing(
                              mobile: 4,
                              tablet: 5,
                              desktop: 6,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'INACTIVE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 10,
                                tablet: 11,
                                desktop: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 16,
                tablet: 18,
                desktop: 20,
              )),

              // Description
              Text(
                offer.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 16,
                tablet: 18,
                desktop: 20,
              )),

              // Offer details
              Container(
                padding: EdgeInsets.all(ResponsiveUtil.spacing(
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                )),
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
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    )),
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
              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 16,
                tablet: 18,
                desktop: 20,
              )),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            _showOfferFormDialog(context, offer: offer),
                        icon: Icon(
                          Icons.edit,
                          size: ResponsiveUtil.iconSize(
                            mobile: 16,
                            tablet: 17,
                            desktop: 18,
                          ),
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: ResponsiveUtil.spacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                      TextButton.icon(
                        onPressed: () => _toggleOfferStatus(offer),
                        icon: Icon(
                          offer.isActive
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: ResponsiveUtil.iconSize(
                            mobile: 16,
                            tablet: 17,
                            desktop: 18,
                          ),
                        ),
                        label: Text(
                          offer.isActive ? 'Deactivate' : 'Activate',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _deleteOffer(context, offer),
                    icon: Icon(
                      Icons.delete,
                      size: ResponsiveUtil.iconSize(
                        mobile: 20,
                        tablet: 22,
                        desktop: 24,
                      ),
                    ),
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
        Icon(
          icon,
          size: ResponsiveUtil.iconSize(
            mobile: 16,
            tablet: 17,
            desktop: 18,
          ),
          color: theme.primaryColor,
        ),
        SizedBox(
            width: ResponsiveUtil.spacing(
          mobile: 4,
          tablet: 5,
          desktop: 6,
        )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
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
        title: Text(
          'Delete Offer',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${offer.title}"?',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminOffersProvider.notifier).deleteOffer(offer.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
