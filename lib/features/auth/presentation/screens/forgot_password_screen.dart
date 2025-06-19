import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../utils/responsive_util.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../utils/validator.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement forgot password logic with AuthBloc
      // For now, just show success state
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.spacing(
              mobile: AppConstants.paddingLarge,
              tablet: AppConstants.paddingLarge + 8,
              desktop: AppConstants.paddingLarge + 16,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ResponsiveUtil.spacing(
                mobile: 60,
                tablet: 80,
                desktop: 100,
              )),

              // Content based on state
              _emailSent 
                  ? _buildSuccessContent(context, theme)
                  : _buildFormContent(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(context, theme),

        SizedBox(height: ResponsiveUtil.spacing(
          mobile: 40,
          tablet: 50,
          desktop: 60,
        )),

        // Reset Form
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: AppValidator.validateEmail,
                  onSubmitted: (_) => _handleResetPassword(),
                ),

                const SizedBox(height: 32),

                // Reset Button
                CustomButton(
                  text: 'Reset Password',
                  onPressed: _handleResetPassword,
                ),

                const SizedBox(height: 20),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to Login',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Container(
          width: ResponsiveUtil.spacing(
            mobile: 120,
            tablet: 140,
            desktop: 160,
          ),
          height: ResponsiveUtil.spacing(
            mobile: 120,
            tablet: 140,
            desktop: 160,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.mark_email_read,
            size: ResponsiveUtil.iconSize(
              mobile: 60,
              tablet: 70,
              desktop: 80,
            ),
            color: Colors.green,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Check Your Email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'We\'ve sent a password reset link to',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          _emailController.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        AppCard(
          child: Column(
            children: [
              Text(
                'Didn\'t receive the email?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: theme.colorScheme.outline,
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Check your spam folder')),
                      );
                    },
                    child: const Text('Check Spam'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Back to Login
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Reset Password Icon
        Container(
          width: ResponsiveUtil.spacing(
            mobile: 100,
            tablet: 120,
            desktop: 140,
          ),
          height: ResponsiveUtil.spacing(
            mobile: 100,
            tablet: 120,
            desktop: 140,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.lock_reset,
            size: ResponsiveUtil.iconSize(
              mobile: 50,
              tablet: 60,
              desktop: 70,
            ),
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Reset Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Enter your email to reset your password',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtil.fontSize(
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
}
