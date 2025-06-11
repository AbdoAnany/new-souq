import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/utils/responsive_util.dart';

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
      // Small offer card for horizontal list
      return InkWell(
        onTap: onTap ?? () {
          // Navigate to offer details or apply discount
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          width: ResponsiveUtil.spacing(mobile: 200, tablet: 220, desktop: 250),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: CachedNetworkImage(
              imageUrl: offer.imageUrl,
              fit: BoxFit.cover,
              height: ResponsiveUtil.spacing(mobile: 100, tablet: 110, desktop: 130),
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                color: theme.primaryColor.withOpacity(0.2),
                child: const Icon(Icons.error),
              ),
            ),
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
        // Specify explicit width instead of infinity
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtil.spacing(mobile: 450, tablet: 500, desktop: 550),
        ),
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
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.primaryColor.withOpacity(0.2),
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),

            // Offer content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    offer.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(mobile: 18, tablet: 20, desktop: 22),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  if (offer.description != null && offer.description!.isNotEmpty)
                    Text(
                      offer.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: ResponsiveUtil.fontSize(mobile: 14, tablet: 16, desktop: 18),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Discount badge
            if (offer.discountPercentage != null && offer.discountPercentage! > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "${offer.discountPercentage}% OFF",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(mobile: 12, tablet: 13, desktop: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
