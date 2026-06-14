import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/food_theme.dart';

/// "Settings Transformation Flow" — a profile / settings screen whose entire
/// surface morphs between a Daylight and a Midnight palette in real time.
///
/// Every colour the screen paints is read from a [_Palette] that is lerped by a
/// single [AnimationController]. Selecting a theme animates the morph from 0→1
/// (or back), so the background gradient shifts, cards recolour, text fades and
/// toggles re-tint together — one smooth, deliberate transformation rather than
/// a hard theme swap. The burnt-orange accent is preserved throughout so the
/// brand reads the same in both moods.
class SettingsTransformScreen extends StatefulWidget {
  const SettingsTransformScreen({super.key, this.active = true});

  /// Whether this screen is the visible one. When it flips false→true (e.g. the
  /// user opens the Profile tab) the entrance animation replays so the widgets
  /// fade in one by one each time the screen is opened.
  final bool active;

  @override
  State<SettingsTransformScreen> createState() =>
      _SettingsTransformScreenState();
}

class _SettingsTransformScreenState extends State<SettingsTransformScreen>
    with TickerProviderStateMixin {
  /// 0.0 = Daylight, 1.0 = Midnight. Drives every colour on screen.
  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );

  /// 0→1 entrance timeline; each row reveals on its own slice of it.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  bool _dark = false;

  // A few demo toggles so the recolour reads across many surface types.
  bool _push = true;
  bool _faceId = true;
  bool _haptics = false;

  @override
  void initState() {
    super.initState();
    // Stay in sync with the app-wide theme, and drive it as the morph plays so
    // every other screen recolours together with this one.
    _dark = FoodTheme.instance.isDark;
    _morph.value = FoodTheme.instance.t;
    _morph.addListener(_syncGlobalTheme);
    if (widget.active) _intro.forward();
  }

  void _syncGlobalTheme() => FoodTheme.instance.t = _morph.value;

  @override
  void didUpdateWidget(SettingsTransformScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _intro.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _morph.removeListener(_syncGlobalTheme);
    _morph.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _select(bool dark) {
    if (dark == _dark) return;
    setState(() => _dark = dark);
    HapticFeedback.lightImpact();
    _morph.animateTo(dark ? 1 : 0, curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morph,
      builder: (context, _) {
        final p = _Palette.lerp(_Palette.light, _Palette.dark, _morph.value);

        // Each entry reveals on its own slice of the intro timeline, so the
        // section eyebrows and their cards fade in as a pair, top to bottom.
        final rows = <Widget>[
          _TopBar(p: p),
          _ProfileHeader(p: p),
          _Eyebrow('APPEARANCE', p: p),
          _ThemePicker(p: p, dark: _dark, onSelect: _select),
          _Eyebrow('PREFERENCES', p: p),
          _Card(
            p: p,
            child: Column(
              children: [
                _ToggleRow(
                  p: p,
                  icon: Icons.notifications_none_rounded,
                  label: 'Push notifications',
                  value: _push,
                  onChanged: (v) => setState(() => _push = v),
                ),
                _Hairline(p: p),
                _ToggleRow(
                  p: p,
                  icon: Icons.face_retouching_natural_rounded,
                  label: 'Unlock with Face ID',
                  value: _faceId,
                  onChanged: (v) => setState(() => _faceId = v),
                ),
                _Hairline(p: p),
                _ToggleRow(
                  p: p,
                  icon: Icons.vibration_rounded,
                  label: 'Haptic feedback',
                  value: _haptics,
                  onChanged: (v) => setState(() => _haptics = v),
                ),
              ],
            ),
          ),
          _Eyebrow('ACCOUNT', p: p),
          _Card(
            p: p,
            child: Column(
              children: [
                _LinkRow(
                  p: p,
                  icon: Icons.receipt_long_rounded,
                  label: 'My orders',
                ),
                _Hairline(p: p),
                _LinkRow(
                  p: p,
                  icon: Icons.credit_card_rounded,
                  label: 'Payment methods',
                ),
                _Hairline(p: p),
                _LinkRow(
                  p: p,
                  icon: Icons.location_on_outlined,
                  label: 'Saved addresses',
                ),
              ],
            ),
          ),
          _SaveButton(p: p),
        ];

        // Vertical gaps that follow each row (matched 1:1 with `rows`).
        const gaps = <double>[20, 28, 14, 28, 14, 22, 14, 30, 0];

        // Past the halfway point of the morph the canvas is dark, so flip the
        // system status bar (clock, wifi, battery) to light icons.
        final isDark = _morph.value > 0.5;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark, // Android
            statusBarBrightness: isDark
                ? Brightness.dark
                : Brightness.light, // iOS
          ),
          child: Scaffold(
            backgroundColor: p.bgBottom,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.bgTop, p.bgBottom],
                  stops: const [0.0, 0.5],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      _StaggerItem(
                        animation: _intro,
                        index: i,
                        count: rows.length,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: gaps[i]),
                          child: rows[i],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reveals [child] on its own slice of the shared [animation] — a fade paired
/// with a small upward slide, staggered by [index] so rows arrive one by one.
class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.animation,
    required this.index,
    required this.count,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const span = 0.5; // fraction of the timeline each row takes to fade in
    final maxStart = 1.0 - span;
    final start = count <= 1 ? 0.0 : (index / (count - 1)) * maxStart;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, start + span, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Palette — the single source of colour, lerped by the morph controller.
// ────────────────────────────────────────────────────────────────────────────

class _Palette {
  const _Palette({
    required this.bgTop,
    required this.bgBottom,
    required this.card,
    required this.surfaceAlt,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.shadow,
    required this.isDark,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color card;
  final Color surfaceAlt;
  final Color hairline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color shadow;
  final double isDark; // 0..1, handy for fading dark-only treatments

  static const light = _Palette(
    bgTop: Color(0xFFFCDAC9),
    bgBottom: Colors.white,
    card: Colors.white,
    surfaceAlt: Color(0xFFF6F1EE),
    hairline: Color(0xFFF1E7E1),
    textPrimary: Color(0xFF17151F),
    textSecondary: Color(0xFF8A8794),
    textMuted: Color(0xFFBDBAC8),
    accent: Color(0xFFE94E00),
    shadow: Color(0x0D14102A),
    isDark: 0,
  );

  static const dark = _Palette(
    bgTop: Color(0xFF2A1A12), // warm ember up top, echoing the peach
    bgBottom: Color(0xFF121016),
    card: Color(0xFF1C1A23),
    surfaceAlt: Color(0xFF272431),
    hairline: Color(0xFF302D3A),
    textPrimary: Color(0xFFF6F3F8),
    textSecondary: Color(0xFF9C98A8),
    textMuted: Color(0xFF6A6676),
    accent: Color(0xFFFF6322), // a touch brighter so it carries on dark
    shadow: Color(0x40000000),
    isDark: 1,
  );

  static _Palette lerp(_Palette a, _Palette b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return _Palette(
      bgTop: c(a.bgTop, b.bgTop),
      bgBottom: c(a.bgBottom, b.bgBottom),
      card: c(a.card, b.card),
      surfaceAlt: c(a.surfaceAlt, b.surfaceAlt),
      hairline: c(a.hairline, b.hairline),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textMuted: c(a.textMuted, b.textMuted),
      accent: c(a.accent, b.accent),
      shadow: c(a.shadow, b.shadow),
      isDark: a.isDark + (b.isDark - a.isDark) * t,
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Pieces
// ────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.p});
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Settings', style: AppText.h1.copyWith(color: p.textPrimary)),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: p.card,
            shape: BoxShape.circle,
            border: Border.all(color: p.hairline),
          ),
          child: Icon(Icons.close_rounded, size: 22, color: p.textPrimary),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.p});
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    // Header stays a deep, warm slab in both moods — only it deepens further at
    // night so it never washes out against the lighter midnight card stack.
    final top = Color.lerp(
      const Color(0xFF8A2B00),
      const Color(0xFF7A2600),
      p.isDark,
    )!;
    final bottom = Color.lerp(
      const Color(0xFF1F1206),
      const Color(0xFF0E0A0F),
      p.isDark,
    )!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [top, bottom],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: const Text('🧑‍💻', style: TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DailyFlutterUI',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'dailyflutterui@gmail.com',
                  style: AppText.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Edit',
              style: AppText.label.copyWith(
                color: p.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.p,
    required this.dark,
    required this.onSelect,
  });

  final _Palette p;
  final bool dark;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeCard(
            p: p,
            selected: !dark,
            title: 'Daylight',
            subtitle: 'Bright & warm',
            icon: Icons.wb_sunny_rounded,
            previewTop: const Color(0xFFFCDAC9),
            previewBottom: Colors.white,
            previewInk: const Color(0xFF17151F),
            onTap: () => onSelect(false),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ThemeCard(
            p: p,
            selected: dark,
            title: 'Midnight',
            subtitle: 'Easy on the eyes',
            icon: Icons.nightlight_round,
            previewTop: const Color(0xFF2A1A12),
            previewBottom: const Color(0xFF121016),
            previewInk: const Color(0xFFF6F3F8),
            onTap: () => onSelect(true),
          ),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.p,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.previewTop,
    required this.previewBottom,
    required this.previewInk,
    required this.onTap,
  });

  final _Palette p;
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color previewTop;
  final Color previewBottom;
  final Color previewInk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: selected ? p.accent : p.hairline, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini phone-screen preview of the palette this card applies.
            Container(
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [previewTop, previewBottom],
                ),
                border: Border.all(color: p.hairline),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 6,
                    decoration: BoxDecoration(
                      color: previewInk.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 54,
                    height: 5,
                    decoration: BoxDecoration(
                      color: previewInk.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 12,
                        decoration: BoxDecoration(
                          color: p.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: previewInk.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? p.accent : p.textSecondary,
                ),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: AppText.title.copyWith(
                    color: p.textPrimary,
                    fontSize: 14.5,
                  ),
                ),
                const Spacer(),
                _RadioDot(p: p, selected: selected),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: AppText.label.copyWith(color: p.textMuted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.p, required this.selected});
  final _Palette p;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? p.accent : Colors.transparent,
        border: Border.all(color: selected ? p.accent : p.textMuted, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
          : null,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.p,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final _Palette p;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: p.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppText.title.copyWith(color: p.textPrimary, fontSize: 14),
            ),
          ),
          _Switch(p: p, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Custom switch so its track/thumb tint with the palette rather than fighting
/// the Material default colours.
class _Switch extends StatelessWidget {
  const _Switch({
    required this.p,
    required this.value,
    required this.onChanged,
  });
  final _Palette p;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? p.accent : p.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: value ? p.accent : p.hairline),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.p, required this.icon, required this.label});
  final _Palette p;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 21, color: p.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppText.title.copyWith(color: p.textPrimary, fontSize: 14),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 22),
        ],
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.p});
  final _Palette p;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  // idle → saving → done, then back to idle.
  int _state = 0;

  Future<void> _save() async {
    if (_state != 0) return;
    HapticFeedback.mediumImpact();
    setState(() => _state = 1);
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() => _state = 2);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _state = 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final saving = _state == 1;
    final done = _state == 2;

    // AnimatedContainer can't interpolate width between a finite value and
    // double.infinity, so resolve the expanded width to the real pixel width
    // via LayoutBuilder and collapse toward the centre.
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        return GestureDetector(
          onTap: _save,
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              height: 56,
              width: saving ? 56 : fullWidth,
              decoration: BoxDecoration(
                color: done ? const Color(0xFF1FA463) : p.accent,
                borderRadius: BorderRadius.circular(saving ? 28 : AppRadius.lg),
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: saving
                    ? const SizedBox(
                        key: ValueKey('spin'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : done
                    ? Row(
                        key: const ValueKey('done'),
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 9),
                          Text('Saved', style: AppText.button),
                        ],
                      )
                    : const Text(
                        'Save changes',
                        key: ValueKey('idle'),
                        style: AppText.button,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Small shared bits.

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {required this.p});
  final String text;
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: AppText.eyebrow.copyWith(color: p.textMuted)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.p, required this.child});
  final _Palette p;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.hairline),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.p});
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: p.hairline,
      indent: 16,
      endIndent: 16,
    );
  }
}

/// Standalone runner so the flow can be launched on its own from `main.dart`.
class SettingsTransformApp extends StatelessWidget {
  const SettingsTransformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Settings Transformation',
      theme: AppTheme.light,
      home: const SettingsTransformScreen(),
    );
  }
}
