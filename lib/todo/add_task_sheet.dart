import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'emoji_art.dart';
import 'task.dart';
import 'todo_theme.dart';

/// The cute task sheet — used both to create a new task and to edit one.
/// Calls [onSubmit] with the final title + emoji when confirmed.
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialEmoji,
  });

  final void Function(String title, String emoji) onSubmit;
  final String? initialTitle;
  final String? initialEmoji;

  bool get isEditing => initialTitle != null;

  static Future<void> show(
    BuildContext context, {
    required void Function(String title, String emoji) onSubmit,
    String? initialTitle,
    String? initialEmoji,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(
        onSubmit: onSubmit,
        initialTitle: initialTitle,
        initialEmoji: initialEmoji,
      ),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final _controller = TextEditingController(text: widget.initialTitle);
  final _focus = FocusNode();
  late String _emoji = widget.initialEmoji ?? kEmojiChoices.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSubmit(text, _emoji);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _controller.text.trim().isNotEmpty;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: T.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grabber.
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: T.inkFaint,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isEditing ? 'Edit task' : 'New task',
              style: const TextStyle(
                fontFamily: T.font,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: T.ink,
              ),
            ),
            const SizedBox(height: 16),
            // Title field.
            Container(
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: T.cardShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  EmojiArt(_emoji, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: T.accent,
                      style: const TextStyle(
                        fontFamily: T.font,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: T.ink,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: InputBorder.none,
                        hintText: 'What would be lovely to do?',
                        hintStyle: TextStyle(
                          fontFamily: T.font,
                          color: T.inkSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pick a vibe',
              style: TextStyle(
                fontFamily: T.font,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: T.inkSoft,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final e in kEmojiChoices) _emojiOption(e)],
            ),
            const SizedBox(height: 22),
            // Submit.
            GestureDetector(
              onTap: canSubmit ? _submit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: canSubmit ? T.accent : T.inkFaint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  widget.isEditing ? 'Save changes' : 'Add it',
                  style: const TextStyle(
                    fontFamily: T.font,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emojiOption(String e) {
    final selected = e == _emoji;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _emoji = e);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? T.accentWash : T.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? T.accent : const Color(0x11000000),
            width: selected ? 2 : 1,
          ),
        ),
        child: AnimatedScale(
          scale: selected ? 1.12 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: EmojiArt(e, size: 30),
        ),
      ),
    );
  }
}
