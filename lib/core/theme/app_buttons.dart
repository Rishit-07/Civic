import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radii.dart';

/// Reusable Button components matching the Stitch design specifications
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final bool isFullWidth;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppColors.secondary,
    this.textColor = Colors.white,
    this.leading,
    this.trailing,
    this.height = 52.0,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.pillBorder,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: AppTypography.labelLarge.copyWith(
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Circular Directional Action Button (52px x 52px circle)
class AppCircularArrowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const AppCircularArrowButton({
    super.key,
    this.onPressed,
    this.backgroundColor = AppColors.secondary,
    this.iconColor = Colors.white,
    this.size = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(
              Icons.arrow_forward_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined Pill Button
class AppOutlinedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final double height;
  final Widget? leading;

  const AppOutlinedPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor = AppColors.borderOutline,
    this.textColor = AppColors.textPrimary,
    this.height = 52.0,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.pillBorder,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
