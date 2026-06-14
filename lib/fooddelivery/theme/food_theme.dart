import 'package:flutter/material.dart';

/// App-wide light⇄dark theme state for the food-delivery prototype.
///
/// The neutral surfaces and text colours live in a [FoodPalette] that is lerped
/// by a single 0→1 value `t` (0 = Daylight, 1 = Midnight). [AppColors] reads
/// its neutral members from [FoodTheme.instance], so every screen recolours at
/// once the moment `t` changes — no per-widget wiring required. The burnt-orange
/// accent is intentionally left out of the palette: it stays constant in both
/// moods so the brand reads the same.
class FoodTheme extends ChangeNotifier {
  FoodTheme._();
  static final FoodTheme instance = FoodTheme._();

  double _t = 0;

  /// 0.0 = Daylight, 1.0 = Midnight. Anything in between is a live morph frame.
  double get t => _t;
  set t(double value) {
    final v = value.clamp(0.0, 1.0);
    if (v == _t) return;
    _t = v;
    notifyListeners();
  }

  bool get isDark => _t > 0.5;

  FoodPalette get palette =>
      FoodPalette.lerp(FoodPalette.light, FoodPalette.dark, _t);
}

/// The full set of neutral colours the UI paints, plus a derived background
/// gradient. Lerped frame-by-frame so transitions are smooth, not a hard swap.
class FoodPalette {
  const FoodPalette({
    required this.bgTop,
    required this.bgBottom,
    required this.background,
    required this.card,
    required this.surfaceAlt,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentSoft,
    required this.pink,
    required this.shadow,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color background;
  final Color card;
  final Color surfaceAlt;
  final Color hairline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentSoft;
  final Color pink;
  final Color shadow;

  /// Warm wash painted once behind every (transparent) screen.
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgBottom],
        stops: const [0.0, 0.42],
      );

  static const light = FoodPalette(
    bgTop: Color(0xFFFCDAC9),
    bgBottom: Colors.white,
    background: Colors.white,
    card: Colors.white,
    surfaceAlt: Color(0xFFF6F1EE),
    hairline: Color(0xFFF1E7E1),
    textPrimary: Color(0xFF17151F),
    textSecondary: Color(0xFF8A8794),
    textMuted: Color(0xFFBDBAC8),
    accentSoft: Color(0xFFFDE7DC),
    pink: Color(0xFFF6EFF9),
    shadow: Color(0x0D14102A),
  );

  static const dark = FoodPalette(
    bgTop: Color(0xFF2A1A12), // warm ember up top, echoing the daylight peach
    bgBottom: Color(0xFF121016),
    background: Color(0xFF121016),
    card: Color(0xFF1C1A23),
    surfaceAlt: Color(0xFF272431),
    hairline: Color(0xFF302D3A),
    textPrimary: Color(0xFFF6F3F8),
    textSecondary: Color(0xFF9C98A8),
    textMuted: Color(0xFF6A6676),
    accentSoft: Color(0xFF3A2317), // deep ember — accent reads on it
    pink: Color(0xFF221E2B),
    shadow: Color(0x40000000),
  );

  static FoodPalette lerp(FoodPalette a, FoodPalette b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return FoodPalette(
      bgTop: c(a.bgTop, b.bgTop),
      bgBottom: c(a.bgBottom, b.bgBottom),
      background: c(a.background, b.background),
      card: c(a.card, b.card),
      surfaceAlt: c(a.surfaceAlt, b.surfaceAlt),
      hairline: c(a.hairline, b.hairline),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textMuted: c(a.textMuted, b.textMuted),
      accentSoft: c(a.accentSoft, b.accentSoft),
      pink: c(a.pink, b.pink),
      shadow: c(a.shadow, b.shadow),
    );
  }
}
