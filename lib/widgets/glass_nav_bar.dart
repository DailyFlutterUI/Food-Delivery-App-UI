import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavDestination {
  const NavDestination(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Floating frosted bottom navigation. The active item gets a gradient
/// pill that slides between slots.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.destinations,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<NavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.bgElevated.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                for (int i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      data: destinations[i],
                      selected: i == index,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final NavDestination data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: selected ? AppGradients.accent : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accentViolet.withValues(alpha: 0.4),
                    blurRadius: 18,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 22,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
            // Show the label only when active, animating its width.
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                widthFactor: selected ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    data.label,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
