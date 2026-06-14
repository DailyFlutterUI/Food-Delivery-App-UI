import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'delivery_theme.dart';

// ===========================================================================
// 1) Order Confirmed — a box drops in, then a "CONFIRMED" stamp slams down.
// ===========================================================================

class ConfirmedHero extends StatefulWidget {
  const ConfirmedHero({super.key});

  @override
  State<ConfirmedHero> createState() => _ConfirmedHeroState();
}

class _ConfirmedHeroState extends State<ConfirmedHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Box drops + settles in the first 40%.
    final drop = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );
    // Stamp slams down around 50–66%.
    final stamp = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.5, 0.66, curve: Curves.easeOutCubic),
    );

    return _HeroFrame(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final dropV = drop.value;
          final stampV = stamp.value;
          // A subtle bounce settle for the box after it lands.
          final settle = _c.value > 0.4
              ? math.sin((_c.value - 0.4) * math.pi * 3) *
                  math.exp(-(_c.value - 0.4) * 8) *
                  6
              : 0.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, (1 - dropV) * -140 + settle),
                child: Transform.scale(
                  scale: 0.7 + dropV * 0.3,
                  child: const _ParcelBox(size: 130),
                ),
              ),
              // The stamp: starts big + rotated + faint, slams to rest.
              if (stampV > 0)
                Transform.rotate(
                  angle: (1 - stampV) * 0.5 - 0.18,
                  child: Transform.scale(
                    scale: 2.4 - stampV * 1.4,
                    child: Opacity(
                      opacity: stampV.clamp(0.0, 1.0),
                      child: const _Stamp(
                        label: 'CONFIRMED',
                        color: D.accent,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
// 2) Packed at Warehouse — a conveyor belt carries the box under a scan beam.
// ===========================================================================

class WarehouseHero extends StatefulWidget {
  const WarehouseHero({super.key});

  @override
  State<WarehouseHero> createState() => _WarehouseHeroState();
}

class _WarehouseHeroState extends State<WarehouseHero>
    with TickerProviderStateMixin {
  late final AnimationController _belt = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _belt.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _HeroFrame(
      child: AnimatedBuilder(
        animation: Listenable.merge([_belt, _scan]),
        builder: (_, _) {
          // Box rides left→right then loops; brief glow as it crosses the beam.
          final p = _scan.value;
          final boxX = -0.9 + (p * 1.8); // -0.9..0.9 of half-width
          final underBeam = (p - 0.5).abs() < 0.12;
          return CustomPaint(
            painter: _ConveyorPainter(beltPhase: _belt.value, scan: _scan.value),
            child: LayoutBuilder(
              builder: (_, box) {
                final cx = box.maxWidth / 2 + boxX * box.maxWidth * 0.42;
                return Stack(
                  children: [
                    Positioned(
                      left: cx - 44,
                      top: box.maxHeight * 0.30,
                      child: _ParcelBox(
                        size: 88,
                        glow: underBeam,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConveyorPainter extends CustomPainter {
  _ConveyorPainter({required this.beltPhase, required this.scan});
  final double beltPhase;
  final double scan;

  @override
  void paint(Canvas canvas, Size size) {
    final beltTop = size.height * 0.66;
    final beltRect = Rect.fromLTWH(0, beltTop, size.width, 26);

    // Belt body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(beltRect, const Radius.circular(13)),
      Paint()..color = D.ink.withValues(alpha: 0.82),
    );
    // Moving chevrons on the belt.
    final chev = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const gap = 34.0;
    final shift = beltPhase * gap;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(beltRect, const Radius.circular(13)));
    for (double x = -gap + shift; x < size.width + gap; x += gap) {
      final cy = beltTop + 13;
      final path = Path()
        ..moveTo(x, cy - 6)
        ..lineTo(x + 7, cy)
        ..lineTo(x, cy + 6);
      canvas.drawPath(path, chev);
    }
    canvas.restore();

    // Belt rollers.
    final roller = Paint()..color = D.inkSoft;
    canvas.drawCircle(Offset(14, beltTop + 13), 9, roller);
    canvas.drawCircle(Offset(size.width - 14, beltTop + 13), 9, roller);

    // Scanner head at the top center, with a sweeping beam.
    final headRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.12),
      width: 90,
      height: 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(11)),
      Paint()..color = D.ink,
    );

    // The scan beam — a soft accent cone that brightens as the box crosses.
    final intensity = 1 - ((scan - 0.5).abs() / 0.5);
    final beam = Path()
      ..moveTo(size.width / 2 - 30, headRect.bottom)
      ..lineTo(size.width / 2 + 30, headRect.bottom)
      ..lineTo(size.width / 2 + 64, beltTop)
      ..lineTo(size.width / 2 - 64, beltTop)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            D.accent.withValues(alpha: 0.05 + intensity * 0.30),
            D.accent.withValues(alpha: 0.0),
          ],
        ).createShader(beam.getBounds()),
    );
    // A crisp scan line that sweeps down the beam.
    final lineY = beltTop - (beltTop - headRect.bottom) * (1 - scan);
    canvas.drawLine(
      Offset(size.width / 2 - 56, lineY),
      Offset(size.width / 2 + 56, lineY),
      Paint()
        ..color = D.accentLight.withValues(alpha: 0.8)
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
  }

  @override
  bool shouldRepaint(_ConveyorPainter o) =>
      o.beltPhase != beltPhase || o.scan != scan;
}

// ===========================================================================
// 6) Delivered — the parcel drops to the doormat, then a success stamp lands.
// ===========================================================================

class DeliveredHero extends StatefulWidget {
  const DeliveredHero({super.key});

  @override
  State<DeliveredHero> createState() => _DeliveredHeroState();
}

class _DeliveredHeroState extends State<DeliveredHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drop = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.45, curve: Curves.bounceOut),
    );
    final stamp = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.55, 0.78, curve: Curves.easeOutCubic),
    );

    return _HeroFrame(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Doormat shadow grows as the parcel nears the ground.
              Align(
                alignment: const Alignment(0, 0.62),
                child: Transform.scale(
                  scale: 0.5 + drop.value * 0.6,
                  child: Container(
                    width: 120,
                    height: 22,
                    decoration: BoxDecoration(
                      color: D.ink.withValues(alpha: 0.10 * drop.value),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.18),
                child: Transform.translate(
                  offset: Offset(0, (1 - drop.value) * -150),
                  child: const _ParcelBox(size: 118, delivered: true),
                ),
              ),
              if (stamp.value > 0)
                Transform.rotate(
                  angle: (1 - stamp.value) * 0.5 - 0.16,
                  child: Transform.scale(
                    scale: 2.3 - stamp.value * 1.3,
                    child: Opacity(
                      opacity: stamp.value.clamp(0.0, 1.0),
                      child: const _Stamp(
                        label: 'DELIVERED',
                        color: D.accent,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
// Shared parts
// ===========================================================================

/// A consistent frame so every hero animation sits on the same stage.
class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}

/// A glossy kraft-paper parcel drawn with gradients — no asset needed.
class _ParcelBox extends StatelessWidget {
  const _ParcelBox({
    required this.size,
    this.glow = false,
    this.delivered = false,
  });

  final double size;
  final bool glow;
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BoxPainter(glow: glow, delivered: delivered),
    );
  }
}

class _BoxPainter extends CustomPainter {
  _BoxPainter({required this.glow, required this.delivered});
  final bool glow;
  final bool delivered;

  static const _kraft = Color(0xFFD9A86B);
  static const _kraftDark = Color(0xFFBE8A4E);
  static const _kraftLight = Color(0xFFEAC58E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Rect.fromLTWH(w * 0.10, h * 0.28, w * 0.80, h * 0.60);

    if (glow) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(body.inflate(8), const Radius.circular(16)),
        Paint()
          ..color = D.accent.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }

    // Soft contact shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          body.shift(const Offset(0, 8)), const Radius.circular(12)),
      Paint()
        ..color = D.ink.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Box body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(10)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kraftLight, _kraft, _kraftDark],
        ).createShader(body),
    );

    // Lid flap across the top.
    final lid = Rect.fromLTWH(w * 0.10, h * 0.28, w * 0.80, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        lid,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ),
      Paint()..color = _kraftDark.withValues(alpha: 0.45),
    );

    // Packing-tape strip down the middle.
    final tape = Rect.fromLTWH(w * 0.42, h * 0.28, w * 0.16, h * 0.60);
    canvas.drawRect(
      tape,
      Paint()..color = const Color(0xFFF3E7CF).withValues(alpha: 0.85),
    );
    // Tape seam highlight.
    canvas.drawLine(
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.50, h * 0.88),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.5,
    );

    // A small shipping label, or a tick when delivered.
    final label = Rect.fromLTWH(w * 0.16, h * 0.50, w * 0.20, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(label, const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    if (delivered) {
      final tick = Path()
        ..moveTo(w * 0.62, h * 0.58)
        ..lineTo(w * 0.68, h * 0.64)
        ..lineTo(w * 0.80, h * 0.50);
      canvas.drawPath(
        tick,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = D.accent,
      );
    } else {
      for (int i = 0; i < 3; i++) {
        final y = h * (0.535 + i * 0.035);
        canvas.drawLine(
          Offset(w * 0.19, y),
          Offset(w * (0.30 - i * 0.03), y),
          Paint()
            ..color = D.inkFaint
            ..strokeWidth = 2,
        );
      }
    }

    // Glossy top-left sheen.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.31, w * 0.18, h * 0.5),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );
  }

  @override
  bool shouldRepaint(_BoxPainter o) =>
      o.glow != glow || o.delivered != delivered;
}

/// A rubber-stamp badge — a rounded double-ruled border with bold tracked text.
class _Stamp extends StatelessWidget {
  const _Stamp({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 3),
          color: color.withValues(alpha: 0.06),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: D.fontDisplay,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
