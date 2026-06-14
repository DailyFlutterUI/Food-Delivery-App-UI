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
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.accent(AppColors.primary),
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
