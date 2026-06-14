import 'package:flutter/material.dart';

/// Premium, restrained palette — a warm canvas with a single refined
/// burnt-orange accent. Neutrals do the heavy lifting; the accent is used
/// sparingly so it reads as deliberate rather than decorative.
class AppColors {
  AppColors._();

  // Single accent.
  static const Color primary = Color(0xFFE94E00);
  static const Color primaryDark = Color(0xFFC23E00);
  static const Color primaryDeep = Color(0xFF8A2B00);
  static const Color accentSoft = Color(0xFFFDE7DC); // tinted accent surface

  // Surfaces.
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Colors.white;
  static const Color surfaceAlt = Color(0xFFF6F1EE); // chips, thumbnails
  static const Color hairline = Color(0xFFF1E7E1);

  /// Warm peach → white wash painted behind every screen.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCDAC9), Colors.white],
    stops: [0.0, 0.42],
  );

  // Legacy alias kept so older references compile.
  static const Color chip = surfaceAlt;

  // Text — warm near-black down to muted greys.
  static const Color textPrimary = Color(0xFF17151F);
  static const Color textSecondary = Color(0xFF8A8794);
  static const Color textMuted = Color(0xFFBDBAC8);

  // Sparing supporting tones.
  static const Color pink = Color(0xFFF6EFF9);
  static const Color amber = Color(0xFFF6A609);
  static const Color discountBanner = accentSoft;
}

/// Layered, soft shadows. Premium UIs avoid hard drop shadows in favour of
/// wide, low-opacity diffusion.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => const [
        BoxShadow(
          color: Color(0x0D14102A), // ~5% ink
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get floating => const [
        BoxShadow(
          color: Color(0x1A14102A), // ~10% ink
          blurRadius: 36,
          offset: Offset(0, 18),
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
      dividerTheme: const DividerThemeData(
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

  static const TextStyle display = TextStyle(
    fontFamily: AppTheme.displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: AppTheme.displayFont,
    fontSize: 23,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppTheme.displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: AppTheme.displayFont,
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Small, all-caps section eyebrow.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: AppTheme.bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.textMuted,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppTheme.bodyFont,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppTheme.bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle price = TextStyle(
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
