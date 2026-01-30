import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.onLeadingPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textWhite,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: AppColors.textWhite,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading != null
          ? IconButton(
              icon: leading!,
              onPressed: onLeadingPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
