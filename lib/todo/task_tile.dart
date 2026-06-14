import 'package:flutter/material.dart';

import 'emoji_art.dart';
import 'task.dart';
import 'todo_theme.dart';

/// A single cute task row: emoji chip, title, and a springy round checkbox.
/// Tap to complete, long-press to edit, swipe left to delete. An optional
/// [dragHandle] is shown leading when the list is reorderable.
class TaskTile extends StatefulWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.dragHandle,
  });

  final Task task;

  /// Receives the global center of the checkbox so the parent can fire a
  /// sparkle burst right where the celebration should happen.
  final void Function(Offset checkboxCenter) onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final Widget? dragHandle;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  final GlobalKey _checkboxKey = GlobalKey();

  void _toggle() {
    final box = _checkboxKey.currentContext?.findRenderObject() as RenderBox?;
    final center = box != null
        ? box.localToGlobal(box.size.center(Offset.zero))
        : Offset.zero;
    widget.onToggle(center);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: _deleteBackground(),
      child: GestureDetector(
        onTap: _toggle,
        onLongPress: widget.onEdit,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: task.done ? T.bgSoft : T.card,
            borderRadius: BorderRadius.circular(22),
            boxShadow: task.done ? null : T.cardShadow,
          ),
          child: Row(
            children: [
              if (widget.dragHandle != null) ...[
                widget.dragHandle!,
                const SizedBox(width: 8),
              ],
              _EmojiChip(emoji: task.emoji, dimmed: task.done),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  style: TextStyle(
                    fontFamily: T.font,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: task.done ? T.inkFaint : T.ink,
                    decoration: task.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: T.inkFaint,
                    decorationThickness: 2,
                  ),
                  child: Text(task.title),
                ),
              ),
              const SizedBox(width: 12),
              _SpringCheckbox(key: _checkboxKey, checked: task.done),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.only(right: 26),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: T.accentWash,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(Icons.delete_rounded, color: T.accentDeep),
    );
  }
}

class _EmojiChip extends StatelessWidget {
  const _EmojiChip({required this.emoji, required this.dimmed});

  final String emoji;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.bgSoft,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: T.accent.withAlpha(28), width: 1),
        ),
        child: EmojiArt(emoji, size: 30),
      ),
    );
  }
}

/// Round checkbox that pops with a tiny spring whenever its checked state
/// flips, and draws a check when filled.
class _SpringCheckbox extends StatefulWidget {
  const _SpringCheckbox({super.key, required this.checked});

  final bool checked;

  @override
  State<_SpringCheckbox> createState() => _SpringCheckboxState();
}

class _SpringCheckboxState extends State<_SpringCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    lowerBound: 0.0,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void didUpdateWidget(_SpringCheckbox old) {
    super.didUpdateWidget(old);
    if (old.checked != widget.checked) {
      _c.reverse().then((_) => _c.forward());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.78, end: 1.0)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: widget.checked ? T.accent : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.checked ? T.accent : T.inkFaint,
              width: 2,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.checked ? 1 : 0,
            child: const Icon(Icons.check_rounded,
                size: 18, color: Colors.white),
          ),
        ),
    );
  }
}
