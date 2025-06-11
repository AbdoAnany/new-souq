import 'package:flutter/material.dart';
import '/core/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final buttonTextColor = textColor ?? (isOutlined ? buttonColor : Colors.white);
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 50.0;
    final buttonFontSize = fontSize ?? 16.0;
    final buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0);
    final buttonBorderRadius = borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium);

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(icon, color: buttonTextColor),
          ),
        Text(
          text,
          style: TextStyle(
            color: buttonTextColor,
            fontSize: buttonFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
            side: BorderSide(color: buttonColor),
            padding: buttonPadding,
            backgroundColor: Colors.transparent,
          ),
          child: buttonContent,
        ),
      );
    } else {
      return SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
            backgroundColor: buttonColor,
            padding: buttonPadding,
          ),
          child: buttonContent,
        ),
      );
    }
  }
}
