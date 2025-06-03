import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/utils/responsive_util.dart';
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
        loading: () => Center(
          child: SizedBox(
            width: ResponsiveUtil.iconSize(mobile: 40, tablet: 45, desktop: 50),
            height:
                ResponsiveUtil.iconSize(mobile: 40, tablet: 45, desktop: 50),
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: EdgeInsets.all(
                ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveUtil.iconSize(
                      mobile: 48, tablet: 56, desktop: 64),
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Error loading offers",
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 16, tablet: 18, desktop: 20),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () {
                    ref.read(offerProvider.notifier).fetchOffers();
                  },
                  child: Text(
                    "Retry",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOffers(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size:
                  ResponsiveUtil.iconSize(mobile: 80, tablet: 90, desktop: 100),
              color: theme.dividerColor,
            ),
            SizedBox(height: 16.h),
            Text(
              "No offers available",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Check back later for special deals and discounts!",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppConstants.textSecondaryColor,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersGrid(BuildContext context, List<Offer> offers) {
    return ListView(
      padding: EdgeInsets.all(
          ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
      children: [
        // Featured offers section (using active offers as featured)
        if (offers.any((offer) => offer.isActive)) ...[
          Text(
            "Featured Offers",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 20, tablet: 22, desktop: 24),
                ),
          ),
          SizedBox(height: 16.h),

          // Featured offers carousel
          SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 180, tablet: 200, desktop: 220),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: offers.where((offer) => offer.isActive).length,
              itemBuilder: (context, index) {
                final offer = offers.where((o) => o.isActive).toList()[index];
                return Container(
                  width: MediaQuery.of(context).size.width *
                      (ResponsiveUtil.isDesktop(context)
                          ? 0.4
                          : ResponsiveUtil.isTablet(context)
                              ? 0.6
                              : 0.8),
                  margin: EdgeInsets.only(right: 16.w),
                  child: OfferCard(
                    offer: offer,
                    onTap: () => _navigateToOffer(context, offer),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // All offers section
        Text(
          "All Offers",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
        ),
        SizedBox(height: 16.h),

        // Grid of all offers
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtil.isDesktop(context)
                ? 4
                : ResponsiveUtil.isTablet(context)
                    ? 3
                    : 2,
            childAspectRatio: ResponsiveUtil.isDesktop(context)
                ? 0.8
                : ResponsiveUtil.isTablet(context)
                    ? 0.77
                    : 0.65,

            crossAxisSpacing:
                ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20),
            mainAxisSpacing:
                ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20),
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
      borderRadius: BorderRadius.circular(
          ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(
              ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16)),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveUtil.spacing(
                    mobile: 12, tablet: 14, desktop: 16)),
                topRight: Radius.circular(ResponsiveUtil.spacing(
                    mobile: 12, tablet: 14, desktop: 16)),
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
                            size: ResponsiveUtil.iconSize(
                                mobile: 32, tablet: 36, desktop: 40),
                          ),
                        ),
                      ),
                    ),

                    // Discount badge
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor,
                          borderRadius: BorderRadius.circular(
                              ResponsiveUtil.spacing(
                                  mobile: 8, tablet: 9, desktop: 10)),
                        ),
                        child: Text(
                          offer.type == OfferType.percentage &&
                                  offer.discountPercentage != null
                              ? '${offer.discountPercentage!.toInt()}% OFF'
                              : offer.discountAmount != null
                                  ? '\$${offer.discountAmount!.toInt()} OFF'
                                  : 'SPECIAL OFFER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 10, tablet: 11, desktop: 12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Expiry tag
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(
                              ResponsiveUtil.spacing(
                                  mobile: 8, tablet: 9, desktop: 10)),
                        ),
                        child: Text(
                          _getExpiryText(offer.endDate),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 9, tablet: 10, desktop: 11),
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
              padding: EdgeInsets.all(
                  ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    offer.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Description
                  Text(
                    offer.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 12, tablet: 13, desktop: 14),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // SizedBox(height: 8.h),
                  //
                  // // Apply button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () => _navigateToOffer(context, offer),
                  //     style: ElevatedButton.styleFrom(
                  //       padding: EdgeInsets.symmetric(
                  //         vertical: 8.h,
                  //       ),
                  //     ),
                  //     child: Text(
                  //       "Shop Now",
                  //       style: TextStyle(
                  //         fontSize: ResponsiveUtil.fontSize(
                  //             mobile: 12, tablet: 13, desktop: 14),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOffer(BuildContext context, Offer offer) {
    // For now, just show a snackbar. In a real app, this would navigate to
    // a product list screen filtered by the offer criteria
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Opening ${offer.title} products",
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
          ),
        ),
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
