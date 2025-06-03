import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/auth/login_screen.dart';
import 'package:souq/screens/home_screen.dart';
import '../utils/responsive_util.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    // Navigate after delay
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    // Add delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check authentication state
    final authState = ref.read(authProvider);

    // Navigate based on authentication state
    if (authState.hasValue && authState.value != null) {
      // User is logged in, navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // User is not logged in, navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
              AppConstants.secondaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              FadeTransition(
                opacity: _fadeInAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    Icons.adb, // Replace with your app logo
                    size: ResponsiveUtil.iconSize(
                      mobile: 80,
                      tablet: 96,
                      desktop: 112,
                    ),
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 24,
                tablet: 28,
                desktop: 32,
              )),

              // App Name
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtil.fontSize(
                      mobile: 36,
                      tablet: 42,
                      desktop: 48,
                    ),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 8,
                tablet: 10,
                desktop: 12,
              )),

              // Tag Line
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Text(
                  "Your One-Stop Shopping Destination",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtil.fontSize(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 40,
                tablet: 48,
                desktop: 56,
              )),

              // Loading indicator
              FadeTransition(
                opacity: _fadeInAnimation,
                child: SizedBox(
                  width: ResponsiveUtil.spacing(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                  height: ResponsiveUtil.spacing(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
