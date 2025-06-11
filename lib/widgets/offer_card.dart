import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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



    // Regular size offer card for carousel
    return InkWell(
      onTap: onTap ?? () {
        // Navigate to offer details or apply discount
      },
      child:         Container(
        width: double.infinity,
         height: 180.h,
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
          fit: StackFit.expand,
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: CachedNetworkImage(
                imageUrl: offer.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180.h,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.error),
                ),
              ),
            ),

            Padding(
              padding:  EdgeInsets.all(18.0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Discount badge
                  Container(
                    padding:  EdgeInsets.symmetric(
                      horizontal: 8.0.w,
                      vertical: 4.0.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      offer.type == OfferType.percentage &&
                          offer.discountPercentage != null
                          ? '${offer.discountPercentage!.toInt()}% OFF'
                          : offer.discountAmount != null
                          ? '\$${offer.discountAmount!.toInt()} OFF'
                          : 'SPECIAL OFFER',
                      style:  TextStyle(
                        color: Colors.white,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Title
                  Text(
                    offer.title,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 20.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    offer.description,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 12.0.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Expiry tag
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                padding:  EdgeInsets.symmetric(
                  horizontal: 8.0.w,
                  vertical: 4.0.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Text(
                  'Ends in ${_getRemainingDays(offer.endDate)} days',
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: 10.0.sp,
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
