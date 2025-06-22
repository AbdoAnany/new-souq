
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:souq/core/app_config.dart';
import 'package:souq/core/utils/responsive.dart';


import '../../../home/presentation/screens/home_screen.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/auth_form.dart';
import '/core/import_core.dart';
class UnifiedAuthScreen extends StatefulWidget {
  final AuthFormType initialType;

  const UnifiedAuthScreen({
    super.key,
    this.initialType = AuthFormType.login,
  });

  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen>
    with TickerProviderStateMixin {
  late AuthFormType _currentType;
  late PageController _pageController;
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _pageController = PageController(initialPage: _getPageIndex(_currentType));
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: AppColorScheme.primary.withOpacity(0.1),
      end: AppColorScheme.secondary.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  int _getPageIndex(AuthFormType type) {
    switch (type) {
      case AuthFormType.login:
        return 0;
      case AuthFormType.signup:
        return 1;
      case AuthFormType.forgotPassword:
        return 2;
    }
  }

  void _switchToType(AuthFormType type) {
    setState(() {
      _currentType = type;
    });
    _pageController.animateToPage(
      _getPageIndex(type),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleAuthSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _handleAuthSuccess();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
              ),
            );
          }
        },
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _backgroundAnimation.value ?? AppColorScheme.primary.withOpacity(0.1),
                    AppColorScheme.surface,
                    AppColorScheme.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    _buildAppBar(context),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: Responsive.paddingHorizontal(
                          context,
                          mobile: AppDimensions.smallMargin,
                          tablet: AppDimensions.mediumPadding,
                          desktop: AppDimensions.largeMargin,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: Responsive.spacing(
                              context,
                              mobile: AppDimensions.smallMargin,
                              tablet: AppDimensions.mediumPadding,
                            )),

                            // Header
                            _buildHeader(context),

                            SizedBox(height: Responsive.spacing(
                              context,
                              mobile: AppDimensions.mediumPadding,
                              tablet: AppDimensions.largeMargin,
                            )),

                            // Auth Forms
                            _buildAuthForms(context),

                            SizedBox(height: Responsive.spacing(
                              context,
                              mobile: AppDimensions.smallMargin,
                              tablet: AppDimensions.mediumPadding,
                            )),

                            // Guest Access
                            if (_currentType == AuthFormType.login)
                              _buildGuestAccess(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,

  ) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.mediumMargin),
      child: Row(
        children: [
          // Back button (only show if not login)
          if (_currentType != AuthFormType.login)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_currentType == AuthFormType.forgotPassword) {
                  _switchToType(AuthFormType.login);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          
          const Spacer(),

          // Theme toggle
          // IconButton(
          //   icon: Icon(
          //     themeManager.isDarkMode(context)
          //         ? Icons.light_mode
          //         : Icons.dark_mode,
          //   ),
          //   onPressed: () => .toggleTheme(),
          // ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ) {
    return Column(
      children: [
        // App Logo with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Transform.rotate(
                angle: (1 - value) * 0.1,
                child: Container(
                  width: Responsive.width(
                    context,
                    mobile: 120,
                    tablet: 140,
                    desktop: 160,
                  ),
                  height: Responsive.height(
                    context,
                    mobile: 120,
                    tablet: 140,
                    desktop: 160,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorScheme.primary,
                      AppColorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color:AppColorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: Responsive.iconSize(
                      context,
                      mobile: AppDimensions.inputIconSize,
                      tablet: AppDimensions.inputIconSize + 8,
                      desktop: AppDimensions.inputIconSize + 16,
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: AppDimensions.mediumMargin),

        // App Name
        Text(
          AppConfig.instance.appName,
          style: AppTextTheme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(
              context,
              mobile: 32,
              tablet: 36,
              desktop: 40,
            ),
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  AppColorScheme.primary,
                  AppColorScheme.secondary,
                ],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),

        SizedBox(height: AppDimensions. smallMargin),

        Text(
          "l10n.tagline",
          style: AppTextTheme.textTheme.bodyLarge?.copyWith(
            color: AppColorScheme.onSurfaceVariant,
            fontSize: Responsive.fontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthForms(BuildContext context, ) {
    return SizedBox(
      height: _getFormHeight(),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Login Form
          AuthForm(
            type: AuthFormType.login,
            onSuccess: _handleAuthSuccess,
            onSwitchToSignup: () => _switchToType(AuthFormType.signup),
            onSwitchToForgotPassword: () => _switchToType(AuthFormType.forgotPassword),
          ),

          // Signup Form
          AuthForm(
            type: AuthFormType.signup,
            onSuccess: _handleAuthSuccess,
            onSwitchToLogin: () => _switchToType(AuthFormType.login),
          ),

          // Forgot Password Form
          AuthForm(
            type: AuthFormType.forgotPassword,
            onSwitchToLogin: () => _switchToType(AuthFormType.login),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestAccess(BuildContext context, ) {
    return Column(
      children: [
        Divider(
          color: AppColorScheme.outline.withOpacity(0.5),
          thickness: 1,
        ),

        SizedBox(height: AppDimensions.largeMargin),

        Text(
          "l10n.orContinueAs",
          style: AppTextTheme.textTheme.bodyMedium?.copyWith(
            color: AppColorScheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: AppDimensions.mediumMargin),

        // AppButton(
        //   text: "l10n.continueAsGuest",
        //   onPressed: () {
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => const HomeScreen(),
        //       ),
        //     );
        //   },
        //   variant: AppButtonVariant.text,
        //   icon: Icons.person_outline,
        // ),
      ],
    );
  }

  double _getFormHeight() {
    switch (_currentType) {
      case AuthFormType.login:
        return Responsive.height(context, mobile: 450, tablet: 500, desktop: 550);
      case AuthFormType.signup:
        return Responsive.height(context, mobile: 700, tablet: 750, desktop: 800);
      case AuthFormType.forgotPassword:
        return Responsive.height(context, mobile: 300, tablet: 350, desktop: 400);
    }
  }
}
