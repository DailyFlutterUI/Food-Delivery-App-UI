import 'package:flutter/material.dart';

import '../state/cart.dart';
import '../theme/app_theme.dart';
import '../theme/food_theme.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'settings_transform_screen.dart';

/// Root scaffold holding the four primary tabs behind a custom bottom bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole shell — every tab and the nav bar — as the app morphs
    // between Daylight and Midnight.
    return ListenableBuilder(
      listenable: FoodTheme.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: _index,
            children: [
              const HomeScreen(),
              const MapScreen(),
              const CartScreen(),
              // Profile tab — replays its entrance each time it becomes active.
              SettingsTransformScreen(active: _index == 3),
            ],
          ),
          bottomNavigationBar: _BottomBar(
            index: _index,
            onTap: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.near_me_rounded, label: 'Nearby'),
    (icon: Icons.shopping_bag_rounded, label: 'Cart'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Floating pill bar that lifts off the canvas — reads cleanly on both the
    // peach daylight wash and the midnight ink.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.hairline),
            boxShadow: AppShadows.floating,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _items.length; i++)
                _NavButton(
                  icon: _items[i].icon,
                  label: _items[i].label,
                  selected: i == index,
                  showBadge: i == 2,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            _IconWithBadge(
              icon: icon,
              color: selected ? AppColors.primary : AppColors.textMuted,
              showBadge: showBadge,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFont,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.color,
    required this.showBadge,
  });

  final IconData icon;
  final Color color;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, color: color, size: 24);
    if (!showBadge) return iconWidget;

    return ListenableBuilder(
      listenable: Cart.instance,
      builder: (context, _) {
        final count = Cart.instance.count;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            if (count > 0)
              Positioned(
                right: -7,
                top: -6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
