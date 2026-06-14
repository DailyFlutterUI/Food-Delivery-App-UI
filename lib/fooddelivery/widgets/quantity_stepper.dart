import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A compact −/+ stepper used wherever a quantity is editable (menu rows, the
/// cart, the detail bottom bar). Accent-tinted, pill-shaped.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove_rounded, onTap: onDecrement),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            // ConstrainedBox + textAlign keeps the number horizontally centred
            // within a stable min-width without an `alignment:`, which would make
            // the box greedily fill the parent's height (e.g. the full-screen
            // maxHeight of a Scaffold.bottomNavigationBar slot).
            child: ConstrainedBox(
              key: ValueKey(quantity),
              constraints: const BoxConstraints(minWidth: 28),
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: AppText.title.copyWith(fontSize: 15),
              ),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
