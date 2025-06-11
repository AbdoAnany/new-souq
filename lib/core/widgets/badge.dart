import 'package:flutter/material.dart';
import '/core/constants/app_constants.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isVisible;
  final double size;
  final EdgeInsets padding;

  const Badge({
    Key? key,
    required this.child,
    required this.value,
    this.backgroundColor,
    this.textColor,
    this.isVisible = true,
    this.size = 18.0,
    this.padding = const EdgeInsets.all(2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (isVisible)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? AppConstants.errorColor,
              ),
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
