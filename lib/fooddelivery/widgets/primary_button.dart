import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The app's primary call-to-action — a full-width accent button with an
/// optional trailing icon and a soft accent glow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.showShadow = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  /// Soft accent glow beneath the button. Off for the flat auth CTAs.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: showShadow ? AppShadows.accent(AppColors.primary) : null,
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppText.button),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 19, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
