import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const MyAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading=true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      // backgroundColor: theme.cardColor,
      // foregroundColor: theme.primaryColor,

      elevation: 0,
      title: title,
      actions: actions,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
