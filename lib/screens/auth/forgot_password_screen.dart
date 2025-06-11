import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/auth/login_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/utils/validator.dart';
import '/core/widgets/custom_button.dart';
import '/core/widgets/custom_text_field.dart';

import '../../core/widgets/my_app_bar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );

      if (!mounted) return;

      // Show success state
      setState(() {
        _resetEmailSent = true;
      });
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
      appBar: MyAppBar(

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
              vertical: AppConstants.paddingLarge,
            ),
            tablet: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge + 8,
              vertical: AppConstants.paddingLarge + 8,
            ),
            desktop: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge + 16,
              vertical: AppConstants.paddingLarge + 16,
            ),
          ),
          child: _resetEmailSent
              ? _buildSuccessView(theme)
              : _buildFormView(theme),
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Icon(
          Icons.lock_reset,
          size: ResponsiveUtil.spacing(mobile: 64, tablet: 68, desktop: 72),
          color: AppConstants.primaryColor,
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 20, tablet: 22, desktop: 24)),
        Text(
          AppStrings.resetPassword,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize:
                ResponsiveUtil.fontSize(mobile: 24, tablet: 26, desktop: 28),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 14, tablet: 15, desktop: 16)),
        Text(
          'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstants.textSecondaryColor,
            fontSize:
                ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 28, tablet: 30, desktop: 32)),

        // Error message if any
        if (_errorMessage != null) ...[
          Container(
            padding: ResponsiveUtil.padding(
              mobile: const EdgeInsets.all(AppConstants.paddingMedium),
              tablet: const EdgeInsets.all(AppConstants.paddingMedium + 2),
              desktop: const EdgeInsets.all(AppConstants.paddingMedium + 4),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  ResponsiveUtil.spacing(mobile: 8, tablet: 9, desktop: 10)),
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
              height:
                  ResponsiveUtil.spacing(mobile: 14, tablet: 15, desktop: 16)),
        ],

        // Form
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
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _resetPassword(),
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 28, tablet: 30, desktop: 32)),

              // Reset button
              CustomButton(
                text: AppStrings.resetPassword,
                onPressed: _resetPassword,
                isLoading: _isLoading,
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 20, tablet: 22, desktop: 24)),

              // Back to login
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to login',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.mark_email_read,
          size: ResponsiveUtil.spacing(mobile: 72, tablet: 76, desktop: 80),
          color: Colors.green,
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 20, tablet: 22, desktop: 24)),
        Text(
          'Password Reset Email Sent',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize:
                ResponsiveUtil.fontSize(mobile: 24, tablet: 26, desktop: 28),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 14, tablet: 15, desktop: 16)),
        Padding(
          padding: ResponsiveUtil.padding(
            mobile: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge),
            tablet: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge + 8),
            desktop: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge + 16),
          ),
          child: Text(
            'We\'ve sent a password reset link to ${_emailController.text}. Please check your email inbox.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 14, tablet: 15, desktop: 16)),
        Text(
          'If you don\'t receive the email within a few minutes, please check your spam folder.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppConstants.textSecondaryColor,
            fontSize:
                ResponsiveUtil.fontSize(mobile: 13, tablet: 14, desktop: 15),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height:
                ResponsiveUtil.spacing(mobile: 36, tablet: 38, desktop: 40)),
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          width: ResponsiveUtil.spacing(mobile: 180, tablet: 190, desktop: 200),
        ),
      ],
    );
  }
}
