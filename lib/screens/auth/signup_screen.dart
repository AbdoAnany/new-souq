import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/auth/login_screen.dart';
import 'package:souq/screens/home_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/utils/validator.dart';
import 'package:souq/widgets/custom_button.dart';
import 'package:souq/widgets/custom_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() != true) return;

    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'You must accept the terms and conditions to proceed';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signUpWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: ResponsiveUtil.spacing(mobile: 24, tablet: 26, desktop: 28),
          ),
          onPressed: () => Navigator.pop(context),
          color: theme.iconTheme.color,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtil.padding(
            mobile: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            tablet: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge + 8,
              vertical: AppConstants.paddingMedium + 4,
            ),
            desktop: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge + 16,
              vertical: AppConstants.paddingMedium + 8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.createAccount,
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
                'Please fill in the form to create your account',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondaryColor,
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 28, tablet: 30, desktop: 32)),

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

              // Registration form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // First and Last Name
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _firstNameController,
                            label: AppStrings.firstName,
                            hintText: 'Enter first name',
                            validator: AppValidator.validateName,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveUtil.spacing(
                                mobile: 14, tablet: 15, desktop: 16)),
                        Expanded(
                          child: CustomTextField(
                            controller: _lastNameController,
                            label: AppStrings.lastName,
                            hintText: 'Enter last name',
                            validator: AppValidator.validateName,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                            mobile: 14, tablet: 15, desktop: 16)),

                    // Email
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

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      hintText: 'Create a password',
                      obscureText: true,
                      validator: AppValidator.validatePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                            mobile: 14, tablet: 15, desktop: 16)),

                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      hintText: 'Confirm your password',
                      obscureText: true,
                      validator: (value) =>
                          AppValidator.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signUpWithEmailAndPassword(),
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                            mobile: 14, tablet: 15, desktop: 16)),

                    // Terms and conditions checkbox
                    Row(
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
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: ResponsiveUtil.fontSize(
                                  mobile: 13, tablet: 14, desktop: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                            mobile: 20, tablet: 22, desktop: 24)),

                    // Sign up button
                    CustomButton(
                      text: AppStrings.signUp,
                      onPressed: _signUpWithEmailAndPassword,
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

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.signIn,
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
