import 'package:flutter/material.dart';

import 'food_theme.dart';

/// Premium, restrained palette — a warm canvas with a single refined
/// burnt-orange accent. Neutrals do the heavy lifting; the accent is used
/// sparingly so it reads as deliberate rather than decorative.
///
/// The accent family is constant in both themes. The neutral surfaces and text
/// tones are *reactive getters* backed by [FoodTheme.instance], so flipping the
/// app between Daylight and Midnight recolours every existing `AppColors.x`
/// call site at once.
class AppColors {
  AppColors._();

  static FoodPalette get _p => FoodTheme.instance.palette;

  // Single accent — constant across both moods.
  static const Color primary = Color(0xFFE94E00);
  static const Color primaryDark = Color(0xFFC23E00);
  static const Color primaryDeep = Color(0xFF8A2B00);
  static const Color amber = Color(0xFFF6A609);

  // Reactive neutral surfaces & accent tint.
  static Color get accentSoft => _p.accentSoft; // tinted accent surface
  static Color get background => _p.background;
  static Color get card => _p.card;
  static Color get surfaceAlt => _p.surfaceAlt; // chips, thumbnails
  static Color get hairline => _p.hairline;

  /// Warm peach → white wash (or ember → ink at night) painted behind screens.
  static LinearGradient get backgroundGradient => _p.backgroundGradient;

  // Legacy alias kept so older references compile.
  static Color get chip => _p.surfaceAlt;

  // Text — warm near-black down to muted greys (inverted in Midnight).
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textMuted => _p.textMuted;

  // Sparing supporting tones.
  static Color get pink => _p.pink;
  static Color get discountBanner => _p.accentSoft;
}

/// Layered, soft shadows. Premium UIs avoid hard drop shadows in favour of
/// wide, low-opacity diffusion. The base ink tone deepens in Midnight.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: FoodTheme.instance.palette.shadow,
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: FoodTheme.instance.palette.shadow,
          blurRadius: 36,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> accent(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.30),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];
}

/// Consistent corner radii.
class AppRadius {
  AppRadius._();
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 30;
}

class AppTheme {
  AppTheme._();

  /// Display / headings.
  static const String displayFont = 'PlusJakartaSans';

  /// Body & UI text.
  static const String bodyFont = 'Inter';

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.card,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AppTheme.bodyFont,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Refined type scale. Display sizes use Plus Jakarta with tight tracking;
/// body/UI text uses Inter for clean legibility at small sizes.
class AppText {
  AppText._();

  // Reactive getters: the text colour follows the active palette, so the same
  // styles read correctly in both Daylight and Midnight. (`button` is white in
  // both moods, sitting on the accent.)
  static TextStyle get display => TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.15,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get title => TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  /// Small, all-caps section eyebrow.
  static TextStyle get eyebrow => TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppColors.textMuted,
      );

  static TextStyle get body => TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get price => TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static const TextStyle button = TextStyle(
    fontFamily: AppTheme.displayFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: Colors.white,
  );
}
