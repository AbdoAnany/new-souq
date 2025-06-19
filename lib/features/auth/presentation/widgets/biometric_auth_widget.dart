import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool showAsButton;

  const BiometricAuthWidget({
    super.key,
    this.onSuccess,
    this.onError,
    this.showAsButton = true,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget> {
  bool _isBiometricSupported = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      // For now, assume biometric is not supported until local_auth package is added
      if (mounted) {
        setState(() {
          _isBiometricSupported = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricSupported = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_isBiometricSupported || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      // TODO: Implement actual biometric authentication when local_auth is added
      // For now, just simulate success after a delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } on PlatformException catch (e) {
      if (widget.onError != null) {
        widget.onError!(e.message ?? 'Biometric authentication failed');
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // For now, don't show biometric widget until local_auth is properly configured
    return const SizedBox.shrink();
  }
}
