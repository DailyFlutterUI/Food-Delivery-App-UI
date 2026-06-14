import 'package:flutter/material.dart';

/// Neutral, restrained design tokens. Colour comes only from the active mode's
/// single accent — everything structural stays quiet.
class E {
  E._();

  static const Color bg = Color(0xFFFAF9F7); // warm off-white canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF16140F); // near-black text
  static const Color muted = Color(0xFF8A857C); // secondary text
  static const Color hairline = Color(0xFFECE9E4); // dividers / borders
  static const Color fill = Color(0xFFF1EFEB); // inert input fills

  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData theme(Color accent) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        surface: surface,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      splashFactory: InkSparkle.splashFactory,
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
        fontFamily: fontFamily,
      ),
    );
  }

  // Shared text styles.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: ink,
    height: 1.12,
    letterSpacing: -0.6,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.4,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: muted,
    letterSpacing: 0.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ink,
  );

  static const TextStyle sub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: muted,
  );
}
