import 'package:flutter/material.dart';

/// Design tokens for **Money Rain** — a premium little savings app.
///
/// Aesthetic: a cool, near-white canvas, soft white cards, and a *single*
/// emerald accent. The only other colour is **gold** — but gold isn't a second
/// accent here, it's the material of the coins themselves, the literal money.
/// Restraint is the point: depth comes from light, shadow and motion, never
/// from a busy palette.
class S {
  S._();

  // ---- the one accent -------------------------------------------------------

  /// Deep, refined emerald — used for the primary action, ring and inks-on-wash.
  static const Color accent = Color(0xFF10A37F);
  static const Color accentDeep = Color(0xFF0B7D60);

  static Color get accentWash => accent.withAlpha(20); // ~8%
  static Color get accentGlow => accent.withAlpha(64); // ~25%
  static Color get accentHalo => accent.withAlpha(30);

  // ---- gold: the coin material ----------------------------------------------

  /// The coin gradient, light → deep. Reused by the rain, the jar and chips.
  static const Color gold = Color(0xFFE7B43E);
  static const Color goldLight = Color(0xFFF7DE9B);
  static const Color goldDeep = Color(0xFFBE8A1E);
  static const Color goldShadow = Color(0xFF8A6212);

  static const List<Color> coinFace = [goldLight, gold, goldDeep];

  // ---- canvas + surfaces (faintly cooled toward the accent) -----------------

  static Color get bg => Color.lerp(const Color(0xFFFFFFFF), accent, 0.035)!;
  static Color get bgSoft => Color.lerp(const Color(0xFFFFFFFF), accent, 0.10)!;
  static const Color card = Color(0xFFFFFFFF);

  // ---- neutral ink ----------------------------------------------------------

  static const Color ink = Color(0xFF15231D);
  static const Color inkSoft = Color(0xFF7E8B85);
  static const Color inkFaint = Color(0xFFB9C2BD);

  // ---- type -----------------------------------------------------------------

  /// Body — clean, modern, slightly technical (reads well with numbers).
  static const String font = 'PlusJakartaSans';

  /// Display — same family, used at heavier weights for headlines & figures.
  static const String fontDisplay = 'PlusJakartaSans';

  // ---- elevation ------------------------------------------------------------

  /// Soft, airy card shadow, cooled by the accent.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: accent.withAlpha(16),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get goldShadowSoft => [
        BoxShadow(
          color: goldShadow.withAlpha(60),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

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

  // ---- money formatting -----------------------------------------------------

  static String money(double v, {bool decimals = false}) {
    final whole = v.abs().truncate();
    final s = whole.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    final sign = v < 0 ? '-' : '';
    if (decimals) {
      final cents = ((v.abs() - whole) * 100).round().toString().padLeft(2, '0');
      return '$sign\$$buf.$cents';
    }
    return '$sign\$$buf';
  }
}
