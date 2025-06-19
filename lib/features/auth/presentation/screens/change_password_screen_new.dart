import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../utils/responsive_util.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../utils/validator.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/password_strength_indicator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement change password with AuthBloc
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtil.spacing(
                mobile: AppConstants.paddingLarge,
                tablet: AppConstants.paddingLarge + 8,
                desktop: AppConstants.paddingLarge + 16,
              ),
              vertical: AppConstants.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ResponsiveUtil.spacing(
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                )),

                // Header
                _buildHeader(context, theme),

                SizedBox(height: ResponsiveUtil.spacing(
                  mobile: 32,
                  tablet: 36,
                  desktop: 40,
                )),

                // Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Current Password
                          CustomTextField(
                            controller: _currentPasswordController,
                            label: 'Current Password',
                            hintText: 'Enter current password',
                            obscureText: _obscureCurrentPassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword = !_obscureCurrentPassword;
                                });
                              },
                            ),
                            validator: AppValidator.validatePassword,
                          ),

                          const SizedBox(height: 20),

                          // New Password
                          CustomTextField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            hintText: 'Enter new password',
                            obscureText: _obscureNewPassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            validator: AppValidator.validatePassword,
                            onChanged: (_) => setState(() {}),
                          ),

                          if (_newPasswordController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            PasswordStrengthIndicator(
                              password: _newPasswordController.text,
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Confirm New Password
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            hintText: 'Confirm new password',
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) => AppValidator.validateConfirmPassword(
                              value,
                              _newPasswordController.text,
                            ),
                            onSubmitted: (_) => _handleChangePassword(),
                          ),

                          const SizedBox(height: 32),

                          // Change Password Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                text: 'Change Password',
                                onPressed: _handleChangePassword,
                                isLoading: state is AuthLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Security Tips Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Security Tips',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildSecurityTip(
                          'Use a strong password with mixed characters',
                          Icons.check_circle_outline,
                          theme,
                        ),
                        _buildSecurityTip(
                          'Don\'t reuse passwords from other accounts',
                          Icons.check_circle_outline,
                          theme,
                        ),
                        _buildSecurityTip(
                          'Keep your password private and secure',
                          Icons.check_circle_outline,
                          theme,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Change Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your current and new password',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSecurityTip(String text, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
