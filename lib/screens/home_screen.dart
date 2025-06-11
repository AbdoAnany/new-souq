import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/screens/cart_screen.dart';
import 'package:souq/screens/categories_screen.dart';
import 'package:souq/screens/home/home_tab.dart';
import 'package:souq/screens/profile_screen.dart';
import 'package:souq/screens/search_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/core/widgets/badge.dart' as custom_badge;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const CategoriesScreen(),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.value?.items.length ?? 0;

    return Scaffold(
      body: ResponsiveUtil.isWeb(context)
          ? _buildDesktopLayout(cartItemCount)
          : _buildMobileLayout(cartItemCount),
      bottomNavigationBar: ResponsiveUtil.isMobile(context)
          ? _buildBottomNavigationBar(cartItemCount)
          : null,
    );
  }

  Widget _buildMobileLayout(int cartItemCount) {
    return _tabs[_currentIndex];
  }

  Widget _buildDesktopLayout(int cartItemCount) {
    return Row(
      children: [
        // Side navigation for desktop/tablet
        Container(
          width: ResponsiveUtil.spacing(mobile: 180, tablet: 200, desktop: 220),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius:
                    ResponsiveUtil.spacing(mobile: 8, tablet: 10, desktop: 12),
                offset: Offset(
                    ResponsiveUtil.spacing(mobile: 1, tablet: 2, desktop: 3),
                    0),
              ),
            ],
          ),
          child: _buildSideNavigation(cartItemCount),
        ),
        // Main content
        Expanded(
          child: _tabs[_currentIndex],
        ),
      ],
    );
  }

  Widget _buildSideNavigation(int cartItemCount) {
    return Column(
      children: [
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 50, tablet: 60, desktop: 70)),
        // App Logo/Title
        Padding(
          padding: ResponsiveUtil.padding(
            mobile: const EdgeInsets.all(14),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(18),
          ),
          child: Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 22, tablet: 24, desktop: 26),
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 18, tablet: 20, desktop: 22)),
        // Navigation Items
        Expanded(
          child: ListView(
            children: [
              _buildSideNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: AppStrings.home,
                index: 0,
              ),
              _buildSideNavItem(
                icon: Icons.category_outlined,
                activeIcon: Icons.category,
                label: AppStrings.categories,
                index: 1,
              ),
              _buildSideNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: AppStrings.search,
                index: 2,
              ),
              _buildSideNavItem(
                icon: Icons.shopping_cart_outlined,
                activeIcon: Icons.shopping_cart,
                label: AppStrings.cart,
                index: 3,
                badgeCount: cartItemCount,
              ),
              _buildSideNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: AppStrings.profile,
                index: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return Container(
      margin: ResponsiveUtil.padding(
        mobile: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        tablet: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        desktop: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      ),
      child: ListTile(
        leading: badgeCount != null && badgeCount > 0
            ? custom_badge.Badge(
                value: badgeCount.toString(),
                isVisible: badgeCount > 0,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppConstants.primaryColor : Colors.grey,
                  size: ResponsiveUtil.iconSize(
                      mobile: 22, tablet: 24, desktop: 26),
                ),
              )
            : Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppConstants.primaryColor : Colors.grey,
                size: ResponsiveUtil.iconSize(
                    mobile: 22, tablet: 24, desktop: 26),
              ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppConstants.primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize:
                ResponsiveUtil.fontSize(mobile: 13, tablet: 14, desktop: 15),
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppConstants.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              ResponsiveUtil.spacing(mobile: 6, tablet: 8, desktop: 10)),
        ),
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(int cartItemCount) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedFontSize:
          ResponsiveUtil.fontSize(mobile: 11, tablet: 12, desktop: 13),
      unselectedFontSize:
          ResponsiveUtil.fontSize(mobile: 9, tablet: 10, desktop: 11),
      iconSize: ResponsiveUtil.iconSize(mobile: 22, tablet: 24, desktop: 26),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: AppStrings.categories,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: AppStrings.search,
        ),
        BottomNavigationBarItem(
          icon: custom_badge.Badge(
            value: cartItemCount.toString(),
            isVisible: cartItemCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          activeIcon: custom_badge.Badge(
            value: cartItemCount.toString(),
            isVisible: cartItemCount > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: AppStrings.cart,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}
