import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/wishlist_screen.dart';
import 'package:souq/screens/order_history_screen.dart';
import 'package:souq/screens/admin/admin_dashboard_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            _buildProfileHeader(context, ref, authState),
            
            // Account Settings Section
            _buildSectionHeader(context, 'Account Settings'),
              _buildListItem(
              context: context,
              leading: const Icon(Icons.person_outline),
              title: 'Personal Information',
              onTap: () {
                // Navigate to personal info screen
              },
            ),
              _buildListItem(
              context: context,
              leading: const Icon(Icons.location_on_outlined),
              title: 'Shipping Addresses',
              onTap: () {
                // Navigate to addresses screen
              },
            ),
            
            _buildListItem(
              context: context,
              leading: const Icon(Icons.payment),
              title: 'Payment Methods',
              onTap: () {
                // Navigate to payment methods screen
              },
            ),
            
            _buildListItem(
              context: context,
              leading: const Icon(Icons.favorite_border),
              title: 'My Wishlist',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                );
              },
            ),
            
            _buildListItem(
              context: context,
              leading: const Icon(Icons.shopping_bag_outlined),
              title: 'Order History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),
            
            // App Settings Section
            _buildSectionHeader(context, 'App Settings'),
              _buildListItem(
              context: context,
              leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
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
              leading: const Icon(Icons.language),
              title: 'Language',
              trailing: DropdownButton<String>(
                value: 'en', // TODO: Get from proper locale provider
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'ar',
                    child: Text('العربية'),
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
              leading: const Icon(Icons.notifications_outlined),
              title: 'Notifications',
              trailing: Switch(
                value: true, // This would be from a notifications settings provider
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
              leading: const Icon(Icons.help_outline),
              title: 'Help Center',
              onTap: () {
                // Navigate to help center
              },
            ),
            
            _buildListItem(
              context: context,
              leading: const Icon(Icons.policy_outlined),
              title: 'Privacy Policy',
              onTap: () {
                // Show privacy policy
              },
            ),
              _buildListItem(
              context: context,
              leading: const Icon(Icons.description_outlined),
              title: 'Terms & Conditions',
              onTap: () {
                // Show terms and conditions
              },
            ),
            
            // Admin Section (only visible for admin users)
            if (authState.value?.role == 'admin') ...[
              _buildSectionHeader(context, 'Admin'),
              _buildListItem(
                context: context,
                leading: const Icon(Icons.admin_panel_settings),
                title: 'Admin Dashboard',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
            ],
            
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: authState.value != null 
                    ? () {
                        ref.read(authProvider.notifier).signOut();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  authState.value != null ? 'Sign Out' : 'Sign In',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // App Version
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, AsyncValue<User?> authState) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
      ),
      child: authState.when(
        data: (user) {
          if (user == null) {
            return Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Guest User',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to login screen
                  },
                  child: const Text('Sign In'),
                ),
              ],
            );
          }
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: user.profileImageUrl != null
                    ? CachedNetworkImageProvider(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.phoneNumber ?? 'No phone number',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit profile
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Failed to load profile',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
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
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
