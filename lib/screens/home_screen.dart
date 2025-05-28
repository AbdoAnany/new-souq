import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/cart_screen.dart';
import 'package:souq/screens/categories_screen.dart';
import 'package:souq/screens/profile_screen.dart';
import 'package:souq/screens/search_screen.dart';
import 'package:souq/screens/home/home_tab.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/widgets/badge.dart' as custom_badge;

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
    super.initState();    _tabs = [
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
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
          ),          BottomNavigationBarItem(
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
      ),
    );
  }
}
