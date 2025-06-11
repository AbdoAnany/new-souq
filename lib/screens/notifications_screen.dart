import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/utils/responsive_util.dart';

import '../core/widgets/my_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Notifications'),

      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(
              ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: ResponsiveUtil.iconSize(
                    mobile: 80, tablet: 90, desktop: 100),
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                "No notifications yet",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 18, tablet: 20, desktop: 22),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "We'll notify you when something arrives",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
