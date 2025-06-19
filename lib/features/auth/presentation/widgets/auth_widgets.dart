import 'package:flutter/material.dart';
import '../../../../utils/responsive_util.dart';
import '../../../../core/widgets/custom_button.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool isLoading;

  const SocialAuthButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline)),
          ],
        ),

        const SizedBox(height: 24),

        // Social buttons
        if (onGooglePressed != null) ...[
          CustomButton(
            text: 'Sign in with Google',
            onPressed: isLoading ? null : onGooglePressed,
            isOutlined: true,
            color: Colors.red,
            icon: Icons.g_mobiledata,
          ),
          const SizedBox(height: 16),
        ],

        if (onApplePressed != null) ...[
          CustomButton(
            text: 'Sign in with Apple',
            onPressed: isLoading ? null : onApplePressed,
            isOutlined: true,
            color: Colors.black,
            icon: Icons.apple,
          ),
          const SizedBox(height: 16),
        ],

        if (onFacebookPressed != null) ...[
          CustomButton(
            text: 'Sign in with Facebook',
            onPressed: isLoading ? null : onFacebookPressed,
            isOutlined: true,
            color: const Color(0xFF1877F2),
            icon: Icons.facebook,
          ),
        ],
      ],
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (icon != null) ...[
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
              icon,
              size: ResponsiveUtil.spacing(
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
        ],

        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtil.spacing(
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtil.spacing(
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

class AuthBottomNav extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onActionPressed;

  const AuthBottomNav({
    super.key,
    required this.text,
    required this.actionText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _calculateStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength',
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              _getStrengthText(strength),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStrengthColor(strength),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: _getStrengthColor(strength),
        ),

        const SizedBox(height: 12),

        // Password requirements
        _buildRequirement(
          'At least 8 characters',
          password.length >= 8,
          theme,
        ),
        _buildRequirement(
          'Contains uppercase letter',
          password.contains(RegExp(r'[A-Z]')),
          theme,
        ),
        _buildRequirement(
          'Contains lowercase letter',
          password.contains(RegExp(r'[a-z]')),
          theme,
        ),
        _buildRequirement(
          'Contains number',
          password.contains(RegExp(r'[0-9]')),
          theme,
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool met, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: met ? Colors.green : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: met ? Colors.green : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    
    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
