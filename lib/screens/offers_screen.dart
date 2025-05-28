import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/widgets/offer_card.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final offersAsyncValue = ref.watch(offerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.offers,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: offersAsyncValue.when(
        data: (offers) {
          if (offers.isEmpty) {
            return _buildEmptyOffers(context);
          }
          
          return _buildOffersGrid(context, offers);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text("Error loading offers"),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(offerProvider.notifier).fetchOffers();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOffers(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: theme.dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            "No offers available",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for special deals and discounts!",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersGrid(BuildContext context, List<Offer> offers) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [        // Featured offers section (using active offers as featured)
        if (offers.any((offer) => offer.isActive)) ...[
          Text(
            "Featured Offers",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Featured offers carousel
          SizedBox(
            height: 180,            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: offers.where((offer) => offer.isActive).length,
              itemBuilder: (context, index) {
                final offer = offers.where((o) => o.isActive).toList()[index];
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.only(right: 16),
                  child: OfferCard(
                    offer: offer,
                    onTap: () => _navigateToOffer(context, offer),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // All offers section
        Text(
          "All Offers",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid of all offers
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return _buildOfferItem(context, offer);
          },
        ),
      ],
    );
  }

  Widget _buildOfferItem(BuildContext context, Offer offer) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _navigateToOffer(context, offer),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                topRight: Radius.circular(AppConstants.borderRadiusMedium),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    // Image
                    Image.network(
                      offer.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.primaryColor.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.local_offer_outlined,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    
                    // Discount badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),                        child: Text(
                          offer.type == OfferType.percentage && offer.discountPercentage != null
                              ? '${offer.discountPercentage!.toInt()}% OFF'
                              : offer.discountAmount != null 
                                  ? '\$${offer.discountAmount!.toInt()} OFF'
                                  : 'SPECIAL OFFER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                      // Expiry tag
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          _getExpiryText(offer.endDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Offer details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    offer.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    offer.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToOffer(context, offer),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                      ),
                      child: const Text("Shop Now"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }  void _navigateToOffer(BuildContext context, Offer offer) {
    // For now, just show a snackbar. In a real app, this would navigate to 
    // a product list screen filtered by the offer criteria
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Opening ${offer.title} products"),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
        ),
      ),
    );
  }
  
  String _getExpiryText(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    if (difference.inDays > 0) {
      return 'Ends in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Ends in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'Ends in ${difference.inMinutes} mins';
    } else {
      return 'Ending soon';
    }
  }
}
