import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/screens/auth/login_screen.dart';
import 'package:souq/utils/validator.dart';
import 'package:souq/widgets/custom_button.dart';
import 'package:souq/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: theme.iconTheme.color,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingLarge,
          ),
          child: _resetEmailSent ? _buildSuccessView(theme) : _buildFormView(theme),
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Icon(
          Icons.lock_reset,
          size: 72.0,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(height: 24.0),
        Text(
          AppStrings.resetPassword,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        Text(
          'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32.0),
        
        // Error message if any
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(color: theme.colorScheme.error),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: 16.0),
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
              const SizedBox(height: 32.0),
              
              // Reset button
              CustomButton(
                text: AppStrings.resetPassword,
                onPressed: _resetPassword,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24.0),
              
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
        const Icon(
          Icons.mark_email_read,
          size: 80.0,
          color: Colors.green,
        ),
        const SizedBox(height: 24.0),
        Text(
          'Password Reset Email Sent',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
          child: Text(
            'We\'ve sent a password reset link to ${_emailController.text}. Please check your email inbox.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'If you don\'t receive the email within a few minutes, please check your spam folder.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40.0),
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          width: 200.0,
        ),
      ],
    );
  }
}
