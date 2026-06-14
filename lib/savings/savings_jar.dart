import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'savings_theme.dart';

/// The "bucket": a tall glass jar that fills with gold from the bottom as the
/// balance grows. The liquid surface ripples continuously; when [progress]
/// changes the fill level eases up to meet it. Premium restraint — the jar is
/// glass and light, the only colour inside is the coin-gold of the savings.
class SavingsJar extends StatefulWidget {
  const SavingsJar({
    super.key,
    required this.progress,
    required this.centerLabel,
    required this.centerSub,
  });

  final double progress; // 0..1
  final String centerLabel; // big figure, e.g. "$1,250"
  final String centerSub; // e.g. "of $5,000"

  @override
  State<SavingsJar> createState() => _SavingsJarState();
}

class _SavingsJarState extends State<SavingsJar>
    with TickerProviderStateMixin {
  // Continuous ripple loop for the liquid surface.
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  // Eased fill that chases the target progress on each change.
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late Animation<double> _level =
      AlwaysStoppedAnimation(widget.progress);

  @override
  void initState() {
    super.initState();
    _fill.value = 1;
  }

  @override
  void didUpdateWidget(covariant SavingsJar old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _level = Tween(begin: old.progress, end: widget.progress).animate(
        CurvedAnimation(parent: _fill, curve: Curves.easeOutCubic),
      );
      _fill.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 280,
      child: AnimatedBuilder(
        animation: Listenable.merge([_wave, _fill]),
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 280),
                painter: _JarPainter(
                  fill: _level.value.clamp(0.0, 1.0),
                  wave: _wave.value,
                ),
              ),
              // Centered readout.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerLabel,
                    style: TextStyle(
                      fontFamily: S.fontDisplay,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: S.ink,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.centerSub,
                    style: const TextStyle(
                      fontFamily: S.font,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: S.inkSoft,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JarPainter extends CustomPainter {
  _JarPainter({required this.fill, required this.wave});

  final double fill; // 0..1
  final double wave; // 0..1 loop phase

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(8, 6, size.width - 16, size.height - 12),
      topLeft: const Radius.circular(54),
      topRight: const Radius.circular(54),
      bottomLeft: const Radius.circular(64),
      bottomRight: const Radius.circular(64),
    );
    final jarPath = Path()..addRRect(rrect);

    // Outer soft shadow under the jar.
    canvas.drawRRect(
      rrect.shift(const Offset(0, 10)),
      Paint()
        ..color = S.accent.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Glass body.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            S.bgSoft.withValues(alpha: 0.55),
          ],
        ).createShader(rrect.outerRect),
    );

    // Clip to the jar to draw the liquid.
    canvas.save();
    canvas.clipPath(jarPath);

    final innerRect = rrect.outerRect;
    final baseY = innerRect.bottom;
    final span = innerRect.height;
    final levelY = baseY - span * fill;

    if (fill > 0.001) {
      final amp = 7.0 + 4.0 * math.sin(wave * 2 * math.pi);
      final phase = wave * 2 * math.pi;

      final liquid = Path()..moveTo(innerRect.left, baseY);
      liquid.lineTo(innerRect.left, levelY);
      const steps = 28;
      for (int i = 0; i <= steps; i++) {
        final x = innerRect.left + innerRect.width * (i / steps);
        final y = levelY +
            math.sin((i / steps) * 2 * math.pi * 1.4 + phase) * amp +
            math.sin((i / steps) * 2 * math.pi * 0.6 - phase * 0.7) * amp * 0.4;
        liquid.lineTo(x, y);
      }
      liquid.lineTo(innerRect.right, baseY);
      liquid.close();

      // Gold body of the liquid, lighter near the surface.
      canvas.drawPath(
        liquid,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              S.goldLight,
              S.gold,
              S.goldDeep,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromLTRB(
              innerRect.left, levelY - amp, innerRect.right, baseY)),
      );

      // A brighter rim right at the waterline for a glossy meniscus.
      final crest = Path()..moveTo(innerRect.left, levelY);
      for (int i = 0; i <= steps; i++) {
        final x = innerRect.left + innerRect.width * (i / steps);
        final y = levelY +
            math.sin((i / steps) * 2 * math.pi * 1.4 + phase) * amp +
            math.sin((i / steps) * 2 * math.pi * 0.6 - phase * 0.7) * amp * 0.4;
        crest.lineTo(x, y);
      }
      canvas.drawPath(
        crest,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = S.goldLight.withValues(alpha: 0.9),
      );

      // A few suspended bubbles rising through the gold.
      final bubble = Paint()..color = S.goldLight.withValues(alpha: 0.5);
      for (int i = 0; i < 5; i++) {
        final bx = innerRect.left +
            innerRect.width * (0.2 + 0.6 * ((i * 0.37 + wave) % 1));
        final rise = ((wave * (0.5 + i * 0.13) + i * 0.2) % 1);
        final by = baseY - (baseY - levelY) * rise - 6;
        if (by > levelY + 6) {
          canvas.drawCircle(Offset(bx, by), 2.0 + (i % 3), bubble);
        }
      }
    }

    canvas.restore();

    // Glass highlight — a soft vertical sheen down the left.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(innerRect.left + 16, innerRect.top + 18, 16,
            innerRect.height * 0.62),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    // Glass rim outline.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      rrect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = S.accent.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(_JarPainter old) => old.fill != fill || old.wave != wave;
}
