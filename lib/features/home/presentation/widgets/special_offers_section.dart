import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:souq/core/import_core.dart';
import 'package:souq/core/widgets/offer_card.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/offers_screen.dart';
import 'package:souq/utils/responsive_util.dart';

class SpecialOffersSection extends ConsumerStatefulWidget {
  const SpecialOffersSection({super.key});

  @override
  ConsumerState<SpecialOffersSection> createState() =>
      _SpecialOffersSectionState();
}

class _SpecialOffersSectionState extends ConsumerState<SpecialOffersSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offersState = ref.watch(offerProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Section Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 4.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: AppColorScheme.primary,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Special Offers",
                                        style: AppTextTheme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ResponsiveUtil.fontSize(
                                              mobile: 20,
                                              tablet: 22,
                                              desktop: 24),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.local_fire_department,
                                              color: Colors.red,
                                              size: 12.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              "HOT",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Limited time deals",
                                    style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 14, tablet: 15, desktop: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OffersScreen(),
                              ),
                            );
                          },
                          // style: TextButton.styleFrom(
                          //   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          // ),
                          child: Text(
                            "See All",
                            style: TextStyle(
                              color: AppColorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveUtil.fontSize(
                                  mobile: 12, tablet: 13, desktop: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Offers List
                offersState.when(
                  loading: () => _buildShimmerLoader(),
                  error: (error, stackTrace) => _buildErrorWidget(),
                  data: (offers) {
                    if (offers.isEmpty) {
                      return _buildEmptyState();
                    }

                    return SizedBox(
                      height: ResponsiveUtil.spacing(
                          mobile: 140, tablet: 160, desktop: 180),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            duration:
                                Duration(milliseconds: 300 + (index * 100)),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Opacity(
                                  opacity: value,
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    child: OfferCard(
                                      offer: offers[index],
                                      isSmall: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return SizedBox(
      height: ResponsiveUtil.spacing(mobile: 140, tablet: 160, desktop: 180),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width:
                ResponsiveUtil.spacing(mobile: 220, tablet: 240, desktop: 260),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 140, tablet: 160, desktop: 180),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColorScheme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorScheme.dividerColor.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size:
                  ResponsiveUtil.fontSize(mobile: 40, tablet: 48, desktop: 56),
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              "No special offers available right now",
              style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 16, desktop: 18),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 140, tablet: 160, desktop: 180),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size:
                  ResponsiveUtil.fontSize(mobile: 28, tablet: 32, desktop: 36),
            ),
            SizedBox(height: 8.h),
            Text(
              "Failed to load offers",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 16, desktop: 18),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                ref.read(offerProvider.notifier).fetchOffers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
