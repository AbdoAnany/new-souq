import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/core/import_core.dart';
import 'package:souq/screens/search_screen.dart';
import 'package:souq/utils/responsive_util.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => _controller.forward(),
                    onTapUp: (_) {
                      _controller.reverse();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    onTapCancel: () => _controller.reverse(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorScheme.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColorScheme.dividerColor.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            // decoration: BoxDecoration(
                            //   color: AppColorScheme.primary.withOpacity(0.1),
                            //   borderRadius: BorderRadius.circular(6.r),
                            // ),
                            child: Icon(
                              Iconsax.search_normal_copy,
                              color: Colors.grey[600],
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              AppStrings.search.toLowerCase(),
                              style: AppTextTheme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[500],
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 15, tablet: 16, desktop: 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SearchScreen(showFilters: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorScheme.primary.withOpacity(0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
