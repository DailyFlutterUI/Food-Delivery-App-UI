import 'package:flutter/material.dart';

/// Design tokens for the **Global Shipping Signup** — a refined, premium dark
/// system. Rich near-black canvas, a quiet elevated surface ladder, one warm
/// coral accent, and Inter for crisp modern type. Restraint over decoration.
class S {
  S._();

  static const String font = 'Inter';

  // ---- canvas ---------------------------------------------------------------
  static const Color bg = Color(0xFF0A0B0F);
  static const Color bgLow = Color(0xFF0E0F15);

  // ---- elevated surfaces (the ladder) ---------------------------------------
  static const Color surface = Color(0xFF15161D); // cards / fields
  static const Color surfaceHi = Color(0xFF1C1E27); // raised / keys / chips
  static const Color surfaceTop = Color(0xFF24262F); // key top highlight

  // ---- hairlines ------------------------------------------------------------
  static const Color hair = Color(0x14FFFFFF); // ~8% white
  static const Color hairSoft = Color(0x0AFFFFFF); // ~4% white

  // ---- ink ------------------------------------------------------------------
  static const Color ink = Color(0xFFF3F4F8);
  static const Color inkMute = Color(0xFF9498A6);
  static const Color inkFaint = Color(0xFF595C68);

  // ---- the one accent (warm coral-orange) -----------------------------------
  static const Color accent = Color(0xFFFF6A2B);
  static const Color accentHi = Color(0xFFFF9E5E);
  static const Color accentDeep = Color(0xFFE24E12);

  static Color accentA(double a) => accent.withValues(alpha: a);

  // ---- elevation ------------------------------------------------------------
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get key => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// A restrained accent glow — reserved for the primary CTA only.
  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.26),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ---- type helpers ---------------------------------------------------------
  static const TextStyle eyebrow = TextStyle(
    fontFamily: font,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: accent,
  );

  static const TextStyle title = TextStyle(
    fontFamily: font,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    height: 1.08,
    color: ink,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: inkMute,
  );

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
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
