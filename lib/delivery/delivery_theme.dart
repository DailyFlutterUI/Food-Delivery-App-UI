import 'package:flutter/material.dart';

/// Design tokens for **Parcel** — a premium package-tracking app.
///
/// Aesthetic (from the reference): a light warm-grey canvas, crisp white cards,
/// a single **orange** accent, and deep **charcoal** panels with white text.
/// The map is quiet greyscale; only the route markers and the courier actions
/// carry the orange. Depth comes from light, shadow and motion.
class D {
  D._();

  // ---- the one accent (orange family) ---------------------------------------

  static const Color accent = Color(0xFFF5821F); // primary orange (FAB)
  static const Color accentDeep = Color(0xFFD96A0B);
  static const Color accentWarm = Color(0xFFFF5C39); // red-orange for markers
  static const Color accentLight = Color(0xFFFFB269);

  static Color get accentWash => accent.withAlpha(22);
  static Color get accentGlow => accent.withAlpha(70);
  static Color get accentHalo => accent.withAlpha(34);

  // ---- canvas + light surfaces ----------------------------------------------

  static const Color bg = Color(0xFFF3F3F5);
  static const Color bgSoft = Color(0xFFEAEAEE);
  static const Color card = Color(0xFFFFFFFF);

  // ---- dark surfaces (the detail sheet, nav bar, circular buttons) ----------

  static const Color dark = Color(0xFF1A1A1C);
  static const Color darkSoft = Color(0xFF252529); // chips/nodes on dark
  static const Color darkHair = Color(0xFF323237); // hairlines on dark
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xFF8E8E97);

  // ---- map palette (greyscale) ----------------------------------------------

  static const Color mapBg = Color(0xFFE8E9EE);
  static const Color mapBlock = Color(0xFFDDDEE5);
  static const Color mapBlockAlt = Color(0xFFD3D5DD);
  static const Color mapBlockWarm = Color(0xFFE4DED7); // sandy lots
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapRoadMinor = Color(0xFFF4F5F8);
  static const Color mapRoadEdge = Color(0xFFD0D2DB);
  static const Color mapWater = Color(0xFFCFE0EA); // rivers / canals
  static const Color mapPark = Color(0xFFD4E6D2); // green space
  static const Color route = Color(0xFF1A1A1C); // dark route line

  // ---- neutral ink (on light) -----------------------------------------------

  static const Color ink = Color(0xFF1A1A1C);
  static const Color inkSoft = Color(0xFF8A8A92);
  static const Color inkFaint = Color(0xFFC4C4CC);

  // ---- type -----------------------------------------------------------------

  static const String font = 'PlusJakartaSans';
  static const String fontDisplay = 'PlusJakartaSans';

  // ---- elevation ------------------------------------------------------------

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A1C).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get darkShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A1C).withValues(alpha: 0.22),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> accentShadow(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: 0.34),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(primary: accent, surface: bg),
      textTheme: base.textTheme.apply(
        fontFamily: font,
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}
