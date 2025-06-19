import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
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
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              _getStrengthText(strength),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStrengthColor(strength),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength / 4,
            minHeight: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: _getStrengthColor(strength),
          ),
        ),

        if (showRequirements && password.isNotEmpty) ...[
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
          _buildRequirement(
            'Contains special character',
            password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
            theme,
          ),
        ],
      ],
    );
  }

  Widget _buildRequirement(String text, bool met, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              met ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: met 
                  ? Colors.green 
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.bodySmall!.copyWith(
                color: met 
                    ? Colors.green 
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontWeight: met ? FontWeight.w500 : FontWeight.normal,
              ),
              child: Text(text),
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
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength.clamp(0, 4);
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
