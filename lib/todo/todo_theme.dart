import 'package:flutter/material.dart';

/// Design tokens for the cute to-do app.
///
/// Aesthetic: a soft near-white canvas, white cards, and a *single* friendly
/// accent. Cuteness comes from rounded shapes, glossy 3D emoji, and rich motion
/// — not from a busy palette.
///
/// The accent is **runtime-themeable**: the whole accent family (washes, glows,
/// shadows, the tinted canvas) is derived from a single [accent] seed the user
/// picks in Settings. The inks stay neutral so any accent reads cleanly.
class T {
  T._();

  // ---- the one tunable seed -------------------------------------------------

  static Color accent = const Color(0xFFFF4D9D); // bubblegum pink

  /// Cute accent options offered in Settings.
  static const List<Color> accentChoices = [
    Color(0xFFFF4D9D), // bubblegum
    Color(0xFFFF6B81), // coral
    Color(0xFFFF8A5C), // peach
    Color(0xFFFFB23E), // amber
    Color(0xFF3FC8A9), // mint
    Color(0xFF4DA8FF), // sky
    Color(0xFF8B7BE8), // lavender
    Color(0xFFB06AB3), // orchid
  ];

  // ---- derived accent family ------------------------------------------------

  static Color get accentDeep => _shift(accent, -0.16);
  static Color get accentWash => accent.withAlpha(26); // ~10%
  static Color get accentGlow => accent.withAlpha(85); // ~33%

  /// A large soft accent halo (used behind intro heroes / drifting blob).
  static Color get accentHalo => accent.withAlpha(38);

  // ---- canvas + surfaces (faintly tinted toward the accent) -----------------

  static Color get bg => Color.lerp(Colors.white, accent, 0.035)!;
  static Color get bgSoft => Color.lerp(Colors.white, accent, 0.12)!;
  static const Color card = Color(0xFFFFFFFF);

  // ---- neutral ink ----------------------------------------------------------

  static const Color ink = Color(0xFF2D2A3A);
  static const Color inkSoft = Color(0xFF9893A8);
  static const Color inkFaint = Color(0xFFC7C2D6);

  // ---- type -----------------------------------------------------------------

  /// Body / default font — rounded and friendly, still clean.
  static const String font = 'Quicksand';

  /// Display font — a chunky, cute rounded face for big headlines.
  static const String fontDisplay = 'Baloo2';

  /// Path to a bundled Microsoft Fluent Emoji 3D asset (glossy, transparent).
  static String emoji(String name) => 'assets/emoji/$name.png';

  // ---- helpers --------------------------------------------------------------

  /// Soft, airy card shadow, tinted by the accent.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: accent.withAlpha(20),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];

  /// Lighten (positive) or darken (negative) a colour in HSL space.
  static Color _shift(Color c, double amount) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        surface: bg,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: font,
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}
