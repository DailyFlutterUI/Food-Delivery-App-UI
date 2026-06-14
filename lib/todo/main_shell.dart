import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'todo_theme.dart';

/// Hosts the main tabs behind a cute, animated floating nav bar. Pages are kept
/// alive in an [IndexedStack] so scroll position and state survive tab switches.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.tune_rounded, label: 'Settings'),
  ];

  void _select(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild (recolour) the whole shell + pages when the accent changes.
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) => Scaffold(
        backgroundColor: T.bg,
        body: IndexedStack(
          index: _index,
          // Non-const so they rebuild (recolour) when the accent changes.
          children: [HomePage(), SettingsPage()],
        ),
        bottomNavigationBar: _NavBar(
          items: _tabs,
          index: _index,
          onSelect: _select,
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Floating rounded nav bar. The active tab expands into a pill with its label;
/// inactive tabs are quiet icons.
class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<_TabItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 0, 56, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: T.card,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: T.accent.withAlpha(22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
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
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? T.accentDeep : T.inkFaint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A soft wash capsule sits behind the active icon — light, not heavy.
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 30,
            width: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? T.accentWash : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(selected),
              tween: Tween(begin: selected ? 0.7 : 1.0, end: 1.0),
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutBack,
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: Icon(item.icon, size: 22, color: color),
            ),
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontFamily: T.fontDisplay,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}
