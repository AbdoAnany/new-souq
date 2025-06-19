import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../utils/validator.dart';
import '../blocs/auth_bloc.dart';
import 'auth_widgets.dart';
import 'password_strength_indicator.dart' as pwd;

enum AuthFormType { login, signup, forgotPassword }

class AuthForm extends StatefulWidget {
  final AuthFormType type;
  final VoidCallback? onSuccess;
  final VoidCallback? onSwitchToLogin;
  final VoidCallback? onSwitchToSignup;
  final VoidCallback? onSwitchToForgotPassword;

  const AuthForm({
    super.key,
    required this.type,
    this.onSuccess,
    this.onSwitchToLogin,
    this.onSwitchToSignup,
    this.onSwitchToForgotPassword,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _acceptTerms = false;
  bool _showPasswordStrength = false;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    switch (widget.type) {
      case AuthFormType.login:
        _handleLogin();
        break;
      case AuthFormType.signup:
        _handleSignup();
        break;
      case AuthFormType.forgotPassword:
        _handleForgotPassword();
        break;
    }
  }

  void _handleLogin() {
    context.read<AuthBloc>().add(
      LoginEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleSignup() {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      RegisterEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      ),
    );
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password with AuthBloc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent!')),
    );
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign In coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._buildFormFields(context, theme),
                
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: _getSubmitButtonText(),
                      onPressed: _handleSubmit,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),

                ..._buildAdditionalUI(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(BuildContext context, ThemeData theme) {
    switch (widget.type) {
      case AuthFormType.login:
        return _buildLoginFields(context, theme);
      case AuthFormType.signup:
        return _buildSignupFields(context, theme);
      case AuthFormType.forgotPassword:
        return _buildForgotPasswordFields(context, theme);
    }
  }

  List<Widget> _buildLoginFields(BuildContext context, ThemeData theme) {
    return [
      // Email Field
      CustomTextField(
        controller: _emailController,
        label: 'Email',
        hintText: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(Icons.email_outlined),
        validator: AppValidator.validateEmail,
      ),

      const SizedBox(height: 20),

      // Password Field
      CustomTextField(
        controller: _passwordController,
        label: 'Password',
        hintText: 'Enter your password',
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        validator: AppValidator.validatePassword,
        onSubmitted: (_) => _handleSubmit(),
      ),

      const SizedBox(height: 16),

      // Remember Me & Forgot Password
      Row(
        children: [
          Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
          ),
          Text(
            'Remember me',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onSwitchToForgotPassword,
            child: const Text('Forgot Password?'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSignupFields(BuildContext context, ThemeData theme) {
    return [
      // Name Fields
      Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _firstNameController,
              label: 'First Name',
              hintText: 'Enter first name',
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.person_outline),
              validator: AppValidator.validateName,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomTextField(
              controller: _lastNameController,
              label: 'Last Name',
              hintText: 'Enter last name',
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.person_outline),
              validator: AppValidator.validateName,
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      // Email Field
      CustomTextField(
        controller: _emailController,
        label: 'Email',
        hintText: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(Icons.email_outlined),
        validator: AppValidator.validateEmail,
      ),

      const SizedBox(height: 20),

      // Phone Field (Optional)
      CustomTextField(
        controller: _phoneController,
        label: 'Phone Number (Optional)',
        hintText: 'Enter phone number',
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(Icons.phone_outlined),
      ),

      const SizedBox(height: 20),

      // Password Field
      CustomTextField(
        controller: _passwordController,
        label: 'Password',
        hintText: 'Enter your password',
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        validator: AppValidator.validatePassword,
        onChanged: (value) {
          setState(() {
            _showPasswordStrength = value.isNotEmpty;
          });
        },
      ),

      if (_showPasswordStrength) ...[
        const SizedBox(height: 16),
        pwd.PasswordStrengthIndicator(
          password: _passwordController.text,
        ),
      ],

      const SizedBox(height: 20),

      // Confirm Password Field
      CustomTextField(
        controller: _confirmPasswordController,
        label: 'Confirm Password',
        hintText: 'Confirm your password',
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        validator: (value) => AppValidator.validateConfirmPassword(
          value,
          _passwordController.text,
        ),
        onSubmitted: (_) => _handleSubmit(),
      ),

      const SizedBox(height: 20),

      // Terms and Conditions
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _acceptTerms = !_acceptTerms;
                });
              },
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildForgotPasswordFields(BuildContext context, ThemeData theme) {
    return [
      // Email Field
      CustomTextField(
        controller: _emailController,
        label: 'Email',
        hintText: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        prefixIcon: const Icon(Icons.email_outlined),
        validator: AppValidator.validateEmail,
        onSubmitted: (_) => _handleSubmit(),
      ),
    ];
  }

  List<Widget> _buildAdditionalUI(BuildContext context, ThemeData theme) {
    if (widget.type == AuthFormType.forgotPassword) {
      return [
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: widget.onSwitchToLogin,
            child: const Text('Back to Login'),
          ),
        ),
      ];
    }

    return [
      const SizedBox(height: 24),

      // Social Authentication (only for login/signup)
      SocialAuthButtons(
        onGooglePressed: _handleGoogleSignIn,
      ),

      const SizedBox(height: 24),

      // Bottom navigation
      _buildBottomNavigation(context, theme),
    ];
  }

  Widget _buildBottomNavigation(BuildContext context, ThemeData theme) {
    switch (widget.type) {
      case AuthFormType.login:
        return AuthBottomNav(
          text: 'Don\'t have an account?',
          actionText: 'Sign Up',
          onActionPressed: widget.onSwitchToSignup ?? () {},
        );
      case AuthFormType.signup:
        return AuthBottomNav(
          text: 'Already have an account?',
          actionText: 'Sign In',
          onActionPressed: widget.onSwitchToLogin ?? () {},
        );
      case AuthFormType.forgotPassword:
        return const SizedBox.shrink();
    }
  }

  String _getSubmitButtonText() {
    switch (widget.type) {
      case AuthFormType.login:
        return 'Sign In';
      case AuthFormType.signup:
        return 'Sign Up';
      case AuthFormType.forgotPassword:
        return 'Reset Password';
    }
  }
}
