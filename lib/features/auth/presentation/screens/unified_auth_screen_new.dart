import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/auth_form.dart';

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

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _pageController = PageController(initialPage: _getPageIndex(_currentType));
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: _currentType != AuthFormType.login
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_currentType == AuthFormType.forgotPassword) {
                    _switchToType(AuthFormType.login);
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _handleAuthSuccess();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, theme),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Auth Forms
                      _buildAuthForms(context),

                      const SizedBox(height: 20),

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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.shopping_bag,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 16),

          // App Name
          Text(
            'Souq',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your marketplace for everything',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForms(BuildContext context) {
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

  Widget _buildGuestAccess(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Divider(
          color: theme.colorScheme.outline.withOpacity(0.5),
          thickness: 1,
        ),

        const SizedBox(height: 16),

        Text(
          'Or continue as guest',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          },
          icon: const Icon(Icons.person_outline),
          label: const Text('Continue as Guest'),
        ),
      ],
    );
  }

  double _getFormHeight() {
    switch (_currentType) {
      case AuthFormType.login:
        return 450;
      case AuthFormType.signup:
        return 700;
      case AuthFormType.forgotPassword:
        return 300;
    }
  }

  String _getAppBarTitle() {
    switch (_currentType) {
      case AuthFormType.login:
        return 'Sign In';
      case AuthFormType.signup:
        return 'Sign Up';
      case AuthFormType.forgotPassword:
        return 'Reset Password';
    }
  }
}
