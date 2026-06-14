import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'savings_store.dart';
import 'savings_theme.dart';

/// Bottom sheet to name the goal and set a target amount.
class EditGoalSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _Sheet(),
    );
  }
}

class _Sheet extends StatefulWidget {
  const _Sheet();

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  late final _name = TextEditingController(text: savingsStore.goalName);
  late final _target = TextEditingController(
      text: savingsStore.target.toInt().toString());

  void _submit() {
    HapticFeedback.mediumImpact();
    savingsStore.setGoal(
      name: _name.text,
      target: double.tryParse(_target.text) ?? savingsStore.target,
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
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
              'Your goal',
              style: TextStyle(
                fontFamily: S.fontDisplay,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: S.ink,
              ),
            ),
            const SizedBox(height: 18),
            _Field(
              label: 'What are you saving for?',
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                cursorColor: S.accent,
                decoration: const InputDecoration(
                  hintText: 'Dream Getaway',
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style: const TextStyle(
                  fontFamily: S.fontDisplay,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: S.ink,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _Field(
              label: 'Target amount',
              child: Row(
                children: [
                  const Text(
                    r'$',
                    style: TextStyle(
                      fontFamily: S.fontDisplay,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: S.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _target,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorColor: S.accent,
                      decoration: const InputDecoration(
                        hintText: '5000',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(
                        fontFamily: S.fontDisplay,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: S.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: S.accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: S.accentGlow,
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Save goal',
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
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: S.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: S.accentWash, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: S.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
