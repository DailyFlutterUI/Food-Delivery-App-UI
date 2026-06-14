import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'savings_theme.dart';

/// Bottom sheet for adding savings. Offers quick chips and a free-entry amount,
/// then hands the value back to the caller which fires the rain.
class AddDepositSheet {
  static Future<void> show(BuildContext context,
      {required ValueChanged<double> onSubmit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(onSubmit: onSubmit),
    );
  }
}

class _Sheet extends StatefulWidget {
  const _Sheet({required this.onSubmit});
  final ValueChanged<double> onSubmit;

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  final _controller = TextEditingController();
  double _amount = 0;

  static const _quick = [5.0, 20.0, 50.0, 100.0, 250.0, 500.0];

  void _setAmount(double v) {
    setState(() {
      _amount = v;
      _controller.text = v == v.truncate() ? v.toInt().toString() : v.toString();
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
    HapticFeedback.selectionClick();
  }

  void _submit() {
    if (_amount <= 0) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    widget.onSubmit(_amount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: S.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: S.inkFaint,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Make it rain',
              style: TextStyle(
                fontFamily: S.fontDisplay,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: S.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'How much are you saving today?',
              style: TextStyle(
                fontFamily: S.font,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: S.inkSoft,
              ),
            ),
            const SizedBox(height: 20),
            // Big amount field.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: S.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: S.accentWash, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text(
                    r'$',
                    style: TextStyle(
                      fontFamily: S.fontDisplay,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: S.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (v) =>
                          setState(() => _amount = double.tryParse(v) ?? 0),
                      onSubmitted: (_) => _submit(),
                      cursorColor: S.accent,
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(
                        fontFamily: S.fontDisplay,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: S.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final q in _quick)
                  _QuickChip(
                    label: S.money(q),
                    selected: _amount == q,
                    onTap: () => _setAmount(q),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _SaveButton(enabled: _amount > 0, onTap: _submit),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? S.accent : S.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? S.accent : S.inkFaint.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: S.fontDisplay,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : S.ink,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: S.accent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: S.accentGlow,
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: const Center(
            child: Text(
              'Save it',
              style: TextStyle(
                fontFamily: S.fontDisplay,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
