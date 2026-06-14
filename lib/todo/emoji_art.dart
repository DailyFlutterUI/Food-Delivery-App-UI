import 'package:flutter/material.dart';

import 'todo_theme.dart';

/// Maps a task's stored emoji glyph to a glossy 3D asset name (Fluent Emoji).
const Map<String, String> kEmojiAssets = {
  '🌸': 'cherry_blossom',
  '☕️': 'coffee',
  '📚': 'books',
  '💪': 'muscle',
  '🧺': 'basket',
  '🛒': 'cart',
  '🎨': 'palette',
  '🎧': 'headphone',
  '🌱': 'seedling',
  '💌': 'letter',
  '🐱': 'cat',
  '✨': 'sparkles',
};

/// Renders a task emoji as a crisp 3D image when one is bundled, otherwise falls
/// back to the platform glyph so any character still shows.
class EmojiArt extends StatelessWidget {
  const EmojiArt(this.emoji, {super.key, this.size = 30});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = kEmojiAssets[emoji];
    if (asset == null) {
      return Text(emoji, style: TextStyle(fontSize: size * 0.82));
    }
    return Image.asset(
      T.emoji(asset),
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );
  }
}
