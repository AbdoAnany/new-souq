import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../utils/responsive_util.dart';
import '../../../../utils/validator.dart';
import '../blocs/auth_bloc.dart';

/// BLoC-integrated login screen
class BlocLoginScreen extends StatefulWidget {
  const BlocLoginScreen({super.key});

  @override
  State<BlocLoginScreen> createState() => _BlocLoginScreenState();
}

class _BlocLoginScreenState extends State<BlocLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@souq.com');
  final _passwordController = TextEditingController(text: 'admin123456');
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      LoginEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: ResponsiveUtil.padding(
                mobile: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingXLarge,
                ),
                tablet: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge + 8,
                  vertical: AppConstants.paddingXLarge + 8,
                ),
                desktop: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge + 16,
                  vertical: AppConstants.paddingXLarge + 16,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and welcome message
                  Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: ResponsiveUtil.spacing(
                          mobile: 80, tablet: 90, desktop: 100),
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(
                      height: ResponsiveUtil.spacing(
                          mobile: 20, tablet: 22, desktop: 24)),
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 24, tablet: 26, desktop: 28),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height: ResponsiveUtil.spacing(
                          mobile: 6, tablet: 7, desktop: 8)),
                  Text(
                    'Please sign in to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondaryColor,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height: ResponsiveUtil.spacing(
                          mobile: 32, tablet: 36, desktop: 40)),

                  // Login form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidator.validateEmail,
                          prefixIcon: const Icon(Icons.email_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 14, tablet: 15, desktop: 16)),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
                          obscureText: true,
                          validator: AppValidator.validatePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 6, tablet: 7, desktop: 8)),

                        // Remember me
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
                              'Remember Me',
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 20, tablet: 22, desktop: 24)),                        // Sign in button
                        CustomButton(
                          text: 'Sign In',
                          onPressed: _handleLogin,
                          isLoading: isLoading,
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 20, tablet: 22, desktop: 24)),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.dividerColor)),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtil.spacing(
                                      mobile: 14, tablet: 15, desktop: 16)),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: theme.dividerColor,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.dividerColor)),
                          ],
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 20, tablet: 22, desktop: 24)),

                        // Google Sign In
                        CustomButton(
                          text: 'Sign in with Google',
                          onPressed: () {
                            // TODO: Implement Google sign in
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google Sign In coming soon!'),
                              ),
                            );
                          },
                          isLoading: false,
                          isOutlined: true,
                          icon: Icons.account_circle,
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 20, tablet: 22, desktop: 24)),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to signup
                              },                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
