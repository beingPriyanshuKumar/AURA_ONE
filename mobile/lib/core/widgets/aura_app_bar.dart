import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AuraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Color? backgroundColor;
  final bool centerTitle;
  final IconThemeData? iconTheme;
  final TextStyle? titleStyle;

  const AuraAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.backgroundColor,
    this.centerTitle = true,
    this.iconTheme,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: backgroundColor ?? AppColors.background.withOpacity(0.8),
          elevation: 0,
          centerTitle: centerTitle,
          automaticallyImplyLeading: showBack,
          iconTheme: iconTheme,
          title: Text(
            title,
            style: titleStyle ?? AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          actions: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
