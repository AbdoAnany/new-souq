import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:souq/core/widgets/offer_card.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:shimmer/shimmer.dart';

class OfferCarousel extends ConsumerStatefulWidget {
  const OfferCarousel({super.key});

  @override
  ConsumerState<OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends ConsumerState<OfferCarousel>
    with TickerProviderStateMixin {
  int _currentCarouselSlide = 0;
  final carousel_slider.CarouselSliderController _carouselController =
      carousel_slider.CarouselSliderController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offersState = ref.watch(offerProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: offersState.when(
              loading: () => _buildShimmerLoader(),
              error: (error, stackTrace) => _buildErrorWidget(theme),
              data: (offers) {
                if (offers.isEmpty) {
                  return _buildPlaceholderBanner(theme);
                }

                return Column(
                  children: [
                    carousel_slider.CarouselSlider(
                      carouselController: _carouselController,
                      options: carousel_slider.CarouselOptions(
                        height: ResponsiveUtil.spacing(
                            mobile: 200, tablet: 240, desktop: 280),
                        viewportFraction: ResponsiveUtil.isDesktop(context)
                            ? 0.8
                            : ResponsiveUtil.isTablet(context)
                                ? 0.85
                                : 0.9,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: offers.length > 1,
                        autoPlay: offers.length > 1,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselSlide = index;
                          });
                        },
                      ),
                      items: offers.map((offer) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          child: OfferCard(offer: offer),
                        );
                      }).toList(),
                    ),
                    if (offers.length > 1)
                      _buildDotIndicators(offers.length, theme),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotIndicators(int count, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _currentCarouselSlide == index ? 24.w : 8.w,
            height: 8.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: _currentCarouselSlide == index
                  ? theme.primaryColor
                  : theme.dividerColor,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 200, tablet: 240, desktop: 280),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner(ThemeData theme) {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 200, tablet: 240, desktop: 280),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: ResponsiveUtil.fontSize(
                    mobile: 48, tablet: 56, desktop: 64),
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "No offers available",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Check back later for exciting deals!",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 16, desktop: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 200, tablet: 240, desktop: 280),
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
                  ResponsiveUtil.fontSize(mobile: 32, tablet: 36, desktop: 40),
            ),
            SizedBox(height: 12.h),
            Text(
              "Failed to load offers",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(offerProvider.notifier).fetchOffers();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
