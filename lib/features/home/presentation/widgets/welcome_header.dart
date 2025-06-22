import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/core/themes/style/color_schemes.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/utils/responsive_util.dart';
import '/core/import_core.dart';

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final userName = user != null ? user.firstName : "Guest";

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $userName! 👋",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColorScheme.textPrimary,
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 24, tablet: 28, desktop: 32),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "What are you looking for today?",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 14, tablet: 16, desktop: 18),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: theme.primaryColor,
              size:
                  ResponsiveUtil.iconSize(mobile: 28, tablet: 32, desktop: 36),
            ),
          ),
        ],
      ),
    );
  }
}
