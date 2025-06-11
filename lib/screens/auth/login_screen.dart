import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/auth/forgot_password_screen.dart';
import 'package:souq/screens/auth/signup_screen.dart';
import 'package:souq/screens/home_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/utils/validator.dart';
import '/core/widgets/custom_button.dart';
import '/core/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@souq.com');
  final _passwordController = TextEditingController(text: 'admin123456');
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!mounted) return;

      // Navigate to home screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return;

      // Navigate to home screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  Icons.adb, // Replace with your app logo
                  size: ResponsiveUtil.spacing(
                      mobile: 80, tablet: 90, desktop: 100),
                ),
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 20, tablet: 22, desktop: 24)),
              Text(
                AppStrings.signIn,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 24, tablet: 26, desktop: 28),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height:
                      ResponsiveUtil.spacing(mobile: 6, tablet: 7, desktop: 8)),
              Text(
                'Welcome back! Please sign in to continue',
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

              // Error message if any
              if (_errorMessage != null) ...[
                Container(
                  padding: ResponsiveUtil.padding(
                    mobile: const EdgeInsets.all(AppConstants.paddingMedium),
                    tablet:
                        const EdgeInsets.all(AppConstants.paddingMedium + 2),
                    desktop:
                        const EdgeInsets.all(AppConstants.paddingMedium + 4),
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveUtil.spacing(
                        mobile: 8, tablet: 9, desktop: 10)),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
                SizedBox(
                    height: ResponsiveUtil.spacing(
                        mobile: 14, tablet: 15, desktop: 16)),
              ],

              // Login form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: AppStrings.email,
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
                      label: AppStrings.password,
                      hintText: 'Enter your password',
                      obscureText: true,
                      validator: AppValidator.validatePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signInWithEmailAndPassword(),
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                            mobile: 6, tablet: 7, desktop: 8)),

                    // Remember me and forgot password
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.forgotPassword,
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
                            mobile: 20, tablet: 22, desktop: 24)),

                    // Sign in button
                    CustomButton(
                      text: AppStrings.signIn,
                      onPressed: _signInWithEmailAndPassword,
                      isLoading: _isLoading,
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
                      text: AppStrings.signInWithGoogle,
                      onPressed: _signInWithGoogle,
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
                          AppStrings.dontHaveAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.signUp,
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
        ),
      ),
    );
  }
}
