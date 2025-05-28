import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/offer.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isSmall;
  final VoidCallback? onTap;

  const OfferCard({
    Key? key,
    required this.offer,
    this.isSmall = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isSmall) {
      return InkWell(
        onTap: onTap ?? () {
          // Navigate to offer details or apply discount
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  fit: BoxFit.cover,
                  width: 200,
                  height: 100,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.primaryColor.withOpacity(0.2),
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Discount badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(                      color: AppConstants.secondaryColor,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      ),
                      child: Text(
                        offer.type == OfferType.percentage && offer.discountPercentage != null
                            ? '${offer.discountPercentage!.toInt()}% OFF'
                            : offer.discountAmount != null 
                                ? '\$${offer.discountAmount!.toInt()} OFF'
                                : 'SPECIAL OFFER',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Title
                    SizedBox(
                      width: 120,
                      child: Text(
                        offer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Regular size offer card for carousel
    return InkWell(
      onTap: onTap ?? () {
        // Navigate to offer details or apply discount
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: CachedNetworkImage(
                imageUrl: offer.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Discount badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(                    color: AppConstants.secondaryColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      offer.type == OfferType.percentage && offer.discountPercentage != null
                          ? '${offer.discountPercentage!.toInt()}% OFF'
                          : offer.discountAmount != null 
                              ? '\$${offer.discountAmount!.toInt()} OFF'
                              : 'SPECIAL OFFER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Title
                  SizedBox(
                    width: 200,
                    child: Text(
                      offer.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  SizedBox(
                    width: 200,
                    child: Text(
                      offer.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // CTA Button
                  ElevatedButton(
                    onPressed: () {
                      // Apply offer or navigate
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),            ),
            
            // Expiry tag
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Text(
                  'Ends in ${_getRemainingDays(offer.endDate)} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  int _getRemainingDays(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
}
