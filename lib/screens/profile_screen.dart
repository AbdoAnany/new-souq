import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/wishlist_screen.dart';
import 'package:souq/screens/order_history_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'admin/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal:
              ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            _buildProfileHeader(context, ref, authState),

            // Account Settings Section
            _buildSectionHeader(context, 'Account Settings'),
            _buildListItem(
              context: context,
              leading: Icon(
                Icons.person_outline,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Personal Information',
              onTap: () {
                // Navigate to personal info screen
              },
            ),
            _buildListItem(
              context: context,
              leading: Icon(
                Icons.location_on_outlined,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Shipping Addresses',
              onTap: () {
                // Navigate to addresses screen
              },
            ),

            _buildListItem(
              context: context,
              leading: Icon(
                Icons.payment,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Payment Methods',
              onTap: () {
                // Navigate to payment methods screen
              },
            ),

            _buildListItem(
              context: context,
              leading: Icon(
                Icons.favorite_border,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'My Wishlist',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WishlistScreen()),
                );
              },
            ),

            _buildListItem(
              context: context,
              leading: Icon(
                Icons.shopping_bag_outlined,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Order History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),

            // App Settings Section
            _buildSectionHeader(context, 'App Settings'),
            _buildListItem(
              context: context,
              leading: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Dark Mode',
              trailing: Switch(
                value: isDark,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  // TODO: Create and use proper theme provider
                  // ref.read(themeModeNotifierProvider.notifier).toggleTheme();
                },
              ),
              onTap: () {
                // TODO: Create and use proper theme provider
                // ref.read(themeModeNotifierProvider.notifier).toggleTheme();
              },
            ),
            _buildListItem(
              context: context,
              leading: Icon(
                Icons.language,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Language',
              trailing: DropdownButton<String>(
                value: 'en', // TODO: Get from proper locale provider
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                  color: theme.textTheme.bodyMedium?.color,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(
                      'English',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'ar',
                    child: Text(
                      'العربية',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    // TODO: Create and use proper locale provider
                    // ref.read(localeNotifierProvider.notifier).changeLocale(value);
                  }
                },
              ),
              onTap: () {
                // No additional action needed as dropdown handles it
              },
            ),
            _buildListItem(
              context: context,
              leading: Icon(
                Icons.notifications_outlined,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Notifications',
              trailing: Switch(
                value:
                    true, // This would be from a notifications settings provider
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  // Toggle notifications
                },
              ),
              onTap: () {
                // Navigate to notification settings
              },
            ),

            // Support Section
            _buildSectionHeader(context, 'Support'),
            _buildListItem(
              context: context,
              leading: Icon(
                Icons.help_outline,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Help Center',
              onTap: () {
                // Navigate to help center
              },
            ),

            _buildListItem(
              context: context,
              leading: Icon(
                Icons.policy_outlined,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Privacy Policy',
              onTap: () {
                // Show privacy policy
              },
            ),

            _buildListItem(
              context: context,
              leading: Icon(
                Icons.description_outlined,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'Terms & Conditions',
              onTap: () {
                // Show terms and conditions
              },
            ), _buildListItem(
              context: context,
              leading: Icon(
                Icons.description_outlined,
                size: ResponsiveUtil.iconSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
              title: 'dashboard',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()),
                );

              },
            ),

            // Sign Out Button
            Padding(
              padding: EdgeInsets.all(
                  ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
              child: ElevatedButton(
                onPressed: authState.value != null
                    ? () {
                        ref.read(authProvider.notifier).signOut();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  authState.value != null ? 'Sign Out' : 'Sign In',
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 16, tablet: 18, desktop: 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // App Version
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 12, tablet: 13, desktop: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, WidgetRef ref, AsyncValue<User?> authState) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
          ResponsiveUtil.spacing(mobile: 20, tablet: 24, desktop: 28)),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: authState.when(
        data: (user) {
          if (user == null) {
            return Column(
              children: [
                CircleAvatar(
                  radius: ResponsiveUtil.iconSize(
                      mobile: 40, tablet: 45, desktop: 50),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: ResponsiveUtil.iconSize(
                        mobile: 40, tablet: 45, desktop: 50),
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Guest User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 20, tablet: 22, desktop: 24),
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to login screen
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: ResponsiveUtil.iconSize(
                    mobile: 40, tablet: 45, desktop: 50),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: user.profileImageUrl != null
                    ? CachedNetworkImageProvider(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : '',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 24, tablet: 28, desktop: 32),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 18, tablet: 20, desktop: 22),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      user.phoneNumber ?? 'No phone number',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: ResponsiveUtil.iconSize(
                      mobile: 20, tablet: 22, desktop: 24),
                ),
                onPressed: () {
                  // Navigate to edit profile
                },
              ),
            ],
          );
        },
        loading: () => Center(
          child: SizedBox(
            width: ResponsiveUtil.iconSize(mobile: 40, tablet: 45, desktop: 50),
            height:
                ResponsiveUtil.iconSize(mobile: 40, tablet: 45, desktop: 50),
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => Center(
          child: Text(
            'Failed to load profile',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontSize:
              ResponsiveUtil.fontSize(mobile: 16, tablet: 18, desktop: 20),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 4.h,
      ),
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize:
              ResponsiveUtil.fontSize(mobile: 16, tablet: 17, desktop: 18),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            size: ResponsiveUtil.iconSize(mobile: 20, tablet: 22, desktop: 24),
          ),
      onTap: onTap,
    );
  }
}
