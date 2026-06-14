import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small labelled pill — an icon plus a short value — used for at-a-glance
/// facts (distance, rating, ETA) on cards and the map.
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primary,
    this.background = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppText.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
