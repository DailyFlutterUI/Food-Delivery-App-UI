import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'todo_theme.dart';

/// Full-screen confetti rain + a "You did it!" badge — plays once when every
/// task is completed. Self-removing via [OverlayEntry].
class Celebration {
  static void play(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Celebration(onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

// A small festive palette — only for this one celebratory moment. A getter so
// the two accent-derived colours follow the user's chosen accent.
List<Color> get _confettiColors => [
      T.accent,
      T.accentDeep,
      const Color(0xFFFFD479), // gold
      const Color(0xFFFF9EC4), // pink
      const Color(0xFF8DE0C9), // mint
    ];

class _Celebration extends StatefulWidget {
  const _Celebration({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Confetto> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(42);
    _pieces = List.generate(80, (i) {
      return _Confetto(
        x: rnd.nextDouble(),
        delay: rnd.nextDouble() * 0.35,
        fall: 0.8 + rnd.nextDouble() * 0.5,
        drift: rnd.nextDouble() * 0.16 - 0.08,
        size: 6 + rnd.nextDouble() * 7,
        color: _confettiColors[i % _confettiColors.length],
        spin: rnd.nextDouble() * 8 - 4,
        wobble: rnd.nextDouble() * math.pi * 2,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Badge pops in, holds, then fades out near the end.
    final badgeIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.18, curve: Curves.easeOutBack),
    );
    final badgeOut = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(
                painter: _ConfettiPainter(t: _c.value, pieces: _pieces),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, child) => Opacity(
                opacity: (1 - badgeOut.value).clamp(0.0, 1.0),
                child: Transform.scale(scale: badgeIn.value, child: child),
              ),
              // Material gives the badge a proper default text style — without
              // it, overlay text inherits the WidgetsApp "missing Material"
              // fallback (the yellow double underline).
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  decoration: BoxDecoration(
                    color: T.card,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: T.accent.withValues(alpha: 0.20),
                        blurRadius: 34,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(T.emoji('popper'),
                          width: 56,
                          height: 56,
                          filterQuality: FilterQuality.high),
                      const SizedBox(height: 10),
                      const Text(
                        'You did it!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: T.fontDisplay,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: T.ink,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Every task complete',
                            style: TextStyle(
                              fontFamily: T.font,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: T.inkSoft,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(T.emoji('heart'), width: 16, height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Confetto {
  _Confetto({
    required this.x,
    required this.delay,
    required this.fall,
    required this.drift,
    required this.size,
    required this.color,
    required this.spin,
    required this.wobble,
  });

  final double x; // 0..1 horizontal start
  final double delay; // 0..1 of timeline
  final double fall; // vertical travel factor
  final double drift; // horizontal drift factor
  final double size;
  final Color color;
  final double spin;
  final double wobble;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.t, required this.pieces});

  final double t;
  final List<_Confetto> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final fade = local > 0.85 ? (1 - (local - 0.85) / 0.15) : 1.0;
      final dx = (p.x + p.drift * math.sin(local * 6 + p.wobble)) * size.width;
      final dy = (-0.1 + local * p.fall * 1.2) * size.height;
      final paint = Paint()..color = p.color.withValues(alpha: fade.clamp(0, 1));
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * local * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(p.size / 4),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
